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

	return res.replace("-,", "-")

func setup(item: Dictionary):
	$Holder.set_text(item.owner.name)
	$Shares.set_text(format(item.shares.count))
	$FileDate.set_text(str(item.date.current))

	$Change.set_text(format(item.shares.change))
	if item.shares.change > 0:
		$Change.set_modulate(ColorUp)

	elif item.shares.change < 0:
		$Change.set_modulate(ColorDw)

