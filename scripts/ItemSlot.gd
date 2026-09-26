extends Button

@onready var icon_texture: TextureRect = $TextureRect
@onready var count_label: Label = $Label

func set_slot(item_info) -> void:
	if item_info == null:
		icon_texture.texture = null
		count_label.text = ""
		visible = false
	else:
		var data: ItemData = item_info["data"]
		icon_texture.texture = data.icon
		count_label.text = str(item_info["count"]) if data.stackable else ""
		visible = true
