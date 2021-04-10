extends Reference

func load_json(filename, compression = -1):
	var input_file = File.new()
	var err

	if compression < 0:
		err = input_file.open(filename, File.READ)

	else:
		err = input_file.open_compressed(filename, File.READ, compression)

	if err != OK:
		push_error(filename + " " + Errors.string_name(err))
		return null

	var data = parse_json(input_file.get_as_text())
	input_file.close()
	return data

func write_json(filename, data, compression = -1):
	var input_file = File.new()
	var err

	if compression < 0:
		err = input_file.open(filename, File.WRITE)

	else:
		err = input_file.open_compressed(filename, File.WRITE, compression)

	if err != OK:
		push_error(filename + " " + Errors.string_name(err))
		return null

	input_file.store_string(JSON.print(data))
	input_file.close()
