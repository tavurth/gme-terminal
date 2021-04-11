extends ColorRect

onready var bar = $"HBoxContainer/VBoxContainer/ProgressBar"

func _ready():
	bar.value = 0
	self.set_process(true)

func _process(delta):
	bar.value += 50 * delta

	if bar.value > 110:
		bar.value = 0

func show():
	.show()
	self.set_process(true)

func hide():
	.hide()
	bar.value = 0
	self.set_process(false)
