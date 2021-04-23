extends Control

var config

func load_instrument(name: String):
	$VBoxContainer/HeaderButtons/HBoxContainer/InstrumentName.text = name

func _ready():
	config = Utils.File.read_json("user://config.json")

	if config and "instrument" in config:
		$InstrumentPicker.emit_signal("instrument_selected", config.instrument)
		return self.load_instrument(config.instrument)

	$InstrumentPicker.emit_signal("instrument_selected", "GME")
	$VBoxContainer/HeaderButtons/HBoxContainer/INST.grab_focus()

func set_instrument(instrument: String):
	self.load_instrument(instrument)

	config.instrument = instrument
	Utils.File.write_json("user://config.json", config)

func _on_BackButton_pressed():
	Utils.File.write_json("user://config.json", { "instrument": config.instrument })
	var _e = get_tree().change_scene("res://Splash.tscn")

func _on_INST_pressed():
	$VBoxContainer/TabContainer.set_current_tab(0)

func _on_FTD_pressed():
	$VBoxContainer/TabContainer.set_current_tab(1)
