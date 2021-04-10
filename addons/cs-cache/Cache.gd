extends Node2D

const EXPIRY = 86400 # One day

# var cache_item = {
# 	"touches": int,
# 	"value": Object,
# 	"updated": int,
# 	"expires": int
# }
var CACHE = {}

func load_cache():
	var data = Utils.File.load_json("user://cache.json", File.COMPRESSION_ZSTD)
	if not data:
		return

	CACHE = data

func save_cache():
	var data = Utils.File.write_json("user://cache.json", CACHE, File.COMPRESSION_ZSTD)

func shake_cache():
	for key in CACHE:
		var item = CACHE[key]

		if expired(item):
			CACHE.erase(key)

func expired(item: Dictionary):
	return OS.get_unix_time() > item.expires

func touches(name):
	if not name in CACHE: return 0
	if not "touches" in CACHE[name]: return 0

	return CACHE[name].touches

func get(name):
	if not name in CACHE:
		return null

	var item = CACHE[name]
	if not item:
		return null

	# Keep track of how many reads
	CACHE[name].touches = touches(name) + 1

	# Cleanup the item if it's expired
	if expired(item):
		CACHE.erase(name)
		return null

	return item.value

func has(name):
	if not name in CACHE:
		return false

	return self.get(name) != null

func set(name, value, expiry = EXPIRY):
	CACHE[name] = {
		"value": value,
		"updated": OS.get_unix_time(),
		"touches": self.touches(name) + 1,
		"expires": OS.get_unix_time() + expiry,
	}

	self.save_cache()

func _init():
	self.load_cache()
	self.shake_cache()
