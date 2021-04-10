tool
extends EditorPlugin

func _enter_tree():
	add_custom_type("FocusWatcher", "Node2D", preload("FocusWatcher.gd"), preload("icon.png"))
	add_custom_type("HttpFetch", "Node2D", preload("Http.gd"), preload("icon.png"))

func _exit_tree():
	remove_custom_type("FocusWatcher")
	remove_custom_type("HttpFetch")
