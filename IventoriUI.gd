extends Control

@onready var grid: GridContainer = $GridContainer

func _ready() -> void:
	InventoriManager.inventory_updated.connect(update_ui)
	update_ui()

func update_ui() -> void:
	var slots = grid.get_children()
	for i in range(slots.size()):
		if i < InventoriManager.items.size():
			slots[i].set_slot(InventoriManager.items[i])
