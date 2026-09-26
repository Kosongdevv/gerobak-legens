extends Control
# MainMenu
# Menangani tombol menu utama (Play / Quit) sekaligus
# sistem reset / restart data save game.
#
# Catatan: script ini mengasumsikan GameManager sudah di-set
# sebagai Autoload (Singleton) di Project Settings, sehingga
# bisa diakses lewat nama global "GameManager".

signal save_reset


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_resetbutoon_pressed() -> void:
	reset_save()


# --- SISTEM RESET SAVE ---

# Menghapus file save dari storage dan mengembalikan variabel
# game ke kondisi awal (baru).
func reset_save() -> void:
	_delete_save_file()
	_reset_game_state()
	save_reset.emit()
	print("Save data berhasil direset. Game dimulai dari awal.")


func _delete_save_file() -> void:
	if FileAccess.file_exists(GameManager.SAVE_PATH):
		var dir := DirAccess.open("user://")
		if dir:
			dir.remove(GameManager.SAVE_PATH.get_file())


func _reset_game_state() -> void:
	GameManager.money = 0.0
	GameManager.current_level = 1

	for key in GameManager.bahan.keys():
		GameManager.bahan[key] = 0

	for key in GameManager.bakso.keys():
		GameManager.bakso[key] = 0

	GameManager.save_game() # Langsung simpan kondisi awal ya
