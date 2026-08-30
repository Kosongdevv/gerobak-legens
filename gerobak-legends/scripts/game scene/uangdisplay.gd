extends Label

# Script ini ditempel ke node Label
# Otomatis ambil data uang dari GameManager (autoload)

func _ready() -> void:
	# Subscribe ke signal money_changed biar label auto-update
	GameManager.money_changed.connect(_on_money_updated)
	# Panggil sekali di awal biar langsung nampilin nilai saat game dibuka
	_on_money_updated(GameManager.money)


func _on_money_updated(new_money: float) -> void:
	text = format_money(new_money)


# ini buat jadi ada nilai K M B dan T
func format_money(amount: float) -> String:
	var abs_amount = abs(amount)
	var sign_str = "-" if amount < 0 else ""

	if abs_amount < 1000.0:
		var small = snapped(abs_amount, 0.01)
		if small == floor(small):
			return sign_str + str(int(small))
		else:
			return sign_str + str(small)

	var units = ["", "k", "M", "B", "T"]
	var unit_index = 0
	var value = abs_amount

	while value >= 1000.0 and unit_index < units.size() - 1:
		value /= 1000.0
		unit_index += 1
	
	var rounded = snapped(value, 0.1)

	# ini bagian kalo nilainya 1 bukan jadi 1.0
	var value_str: String
	if rounded == floor(rounded):
		value_str = str(int(rounded))
	else:
		value_str = str(rounded)

	return sign_str + value_str + units[unit_index]
