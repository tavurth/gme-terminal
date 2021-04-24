extends Control

var config = {}

func get_config():
	config = Utils.File.read_json("user://config.json")

	if not config:
		return {
			"instrument": {
				"cik": "1326380",
				"name": "GME"
			}
		}

	return config

func load_instrument(instrument: Dictionary):
	$VBoxContainer/HeaderButtons/HBoxContainer/Instrument.text = instrument.name

func _ready():
	$InstrumentPicker.set_instrument(Globals.config.instrument)
	self.load_instrument(Globals.config.instrument)

	$VBoxContainer/HeaderButtons/HBoxContainer/INST.grab_focus()

func set_instrument(instrument: Dictionary):
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
