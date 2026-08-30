extends Button

@export var base_cost: float = 10.0
@export var cost_multiplier: float = 1.5
@export var income_boost: float = 2.0

var current_cost: float


func _ready() -> void:
	_update_cost_and_ui()
	pressed.connect(_on_upgrade_pressed)


func _update_cost_and_ui() -> void:
	current_cost = base_cost * pow(cost_multiplier, GameManager.current_level - 1)
	text = "Upgrade Bisnis (Biaya: $" + str(snapped(current_cost, 0.01)) + ")"


func _on_upgrade_pressed() -> void:
	if GameManager.spend_money(current_cost):
		GameManager.income_per_second += income_boost
		GameManager.current_level += 1
		_update_cost_and_ui()

		print("Upgrade Berhasil! Pendapatan sekarang: $", GameManager.income_per_second, "/s")
	else:
		text = "Uang Tidak Cukup!"

		await get_tree().create_timer(1.0).timeout

		if is_inside_tree():
			_update_cost_and_ui()
