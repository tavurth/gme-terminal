extends HBoxContainer

const ColorUp = Color(0.1, 0.9, 0.1)
const ColorDw = Color(0.9, 0.1, 0.1)

static func format(number):
	var string = str(number)
	var mod = string.length() % 3
	var res = ""

	for i in range(0, string.length()):
		if i != 0 && i % 3 == mod:
			res += ","
		res += string[i]

	res = res.replace("-,", "-")
	res = res.replace(",.", ".")
	res = res.replace(".,", ".")

	return res

func format_with_color(node: Node, amount: float, amount_str = null):
	if not amount_str:
		amount_str = format(amount)

	node.set_text(amount_str)

	if amount > 0:
		node.set_modulate(ColorUp)

	elif amount < 0:
		node.set_modulate(ColorDw)

func setup(item: Dictionary):
	$Holder.set_text(item.owner.name)
	$Shares.set_text(format(item.shares.count))
	$FileDate.set_text(str(item.date.current))

	self.format_with_color($Change, item.shares.change)
	self.format_with_color($ChangePct, item.shares.pct_change, "%.1f" % item.shares.pct_change)
