extends Node2D

@onready var baksob = GameManager.resep["baksobiasa"]
@onready var bahan = GameManager.bahan
@onready var baksop = GameManager.resep["baksopedas"]
@onready var baksok = GameManager.resep["baksokomplit"]

var waktutunggu : float = 3.0

func mbaksok() -> bool:
	for item in baksok:
		if bahan[item] < baksok[item]:
			print("bahan kurang !!")
			return false
		
	$selection.visible = false
	for item in baksok:
		bahan[item] -= baksok[item]
	await get_tree().create_timer(waktutunggu).timeout
	$selection.visible = true
	GameManager.bakso["baksokomplit"] += 1
	return true


func mbaksop() -> bool:
	for item in baksop:
		if bahan[item] < baksop[item]:
			print("bahan kurang")
			return false

	$selection.visible = false
	for item in baksop:
		bahan[item] -= baksop[item]
	await get_tree().create_timer(waktutunggu).timeout
	$selection.visible = true
	GameManager.bakso["baksopedas"] += 1
	return true


func mbaksob() -> bool:
	for item in baksob:
		if bahan[item] < baksob[item]:
			print("bahan kurang!!")
			return false
	
	$selection.visible = false # ngilangin ui pilihan
	for item in baksob:
		bahan[item] -= baksob[item]
	await get_tree().create_timer(waktutunggu).timeout
	$selection.visible = true
	GameManager.bakso["baksobiasa"] += 1
	return true
			


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$Label.text = str(GameManager.bahan) + "\n" + str(GameManager.bakso)
	pass
	
	


func _on_baksobiasa_tekan() -> void:
	mbaksob()
	pass # Replace with function body.


func _on_baksopedas_tekan() -> void:
	mbaksop()
	pass # Replace with function body.


func _on_baksokomplit_tekan() -> void:
	mbaksok()
	pass # Replace with function body.


func _on_quit_press() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")
	pass # Replace with function body.
