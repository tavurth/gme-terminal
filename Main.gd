extends Control

var config

func load_instrument(name: String):
	$VBoxContainer/HeaderButtons/HBoxContainer/InstrumentName.text = name
	$"VBoxContainer/cs-institutions".set_instrument(name)

func _ready():
	config = Utils.File.load_json("user://config.json")

	if config and "instrument" in config:
		return self.load_instrument(config.instrument)

	self.load_instrument("GME")

func set_instrument(instrument: String):
	self.load_instrument(instrument)

	config.instrument = instrument
	Utils.File.write_json("user://config.json", config)

func _on_BackButton_pressed():
	Utils.File.write_json("user://config.json", { "instrument": config.instrument })
	var _e = get_tree().change_scene("res://Splash.tscn")
