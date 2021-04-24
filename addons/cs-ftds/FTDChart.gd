extends MarginContainer

var FtdBar = preload("Ftd.tscn")

func reset():
	for child in $HBoxContainer.get_children():
		child.queue_free()

func redraw(ftds: Array):
	self.reset()

	print(len(ftds))

	var ymax = -INF
	for i in ftds:
		ymax = max(ymax, float(i.quantity))

	for i in ftds:
		i.quantity /= ymax

	var to_add
	for ftd in ftds:
		to_add = FtdBar.instance()

		to_add.get_node("Bar").value = ftd.quantity * 100
		to_add.get_node("Label").text = str(ftd.settlement)

		$HBoxContainer.add_child(to_add)
