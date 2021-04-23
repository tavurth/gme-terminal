extends HBoxContainer

const ColorUp = Color(0.1, 0.9, 0.1)
const ColorDw = Color(0.9, 0.1, 0.1)

func format_with_color(node: Node, amount: float, amount_str = null):
	if not amount_str:
		amount_str = Utils.Data.format_int(int(amount))

	if amount > 0:
		node.set_text("+" + amount_str)
		node.set_modulate(ColorUp)

	elif amount < 0:
		node.set_text(amount_str)
		node.set_modulate(ColorDw)

	else:
		node.set_text("0")

func setup(item: Dictionary):
	$Holder.set_text(item.holder)
	$Shares.set_text(Utils.Data.format_int(item.shares))
	$FileDate.set_text(str(item.date))

	self.format_with_color($Change, item.shares_change)
	self.format_with_color($ChangePct, item.shares_pct_change, Utils.Data.format_float(item.shares_pct_change))
