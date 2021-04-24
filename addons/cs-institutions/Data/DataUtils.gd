extends Node2D

func handle_error(data):
	if not data:
		return { "error": "Unknown errro" }

	else:
		return data


