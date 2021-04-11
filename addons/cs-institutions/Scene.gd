extends Control

signal instrument_set(instrument)

var Institution = preload("Institution.tscn")

var Buttons = preload("sort_group.tres")

onready var Header = $TableContent/Container/Header
onready var Table = $TableContent/Container/Scroller/Table

var data: Array = []
var sort_mode = "by_shares_desc"

class DataSort:
	static func date(date: String):
		var parts: Array = date.split("/")
		var to_return = 0

		to_return += int(parts[2]) * 365 # year
		to_return += int(parts[1]) # day
		to_return += int(parts[0]) * 30 # month

		return to_return

	static func by_shares_asc(a, b):
		return a.shares < b.shares

	static func by_shares_desc(a, b):
		return a.shares > b.shares

	static func by_change_asc(a, b):
		return a.shares_change < b.shares_change

	static func by_change_desc(a, b):
		return a.shares_change > b.shares_change

	static func by_percent_asc(a, b):
		return a.shares_pct_change < b.shares_pct_change

	static func by_percent_desc(a, b):
		return a.shares_pct_change > b.shares_pct_change

	static func by_date_asc(a, b):
		return date(a.date) < date(b.date)

	static func by_date_desc(a, b):
		return date(a.date) > date(b.date)

func cleanup():
	for child in Table.get_children():
		child.hide()
		child.queue_free()

func setup():
	self.cleanup()

	self.data.sort_custom(DataSort, self.sort_mode)

	for row in self.data:
		var item = Institution.instance()
		item.setup(row)
		Table.add_child(item)

func _on_failed(message: String = "An error occurred"):
	$Loader.hide()
	$Error.show()

	$"Error/Label".set_text(message)

func _on_loading():
	self.cleanup()
	$Error.hide()
	$Loader.show()

func _on_loaded(data):
	$Loader.hide()
	self.data = data.duplicate()
	self.setup()

const DW_SYMBOL = " ▼"
const UP_SYMBOL = " ▲"

func _on_button_toggled(button_toggled):
	var button = Buttons.get_pressed_button()
	self.sort_mode = button.get_meta("sort")

	var button_text = button.text
	for item in Buttons.get_buttons():
		item.set_text(item.text.rstrip(UP_SYMBOL))
		item.set_text(item.text.rstrip(DW_SYMBOL))

	if UP_SYMBOL in button_text:
		self.sort_mode += "_desc"
		button.text += DW_SYMBOL

	else:
		self.sort_mode += "_asc"
		button.text += UP_SYMBOL

	self.setup()

func _ready():
	Header.get_node("Shares").set_meta("sort", "by_shares")
	Header.get_node("Change").set_meta("sort", "by_change")
	Header.get_node("FileDate").set_meta("sort", "by_date")
	Header.get_node("ChangePct").set_meta("sort", "by_percent")

	for button in Buttons.get_buttons():
		button.connect("toggled", self, "_on_button_toggled")
