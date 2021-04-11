extends Control

signal loading()
signal loaded(data)
signal failed(message)

var config = {}
var source = null

var DataUtils = preload("DataUtils.gd").new()

const SOURCES = {
	"EDGAR API": "res://addons/cs-institutions/Data/Edgar.tscn",
	"IEX CLOUD": "res://addons/cs-institutions/Data/IexCloud.tscn"
}

func cache_name(instrument: String):
	return 'INSTITUTIONS_%s_%s' % [self.config.api_source, instrument]

func fetch(instrument: String, force: bool = false):
	self.emit_signal("loading")
	self.config.instrument = instrument

	var result

	if force == false and Cache.has(cache_name(instrument)):
		result = Cache.get(self.cache_name(instrument))

	else:
		result = self.source.fetch(self.config, instrument, force)
		result = yield(result, "completed")

	if not result:
		self.emit_signal("failed", "Failed to fetch data")
		DataUtils.handle_error(self.config, result)
		return null

	if "error" in result:
		self.emit_signal("failed", result.error)
		DataUtils.handle_error(self.config, result)
		return null

	Cache.set(self.cache_name(instrument), result, 86400 / 2)

	self.emit_signal("loaded", result)

	# Save that our API key is good for fetching
	DataUtils.validate_api_key(self.config)

	return result

func _ready():
	self.config = Utils.File.load_json("user://config.json")
	assert(self.config.api_source in SOURCES, "SOURCE NOT FOUND")

	self.source = load(SOURCES[self.config.api_source]).instance()

	self.add_child(source)
	self.add_child(DataUtils)

func _input(event: InputEvent):
	if not event is InputEventKey: return

	if event.is_action_pressed("ui_reload"):
		self.fetch(self.config.instrument, true)
