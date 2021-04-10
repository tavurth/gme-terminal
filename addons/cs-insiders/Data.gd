extends Control

signal failed()
signal loading()
signal loaded(data)

var config = null
const request_url = "https://datafied.api.edgar-online.com/v2/ownerships/currentownerholdings?appkey={api_key}&filter=ticker%20eq%20%22{instrument}%22&limit=999"

func cache_name(instrument):
	return 'INSIDERS_%s' % instrument

func extract_item(item: Array):
	return {
		"date": {
			"current": item[3].value,
			"previous": item[4].value,
		},
		"owner": {
			"name": item[5].value,
			"city": item[13].value,
			"state": item[14].value,
			"zip": item[15].value,
			"country": item[16].value,
		},
		"shares": {
			"price": item[22].value,
			"date": item[23].value,
			"count": item[24].value,
			"change": item[25].value,
			"pct_change": item[26].value,
		},
		"value": {
			"market": item[27].value,
			"change": item[28].value,
			"portfolio_pct": item[29].value,
		},
		"company": {
			"ticker": item[7].value,
			"name": item[8].value,
			"exchange": item[11].value
		},
	}

func extract_data(data: Dictionary):
	if not "result" in data:
		self.emit_signal("failed")
		return

	data = data.result

	# print(JSON.print(data, "  "))
	var total = data.totalrows
	var to_return = []

	for row in data.rows:
		to_return.append(self.extract_item(row.values))

	return to_return

func handle_error(data):
	get_parent().get_node("Scene/Loader").hide()
	get_parent().get_node("Scene/Error").show()

	if not data:
		return

	get_parent().get_node("Scene/Error/Label").set_text(data.Error.Message)


func validate_api_key():
	if "valid_api_key" in self.config: return

	self.config.valid_api_key = true
	Utils.File.write_json("user://config.json", self.config)

func fetch(instrument):
	yield(get_tree(), "idle_frame")

	self.emit_signal("loading")

	var data

	if false and Cache.has(cache_name(instrument)):
		data = Cache.get(self.cache_name(instrument))

	else:
		data = $HttpFetch.fetch(request_url.format({
			"instrument": "GME",
			"api_key": self.config.api_key
		}))

		data = yield(data, "completed")

		if not data or  "Error" in data:
			return handle_error(data)

		Cache.set(self.cache_name(instrument), data, 86400 / 2)

	data = self.extract_data(data)

	self.validate_api_key()

	if not data:
		return null

	self.emit_signal("loaded", data)

	return data

func _ready():
	self.config = Utils.File.load_json("user://config.json")
