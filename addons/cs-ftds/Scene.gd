extends Control

const HALF_MONTH = 86400 * 7 * 2
const request_part = "cnsfails{year}{month}{part}.zip"
const request_url = "https://www.sec.gov/files/data/fails-deliver-data/{request_part}"

const DIRECTORY = "user://"
var DataDir = Directory.new()

var request_id = 0

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
	var loaded = ProjectSettings.load_resource_pack(filename)

	# File is not a zip, or file not found
	if not loaded:
		return null

	# Then we just trip out the string name and find the .txt
	# file which was extracted into memory
	var text_file = filename.right(filename.rfind("/") + 1)
	text_file = text_file.left(text_file.rfind("."))

	# Then load the file from memory as text
	return Utils.File.read_string("res://%s.txt" % text_file)

func fetch(time: int):
	yield(get_tree(), "idle_frame")

	var filename = "%s%s" % [DIRECTORY, build_request(time)]

	if DataDir.file_exists(filename):
		return open(filename)

	$HTTPRequest.set_download_file(filename)
	$HTTPRequest.request(build_url(time))

	var result = yield($HTTPRequest, "request_completed")

	return open(filename)

func fetch_months(months: int):
	var promises = []

	for i in range(0, months * 2):
		promises.append(fetch(OS.get_unix_time() - HALF_MONTH * i))

	var to_return = []
	for promise in promises:
		var result = yield(promise, "completed")

		if result:
			to_return.append(result)

	return to_return

func _ready():
	DataDir.change_dir(DIRECTORY)
	print(yield(fetch_months(3), "completed"))
