extends Node2D


const sandbox_url = "https://sandbox.iexapis.com/stable/stock/{instrument}/institutional-ownership?token={api_key}"
const request_url = "https://cloud.iexapis.com/stable/stock/{instrument}/institutional-ownership?token={api_key}"

func extract_item(item: Dictionary):
	return {
		"ticker": item.symbol,
		"holder": item.entityProperName.lstrip(" ").rstrip(" "),
		"shares": item.reportedHolding,
		"shares_change": item.adjMv,
		"shares_pct_change": round((item.adjMv / item.adjHolding) * 1000) / 10,
		"date": item.filingDate
	}

func extract_data(data: Array):
	var to_return = []

	for item in data:
		to_return.append(self.extract_item(item))

	return to_return

func fetch(config: Dictionary, instrument: String):
	yield(get_tree(), "idle_frame")

	var data = $HttpFetch.fetch(request_url.format({
		"instrument": instrument,
		"api_key": config.api_key
	}))

	data = yield(data, "completed")

	if not data or "error" in data:
		return data

	data = self.extract_data(data)

	if not data:
		return data

	return data
