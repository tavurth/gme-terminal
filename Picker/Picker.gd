extends VBoxContainer

signal type_selected(type)
signal instrument_selected(instrument)

onready var ItemListContainer = $ItemListContainer

func _ready():
	self.add_to_group("modals")
	self.hide()

func show():
	.show()

	var LineEdit = $ItemListContainer/Panel/MarginContainer/VBoxContainer/LineEdit
	LineEdit.grab_focus()
	LineEdit.set_text("")

	var InstrumentList = $ItemListContainer/Panel/MarginContainer/VBoxContainer/InstrumentList
	InstrumentList.search = ""
	InstrumentList.show_instruments()

func _input(event: InputEvent):
	if event is InputEventKey:
		if event.scancode == KEY_ESCAPE and self.visible:
			get_tree().set_input_as_handled()
			return self.hide()

	if self.visible: return
	if not event.is_action_pressed("ui_picker"): return

	get_tree().set_input_as_handled()
	self.show()

# Click-outside to close the picker window
func _on_OutsidePicker_gui_input(event):
	if not event is InputEventMouseButton: return
	if not event.pressed: return

	if event.button_index == 1:
		self.hide()
