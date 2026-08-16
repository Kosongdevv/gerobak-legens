extends Label

func _ready() -> void:
	# Menghubungkan signal money_changed agar UI otomatis update saat uang berubah
	GameManager.money_changed.connect(_on_money_updated)
	_on_money_updated(GameManager.money)

func _on_money_updated(new_money: float) -> void:
	# Menampilkan uang dengan pembulatan 2 angka di belakang koma (Format Uang)
	text = "Uang: $" + str(snapped(new_money, 0.01))
