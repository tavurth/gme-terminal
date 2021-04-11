extends Node2D

func handle_error(config: Dictionary, data):
	config.erase("valid_api_key")
	Utils.File.write_json("user://config.json", config)

	if not data:
		return { "error": "Unknown errro" }

	else:
		return data

func validate_api_key(config: Dictionary):
	if "valid_api_key" in config: return

	config.valid_api_key = true
	Utils.File.write_json("user://config.json", config)

