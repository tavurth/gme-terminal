tool
extends EditorPlugin

func _enter_tree():
	add_custom_type("cs-Insiders", "CanvasLayer", preload("Insiders.gd"), preload("icon.png"))

func _exit_tree():
	remove_custom_type("cs-Insiders")
