extends Control

func _ready():
	var config = Utils.File.load_json("user://config.json")

	if not config:
		return

	if "valid_api_key" in config:
		var _e = self.get_tree().change_scene("res://Main.tscn")

func _on_Button_pressed():
	var API_KEY = $MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/LineEdit.text

	if len(API_KEY) < 1:
		return

	Utils.File.write_json("user://config.json", { "api_key": API_KEY })
	var _e = self.get_tree().change_scene("res://Main.tscn")

func _on_RichTextLabel_meta_clicked(meta):
	OS.shell_open(meta)

func _on_LineEdit_gui_input(event):
	if not event is InputEventKey: return

	if event.scancode == KEY_ENTER:
		self._on_Button_pressed()
