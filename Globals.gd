extends Node2D

var config := {} setget set_config

func set_config(new_config: Dictionary):
	config = new_config
	Utils.File.write_json("user://config.json", config)
	
func _ready():
	self.config = Utils.File.read_json("user://config.json") or {}

	if not self.config:
		self.config = {
			"api_source": "SEC",
			"instrument": {
				"cik": "1326380",
				"name": "GME"
			}
		}

