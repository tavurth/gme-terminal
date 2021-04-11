extends Control

signal failed()
signal loading()
signal loaded(data)

var config = null
var instrument
const request_url = "https://datafied.api.edgar-online.com/v2/ownerships/currentownerholdings?appkey={api_key}&filter=ticker%20eq%20%22{instrument}%22&limit=999"

func cache_name(instrument):
	return 'INSIDERS_%s' % instrument

var DATE_CURRENT
var DATE_PREVIOUS
var OWNER_NAME
var OWNER_CITY
var OWNER_STATE
var OWNER_ZIP
var OWNER_COUNTRY
var SHARES_PRICE
var SHARES_DATE
var SHARES_COUNT
var SHARES_CHANGE
var SHARES_PCT_CHANGE
var VALUE_MARKET
var VALUE_CHANGE
var VALUE_PORTFOLIO_PCT
var COMPANY_TICKER
var COMPANY_NAME
var COMPANY_EXCHANGE

func extract_item(item: Array):
	return {
		"date": {
			"current": item[DATE_CURRENT].value,
			"previous": item[DATE_PREVIOUS].value,
		},
		"owner": {
			"name": item[OWNER_NAME].value,
			"city": item[OWNER_CITY].value,
			"state": item[OWNER_STATE].value,
			"zip": item[OWNER_ZIP].value,
			"country": item[OWNER_COUNTRY].value,
		},
		"shares": {
			"price": item[SHARES_PRICE].value,
			"date": item[SHARES_DATE].value,
			"count": item[SHARES_COUNT].value,
			"change": item[SHARES_CHANGE].value,
			"pct_change": round(item[SHARES_PCT_CHANGE].value * 1000) / 10,
		},
		"value": {
			"market": item[VALUE_MARKET].value,
			"change": item[VALUE_CHANGE].value,
			"portfolio_pct": item[VALUE_PORTFOLIO_PCT].value,
		},
		"company": {
			"ticker": item[COMPANY_TICKER].value,
			"name": item[COMPANY_NAME].value,
			"exchange": item[COMPANY_EXCHANGE].value
		},
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
	DATE_PREVIOUS = find_index("priorreportdate", row)
	OWNER_NAME = find_index("ownername", row)
	OWNER_CITY = find_index("city", row)
	OWNER_STATE = find_index("ownername", row)
	OWNER_ZIP = find_index("zip", row)
	OWNER_COUNTRY = find_index("country", row)
	SHARES_PRICE = find_index("price", row)
	SHARES_DATE = find_index("pricedate", row)
	SHARES_COUNT = find_index("sharesheld", row)
	SHARES_CHANGE = find_index("sharesheldchange", row)
	SHARES_PCT_CHANGE = find_index("sharesheldpercentchange", row)
	VALUE_MARKET = find_index("marketvalue", row)
	VALUE_CHANGE = find_index("marketvaluechange", row)
	VALUE_PORTFOLIO_PCT = find_index("portfoliopercent", row)
	COMPANY_TICKER = find_index("ticker", row)
	COMPANY_NAME = find_index("companyname", row)
	COMPANY_EXCHANGE = find_index("exchange", row)

func extract_data(data: Dictionary):
	if not "result" in data:
		self.emit_signal("failed")
		return

	data = data.result
	if not len(data.rows):
		self.emit_signal("failed")
		return

	# print(JSON.print(data, "  "))
	var total = data.totalrows
	var to_return = []

	self.compute_indexes(data.rows[0].values)

	for row in data.rows:
		to_return.append(self.extract_item(row.values))

	return to_return

func handle_error(data):
	self.config.erase("valid_api_key")
	Utils.File.write_json("user://config.json", self.config)

	get_parent().get_node("Scene/Loader").hide()
	get_parent().get_node("Scene/Error").show()

	if not data:
		return

	get_parent().get_node("Scene/Error/Label").set_text(data.Error.Message)

func validate_api_key():
	if "valid_api_key" in self.config: return

	self.config.valid_api_key = true
	Utils.File.write_json("user://config.json", self.config)

func fetch(instrument: String, force = false):
	yield(get_tree(), "idle_frame")
	self.instrument = instrument

	get_parent().get_node("Scene/Loader").show()
	get_parent().get_node("Scene/Error").hide()

	self.emit_signal("loading")

	var data

	if force == false and Cache.has(cache_name(instrument)):
		data = Cache.get(self.cache_name(instrument))

	else:
		data = $HttpFetch.fetch(request_url.format({
			"instrument": instrument,
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

func _input(event: InputEvent):
	if not event is InputEventKey: return

	if event.is_action_pressed("ui_reload"):
		self.fetch(self.instrument, true)
