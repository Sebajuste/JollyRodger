extends Object

export(float) var min_height_threshold := 0
export(float) var max_height_threshold := 1000
export(float, 0.0, 1.0) var amount_on_slope := 0.0
export(float, 0.0, 1.0) var amount_on_flat := 1.0

func get_amount(slope : float, hight : float) -> float:
	var amount : float = 1.0
	if hight < min_height_threshold or hight > max_height_threshold:
		amount = 0.0
	else:
		amount = clamp((1.0 - slope) * amount_on_slope, 0.0, 1.0)
		amount = clamp(amount + slope * amount_on_flat, 0.0, 1.0)
	return amount
