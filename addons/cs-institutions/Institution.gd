extends HBoxContainer

const ColorUp = Color(0.1, 0.9, 0.1)
const ColorDw = Color(0.9, 0.1, 0.1)

func format_float(value: float) -> String:
	# Convert value to string.
	var str_value: String = str(value)

	# Check if the value is positive or negative.
	# Use index 0(excluded) if positive to avoid comma at the beginning.
	# Use index 1(excluded) if negative to avoid comma after the - sign.
	var loop_end: int = 0 if value > -0.001 else 1

	# Set default value to 3 since commas has interval of 3.
	var loop_start: int = 3

	# Look for the decimal point by looping backward.
	# Use this when the characters of the decimal part
	# are lower than the whole number part.
	for i in range(str_value.length()-1, -1, -1):
		if str_value[i] == ".":
			loop_start += (str_value.length() - i)
			break;

	# Loop to look for the decimal point.
	# Use this when the characters of the decimal part
	# are more than the whole number part.
#	for i in str_value.length():
#		if str_value[i] == ".":
#			loop_start += (str_value.length() - i)
#			break;

	# Loop backward starting at the last 3 digits of the whole number,
	# add comma then, repeat every 3rd step.
	for i in range(str_value.length()-loop_start, loop_end, -3):
		str_value = str_value.insert(i, ",")

	# Return the formatted string.
	return str_value

func format_int(value: int) -> String:
	# Convert value to string.
	var str_value: String = str(value)

	# Check if the value is positive or negative.
	# Use index 0(excluded) if positive to avoid comma before the 1st digit.
	# Use index 1(excluded) if negative to avoid comma after the - sign.
	var loop_end: int = 0 if value > -1 else 1

	# Loop backward starting at the last 3 digits,
	# add comma then, repeat every 3rd step.
	for i in range(str_value.length()-3, loop_end, -3):
		str_value = str_value.insert(i, ",")

	# Return the formatted string.
	return str_value

func format_with_color(node: Node, amount: float, amount_str = null):
	if not amount_str:
		amount_str = format_int(int(amount))

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
	$Shares.set_text(format_int(item.shares))
	$FileDate.set_text(str(item.date))

	self.format_with_color($Change, item.shares_change)
	self.format_with_color($ChangePct, item.shares_pct_change, format_float(item.shares_pct_change))
