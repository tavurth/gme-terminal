extends ItemList

var search = ""
var selected = null

export(Array) var data_files = [
	"res://Picker/data/stocks.json",
]

var all_instruments = []
onready var Scroller: VScrollBar = self.get_v_scroll()
onready var Root = get_node('../../../../..')

func load_json(filename):
	var input_file = File.new()
	input_file.open(filename, File.READ)
	var data = parse_json(input_file.get_as_text())
	input_file.close()
	return data

func _ready():
	var to_set = []
	for data_file in data_files:
		to_set = to_set + load_json(data_file)

	self.all_instruments = to_set
	self.show_instruments()
	self.set_process_input(true)

func _on_LineEdit_text_changed(new_text):
	self.search = new_text.to_upper()
	self.show_instruments()

func matches(instrument):
	if not len(self.search):
		return true

	var search_value = self.search.to_upper().replace("/", "").replace(" ", "")
	var name_to_check = instrument.name.to_upper().replace("/", "").replace("_", "")

	if search_value in name_to_check:
		return true

	var found
	var last_index = 0
	for character in search_value:
		found = name_to_check.find(character, last_index + 1)

		if found < last_index:
			return false

		last_index = found

	return true

func _input(event: InputEvent):
	if not self.visible: return
	if not event is InputEventKey: return

	# Don't multi select the first one
	# only trigger on first press
	if event.is_echo() or not event.is_pressed():
		return

	if event.scancode == KEY_ENTER:
		if not self.search: return Root.hide()
		if not self.visible: return Root.hide()

		if not self.selected:
			self.selected = self.get_item_metadata(0)

		self.select_instrument()

func select_index(index: int):
	self.selected = self.get_item_metadata(index)

	if Input.is_mouse_button_pressed(1):
		self.select_instrument()

func select_instrument():
	if not self.selected:
		return

	self.search = ""
	Root.set_instrument(self.selected)
	Root.hide()

	self.selected = null

func show_instruments():
	self.clear()

	var padded_string = "%4s  %s"

	var count = 0
	for instrument in self.all_instruments:
		if len(self.search):
			if not self.matches(instrument):
				continue

		self.add_item(padded_string % [instrument.name, instrument.displayName])
		self.set_item_metadata(count, instrument)

		count += 1
