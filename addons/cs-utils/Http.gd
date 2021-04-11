extends Node2D

var request_id = 0
var interface = preload("Request.gd").new()

const STREAM_TIMEOUT = 5

func _ready():
	self.set_name("HttpFetch")
	self.add_child(self.interface)

func close(stream):
	if not stream:
		return

	if stream.has_method("close"):
		stream.close()

	if stream.has_method("cancel_request"):
		stream.cancel_request()

func network_error(error, type, url = null):
	if error == ERR_UNAVAILABLE:
		push_error(Errors.string_name(error))
		return

	if error < 2:
		push_error(type)

	else:
		push_error(Errors.string_name(error))

	if url:
		push_warning("[Http error]: %s %s %s" % [Errors.string_name(error), type, url])
	else:
		push_warning("[Http error]: %s %s" % [Errors.string_name(error), type])
	return null

func default_headers():
	return [
		"user-agent: CustomTrader",
		"Content-Type: application/json",
	]

func fetch(url, headers = default_headers(), data = null, type = null):
	# Make sure we always return a functionstate
	yield(get_tree(), "idle_frame")

	# We'll track our response ID to prevent race conditions
	self.request_id += 1
	var current_request_id = self.request_id

	if not interface:
		return network_error(ERR_UNAVAILABLE, "interface is null")

	# Make sure we can perform this request
	close(interface)

	var error
	if data:
		var query = JSON.print(data)
		if not type:
			type = HTTPClient.METHOD_POST

		error = interface.request(url, headers, true, type, query)

	else:
		error = interface.request(url, headers, true)

	if error:
		close(interface)
		return network_error(error, "when making request", url)

	var _result = yield(interface, "request_completed")
	error = _result[0]
	if error:
		close(interface)
		return network_error(error, "when waiting for request completion", url)

	var body = _result[3]
	var result = parse_json(body.get_string_from_utf8())

	if result == null and body.get_string_from_utf8():
		return {
			"error": body.get_string_from_utf8()
		}

	if not result:
		return network_error(ERR_UNAVAILABLE, "no body found", url)

	if "errorMessage" in result:
		return network_error(1, result.errorMessage, url)

	if self.request_id != current_request_id:
		print("Http: Request was superceded")
		return null

	return result


