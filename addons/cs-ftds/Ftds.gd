extends Control

var Scene = preload("Scene.tscn").instance()

func _ready():
	self.add_child(Scene)

