extends Node2D

const request_url = "https://datafied.api.edgar-online.com/v2/ownerships/currentownerholdings?appkey={api_key}&filter=ticker%20eq%20%22{instrument}%22&limit=999"

var DATE_CURRENT
var OWNER_NAME
var SHARES_COUNT
var SHARES_CHANGE
var SHARES_PCT_CHANGE
var COMPANY_TICKER

func extract_item(item: Array):
	return {
		"date": item[DATE_CURRENT].value,
		"holder": item[OWNER_NAME].value,
		"shares": item[SHARES_COUNT].value,
		"shares_change": item[SHARES_CHANGE].value,
		"shares_pct_change": round(item[SHARES_PCT_CHANGE].value * 1000) / 10,
		"ticker": item[COMPANY_TICKER].value,
	}

func find_index(name: String, rows: Array):
	var index = 0

	for item in rows:
		if item.field == name:
			return index

		index += 1

	return -1

func compute_indexes(row: Array):
	"""
	My data source seems to get mixed up sometimes
	This was a quick fix until we can find a better data source

	FInds the correct index for each key and saves it above for item extraction
	"""
	DATE_CURRENT = find_index("currentreportdate", row)
	OWNER_NAME = find_index("ownername", row)
	SHARES_COUNT = find_index("sharesheld", row)
	SHARES_CHANGE = find_index("sharesheldchange", row)
	SHARES_PCT_CHANGE = find_index("sharesheldpercentchange", row)
	COMPANY_TICKER = find_index("ticker", row)

func extract_data(data: Dictionary):
	if not "result" in data:
		return null

	data = data.result
	if not len(data.rows):
		return null

	# print(JSON.print(data, "  "))
	var total = data.totalrows
	var to_return = []

	self.compute_indexes(data.rows[0].values)

	for row in data.rows:
		to_return.append(self.extract_item(row.values))

	return to_return

func fetch(config: Dictionary, instrument: String, force = false):
	yield(get_tree(), "idle_frame")

	var data = $HttpFetch.fetch(request_url.format({
		"instrument": instrument,
		"api_key": config.api_key
	}))

	data = yield(data, "completed")

	if not data or  "Error" in data:
		return data

	data = self.extract_data(data)

	if not data:
		return null

	return data
