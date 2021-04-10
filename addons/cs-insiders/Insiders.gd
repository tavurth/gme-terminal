extends CanvasLayer

var Data = preload("Data.tscn").instance()
var Scene = preload("Scene.tscn").instance()

var instrument

func _ready():
	self.add_child(Data)
	self.add_child(Scene)

	Data.connect("failed", Scene, "_on_failed")
	Data.connect("loaded", Scene, "_on_loaded")
	Data.connect("loading", Scene, "_on_loading")

func set_instrument(new_instrument: String):
	self.instrument = new_instrument
	Data.fetch(new_instrument)
