extends Node

# Signal untuk memberitahu UI supaya mengemaskini paparan
signal inventory_updated

# Kapasiti maksimum slot inventori
@export var capacity: int = 30

# Array untuk menyimpan data barang
var items: Array = []

func _ready() -> void:
	# Isi array dengan nilai null mengikut jumlah kapasiti
	items.resize(capacity)

func add_item(item_data: ItemData,amount: int = 1) -> bool:
	# 1. Jika barang boleh bertindih (stackable), cari slot yang sudah ada barang sama
	if item_data.stackable:
		for slot in items:
			if slot != null and slot["data"] == item_data:
				slot["count"] += amount
				inventory_updated.emit()
				return true

	# 2. Cari slot kosong pertama (nilai null)
	for i in range(items.size()):
		if items[i] == null:
			items[i] = {"data": item_data, "count": amount}
			inventory_updated.emit()
			return true

	# 3. Jika tiada slot kosong (Inventori Penuh)
	print("Inventori penuh!")
	return false

func remove_item(index: int) -> void:
	if index >= 0 and index < items.size():
		items[index] = null
		inventory_updated.emit()
 
