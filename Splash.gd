extends Control

onready 	var TabContainer = $MarginContainer/HBoxContainer/VBoxContainer/TabContainer
onready var LineEdit = $MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/LineEdit

var config = {}

func _ready():
	var old_config = Utils.File.load_json("user://config.json")

	if not old_config:
		return

	if "valid_api_key" in old_config:
		var _e = self.get_tree().change_scene("res://Main.tscn")

func _on_Button_pressed():
	var API_KEY = LineEdit.text

	if len(API_KEY) < 1:
		return

	self.config.api_key = API_KEY

	if not "api_source" in self.config:
		config.api_source = TabContainer.get_tab_title(0)

	Utils.File.write_json("user://config.json", self.config)
	var _e = self.get_tree().change_scene("res://Main.tscn")

func _on_RichTextLabel_meta_clicked(meta):
	print(meta)
	var _e = OS.shell_open(meta)

func _on_LineEdit_gui_input(event):
	if not event is InputEventKey: return

	if event.scancode == KEY_ENTER:
		self._on_Button_pressed()

func _on_TabContainer_tab_changed(tab_index):
	LineEdit.set_text("")
	config.api_source = TabContainer.get_tab_title(tab_index)
