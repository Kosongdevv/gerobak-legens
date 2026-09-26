extends Area2D

# Tarik fail Resource ItemData (contoh: Daging.tres) ke slot ini di Inspector
@export var item_data: ItemData
@export var amount: int = 1

@onready var sprite_2d: Sprite2D = $Sprite2D

func _ready() -> void:
	# Sambungkan signal apabila ada node lain masuk ke kawasan Area2D ini
	body_entered.connect(_on_body_entered)
	
	# Paparkan ikon barang mengikut Resource ItemData
	if item_data and item_data.icon:
		sprite_2d.texture = item_data.icon

func _on_body_entered(body: Node2D) -> void:
	# Pastikan node yang menyentuh barang adalah Player (boleh guna Group atau Nama)
	if body.is_in_group("player") or body.name == "Player":
		# Masukkan barang ke dalam InventoryManager (Autoload)
		var success: bool = InventoriManager.add_item(item_data, amount)
		
		# Jika inventori belum penuh dan barang berjaya ditambah, padam barang dari map
		if success:
			queue_free()
