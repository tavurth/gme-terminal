extends Control

const HALF_MONTH = 86400 * 7 * 2
const request_part = "cnsfails{year}{month}{part}.zip"
const request_url = "https://www.sec.gov/files/data/fails-deliver-data/{request_part}"

const DIRECTORY = "user://"
var DataDir = Directory.new()

var ftds = []
var loading = 0
var instrument = null

class DataSort:
	static func by_date(a, b):
		return a['settlement'] < b['settlement']

func build_request(time: int):
	var date = OS.get_datetime_from_unix_time(time)
	return request_part.format({
		"year": date.year,
		"month": "%02d" % date.month,
		"part": "a" if date.day < 15 else "b"
	})

func build_url(time: int):
	return request_url.format({ "request_part": build_request(time) })

func open(filename):
	# Godot's zip loading is not so good at the moment
	# but we can load the data as a resource pack,
	# this loads it into memory at the res:// directory level
	var loaded = ProjectSettings.load_resource_pack(filename, true)

	# File is not a zip, or file not found
	if not loaded:
		push_error("Failed to load FTD zip file: %s" % filename)
		return null

	# Then we just trip out the string name and find the .txt
	# file which was extracted into memory
	var text_file = filename.right(filename.rfind("/") + 1)
	text_file = text_file.left(text_file.rfind("."))

	# Then load the file from memory as CSV -> JSON
	var file = File.new()
	file.open("res://%s.txt" % text_file, file.READ)

	var to_return = file.get_as_text()

	file.close()

	return to_return

func fetch(time: int):
	yield(get_tree(), "idle_frame")

	var filename = "%s%s" % [DIRECTORY, build_request(time)]

	if DataDir.file_exists(filename):
		return open(filename)

	var fetcher = HTTPRequest.new()
	self.add_child(fetcher)
	fetcher.set_download_chunk_size(16777216)
	fetcher.set_download_file(filename)

	var result = fetcher.request(build_url(time))
	if result != OK:
		return null

	result = yield(fetcher, "request_completed")
	fetcher.queue_free()

	if result[1] != 200:
		push_error("Got %s response from SEC" % str(result[1]))
		DataDir.remove(filename)
		return null

	return open(filename)

func loaded_one():
	self.loading -= 1

	if self.loading <= 1:
		self.render_list()

func _completed(result = null):
	if not result:
		return self.loaded_one()

	var lines = result.split("\n")
	var search = "|%s|" % self.instrument

	var headers = lines[0].to_lower().split("|")

	# I only care about the first word in header
	for index in range(0, len(headers)):
		headers[index] = headers[index].split(" ")[0]

	var to_append = []

	for line in lines:
		if search in line:
			var to_add = {}
			var parts = line.split("|")

			for index in range(0, len(headers)):
				to_add[headers[index]] = parts[index]

			to_add.quantity = float(to_add.quantity)

			to_append.append(to_add)

	self.ftds += to_append

	self.loaded_one()

func fetch_months(months: int):

	yield(get_tree().create_timer(0.5), "timeout")
	self.ftds = []
	var results = []

	self.loading = 0
	for i in range(0, months * 2):
		self.loading += 1
		var result = self.fetch(OS.get_unix_time() - HALF_MONTH * i)
		result.connect("completed", self, "_completed")

func render_list():
	self.ftds.sort_custom(DataSort, "by_date")

	$FTDChart.redraw(self.ftds)
	$Loader.hide()

func redraw():
	self.fetch_months(2)

func set_instrument(instrument: String):
	self.instrument = instrument
	$Loader.show()
	$FTDChart.reset()

	if not self.get_parent().visible: return
	self.fetch_months(2)

func _ready():
	$Loader.show()
	$FTDChart.reset()
	DataDir.change_dir(DIRECTORY)
