extends Control

signal loading()
signal loaded(data)
signal failed(message)

var source = null

var DataUtils = preload("DataUtils.gd").new()

const SOURCES = {
	"SEC": "res://addons/cs-institutions/Data/SEC.tscn",
	"EDGAR API": "res://addons/cs-institutions/Data/Edgar.tscn",
	"IEX CLOUD": "res://addons/cs-institutions/Data/IexCloud.tscn"
}

func cache_name(instrument: String):
	return 'INSTITUTIONS_%s_%s' % [Globals.config.api_source, instrument]

func fetch(instrument: Dictionary, force: bool = false):
	self.emit_signal("loading")
	Globals.config.instrument = instrument

	var result

	if force == false and Cache.has(cache_name(instrument.name)):
		result = Cache.get(self.cache_name(instrument.name))

	else:
		result = self.source.fetch(instrument)
		result = yield(result, "completed")

	if not result:
		self.emit_signal("failed", "Failed to fetch data")
		DataUtils.handle_error(result)
		return null

	if "error" in result:
		self.emit_signal("failed", result.error)
		DataUtils.handle_error(result)
		return null

	Cache.set(self.cache_name(instrument.name), result, 86400 / 2)

	self.emit_signal("loaded", result)

	return result

func _ready():
	assert(Globals.config.api_source in SOURCES, "SOURCE NOT FOUND")
	self.source = load(SOURCES[Globals.config.api_source]).instance()

	self.add_child(source)
	self.add_child(DataUtils)

func _input(event: InputEvent):
	if not event is InputEventKey: return

	if event.is_action_pressed("ui_reload"):
		self.fetch(Globals.config.instrument.name, true)
