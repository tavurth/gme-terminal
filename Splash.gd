extends Control

func _ready():
	var config = Utils.File.load_json("user://config.json")
	if "valid_api_key" in config:
		var _e = self.get_tree().change_scene("res://Main.tscn")

func _on_Button_pressed():
	var API_KEY = $MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/LineEdit.text

	Utils.File.write_json("user://config.json", { "api_key": API_KEY })
	var _e = self.get_tree().change_scene("res://Main.tscn")
