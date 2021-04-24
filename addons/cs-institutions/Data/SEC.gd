extends Node2D

var Filing = preload("Filing.gd").new()

func _ready():
	self.add_child(Filing)

func beneficial(filing: Dictionary):
	yield(get_tree(), "idle_frame")

	match filing.title:
		"Statement of acquisition of beneficial ownership by individuals":
			return yield(Filing.read_13D(filing.url), "completed")
		"Statement of acquisition of beneficial ownership by individuals - amended":
			pass
		"General statement of acquisition of beneficial ownership":
			pass
		"General statement of acquisition of beneficial ownership - amended":
			pass

	return null

func fetch(instrument: Dictionary):
	yield(get_tree(), 'idle_frame')

	var filings
	if not Cache.has('FILINGS'):
		filings = yield(Filing.fetch_rss(instrument), "completed")
		Cache.set("FILINGS", filings)

	else:
		filings = Cache.get("FILINGS")

	var to_return = []

	for filing in filings:
		if "statement of acquisition of beneficial ownership" in filing.title.to_lower():
			var result = yield(beneficial(filing), "completed")
			if result:
				to_return.append(result)

	return to_return