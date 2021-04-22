tool
extends EditorPlugin

func _enter_tree():
	add_custom_type("cs-ftds", "Control", preload("Ftds.gd"), preload("icon.png"))

func _exit_tree():
	remove_custom_type("cs-ftds")
