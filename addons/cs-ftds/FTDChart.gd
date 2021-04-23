extends HBoxContainer

var FtdBar = preload("Ftd.tscn")

func reset():
	for child in self.get_children():
		child.queue_free()

func redraw(ftds: Array):
	self.reset()

	var ymax = -INF
	for i in ftds:
		ymax = max(ymax, float(i.quantity))

	for i in ftds:
		i.quantity /= ymax

	var to_add
	for ftd in ftds:
		to_add = FtdBar.instance()

		to_add.value = ftd.quantity * 100

		self.add_child(to_add)
