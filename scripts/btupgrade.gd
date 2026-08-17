extends Button

@export var base_cost: float = 10.0
@export var cost_multiplier: float = 1.5
@export var income_boost: float = 2.0

var current_cost: float

func _ready() -> void:
	_update_cost_and_ui()
	# Hubungkan fungsi saat tombol ditekan
	pressed.connect(_on_upgrade_pressed)

func _update_cost_and_ui() -> void:
	# Biaya naik secara eksponensial khas game tycoon
	current_cost = base_cost * pow(cost_multiplier, GameManager.current_level - 1)
	text = "Upgrade Bisnis (Biaya: $" + str(snapped(current_cost, 0.01)) + ")"

func _on_upgrade_pressed() -> void:
	# Memanggil fungsi spend_money dari Singleton GameManager
	if GameManager.spend_money(current_cost):
		GameManager.income_per_second += income_boost
		GameManager.current_level += 1
		_update_cost_and_ui()
		print("Upgrade Berhasil! Pendapatan sekarang: $", GameManager.income_per_second, "/s")
	else:
		text = "Uang Tidak Cukup!"
		await get_tree().create_timer(1.0).timeout
		_update_cost_and_ui()

