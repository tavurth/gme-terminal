extends Control

var Scene = preload("Scene.tscn").instance()

func _ready():
	self.add_child(Scene)

func set_instrument(instrument: String):
	Scene.set_instrument(instrument)

func redraw(_tab):
	if not self.visible: return
	Scene.redraw()
