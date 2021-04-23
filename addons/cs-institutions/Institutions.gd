extends Control

var Data = preload("Data/Data.tscn").instance()
var Scene = preload("Scene.tscn").instance()

var instrument

func _ready():
	self.add_child(Data)
	self.add_child(Scene)

	Data.connect("failed", Scene, "_on_failed")
	Data.connect("loaded", Scene, "_on_loaded")
	Data.connect("loading", Scene, "_on_loading")

	Scene.connect("instrument_set", self, "_on_instrument")

func set_instrument(new_instrument: String):
	self.instrument = new_instrument

	if not self.visible: return
	Data.fetch(new_instrument)

func redraw(tab):
	if not self.visible: return
	Data.fetch(self.instrument)
