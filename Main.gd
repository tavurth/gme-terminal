extends Control

signal instrument_set(instrument)

export(String) var instrument setget set_instrument

func set_instrument(new_instrument: String):
	self.emit_signal("instrument_set", new_instrument)
	instrument = new_instrument

func _ready():
	self.emit_signal("instrument_set", instrument)
