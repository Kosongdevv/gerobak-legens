extends Node2D

#informasi script
#saat ini ada script penambah uang
#dan membuka ui gerobak 

@onready var interact : TouchScreenButton = $CharacterBody2D/CanvasLayer/interact
var entered_gerobak : bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function b
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_interact") and entered_gerobak:
		get_tree().change_scene_to_file("res://scenes/cooking.tscn")
	pass


func _on_add_monwy_pressed() -> void:
	print("kepencet")
	GameManager.money += 100000
	pass # Replace with function body.
	
	
	


func _on_areagerobak_body_entered(_body: Node2D) -> void: # jika player ada disekitaran gerobak
	interact.visible = true # munculin tombol interact sama var entered gerobak aktif
	entered_gerobak = true
	pass # Replace with function body.


func _on_areagerobak_body_exited(_body: Node2D) -> void:
	interact.visible = false # sama aja cuman yang ini matiin
	entered_gerobak = false
	pass # Replace with function body.


func _on_add_stock_pressed() -> void:
	for a in GameManager.bahan:
		GameManager.bahan[a] += 10
	pass # Replace with function body.
