extends HTTPRequest

func _ready():
	set_download_chunk_size(16777216)
