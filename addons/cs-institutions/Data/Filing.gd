extends Node2D

const XML_HEADERS = [
	"User-Agent: FilingsReader",
	"Accept: text/html,application/xhtml+xml",
]

const TXT_HEADERS = [
	"User-Agent: FilingsReader",
	"Accept: text,text/html",
]

const filing_url = "https://sec.gov{archive_part}"
const filings_url = "https://feed2json.org/convert?url=https%3A%2F%2Fdata.sec.gov%2Frss%3Fcik%3D{cik}%26type%3D3%2C4%2C5%26exclude%3Dtrue%26count%3D4000"

func fetch_buffer(url: String, headers: Array = TXT_HEADERS):
	var interface = HTTPRequest.new()
	interface.set_download_chunk_size(16777216)
	self.add_child(interface)

	# $HTTPRequest.set_download_file("sec_filings.temp.txt")
	interface.request(url, headers, true)

	var result = yield(interface, "request_completed")
	self.remove_child(interface)

	if result[0] != OK:
		return {
			"url": url,
			"code": "ERR_CONN",
			"error": "Connection issue"
		}

	if result[1] != 200:
		return {
			"url": url,
			"code": str(result[1]),
			"error": "SEC failed to deliver issues",
		}

	return { "data": result[3] }

func fetch_string(url: String, headers: Array = TXT_HEADERS):
	return yield(fetch_buffer(url, headers), "completed").data.get_string_from_utf8()

func fetch_rss(instrument: Dictionary):
	var result = fetch_string(filings_url.format({ "cik": instrument.cik }), XML_HEADERS)

	result = yield(result, "completed")
	result = parse_json(result)
	return result.items

func find_before(entirety: String, substr: String):
	if not substr in entirety:
		prints("NOT FOUND", substr)
		return null

	return entirety.left(entirety.find(substr))

func find_after(entirety: String, substr: String):
	if not substr in entirety:
		prints("NOT FOUND", substr)
		return null

	return entirety.right(entirety.find(substr) + len(substr)).strip_edges()

func find_agregate(entirety: String):
	var start_pos
	start_pos = entirety.find(" owned by each reporting person")
	start_pos = entirety.rfind("<tr", start_pos)
	var table

	# Find the position of the last row in the table
	# before the holder information starts
	table = entirety.right(start_pos)
	table = find_before(table, "</tr>")
	table = table.replace("<td", "<text")
	table = table.replace("</td", "</text")

	# Open the table row with the XML parser
	var xml = XMLParser.new()
	xml.open_buffer(table.to_utf8())

	# Find all tags which could be the share count information
	var amount_tags = []
	while xml.read() == 0:
		if xml.get_node_type() == XMLParser.NODE_TEXT:
			var data = xml.get_node_data().strip_edges()
			if "(1)" in data or "," in data:
				amount_tags.append(data)

	# Cleanup and extract the actual share amount (remove SEC inaccuracies)
	var size
	size = amount_tags[-1]
	size = size.replace(",", "")
	size = size.replace("&nbsp;", "")
	if " " in size:
		size = size.left(size.find(" "))

	# Finally!
	return int(size)

func read_13D(link: String):
	var result = fetch_string(link, TXT_HEADERS)
	result = yield(result, "completed")
	if "error" in result:
		prints("FAILED", result.url)
		push_error(result.error)
		return null

	var part

	part = link.right(link.rfind("/") + 1)
	part = part.left(part.rfind("-index"))
	part = "%s.txt" % part

	if not part in result:
		return {
			"error": "No .txt found for filing",
			"code": "ERR_TXT"
		}

	var filing
	# Find the start of link
	filing = result.right(result.rfind('="', result.rfind(part)) + 2)
	# Find the end of link
	filing = filing.left(filing.find('"'))

	result = fetch_string(filing_url.format({ "archive_part": filing }))
	result = yield(result, "completed")
	if "error" in result:
		prints("FAILED", result.url)
		push_error(result.error)
		return null

	# Easier matching
	result = result.to_lower()

	var company_str = find_after(result, "filed by:")
	if not company_str:
		push_error("NO COMPANY FILING")
		return null

	var company_name
	company_name = find_after(company_str, "company conformed name:")
	company_name = find_before(company_name, "\n")

	var date
	date = find_after(result, "filed as of date:")
	date = find_before(date, "\n")

	var shares = 0
	shares += find_agregate(result)

	prints(company_name, shares, date)
	print('--------------------------------------------------')
	print()

