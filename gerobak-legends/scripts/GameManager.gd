extends Node

# File path penyimpan data di storage lokal HP
const SAVE_PATH := "user://tycoon_savegame.json"

# Signal untuk memperbarui tampilan UI saat uang berubah
signal money_changed(new_amount: float)

# --- VARIABEL UTAMA GAME TYCOON ---
var money: float = 0.0:
	set(value):
		money = max(0.0, value) # Memastikan uang tidak minus
		money_changed.emit(money)

var current_level: int = 1

# Dictionary bahan-bahan (stok), semua nilainya bertipe int
var bahan: Dictionary = {
	"kecap": 0,
	"saos": 0,
	"bakso": 0,
	"bihun": 0,
	"sawi": 0,
	"toge": 0,
	"pangsit": 0,
}



# --- Variabel Resep ---
var resep : Dictionary = {
  "baksobiasa" : {
	"bakso" : 4,
		"sawi" : 2,
		"toge" : 1
	},
	"baksopedas" : {
	  "bakso" : 4,
		"sawi"  : 2,
		"toge"  : 1,
		"saos"  : 1,
	},
	"baksokomplit" : {
	   "bakso" : 5,
		 "sawi" : 2,
		 "toge" : 1,
		 "saos" : 1,
		 "kecap": 1,
		 "bihun": 1,
		 "pangsit": 2
	}

}


# --variabel jumlah bakso-- 
var bakso = {
 "baksobiasa" : 0,
 "baksopedas" : 0,
 "baksokomplit": 0
}


# Timer autosave
var save_timer: Timer


func _ready() -> void:
	load_game()    # Muat data lama saat game dibuka
	setup_timers()  # Jalankan autosave berkala


# --- SISTEM AUTOSAVE (TIMER) ---
func setup_timers() -> void:
	save_timer = Timer.new()
	save_timer.wait_time = 10.0
	save_timer.autostart = true
	save_timer.timeout.connect(save_game)
	add_child(save_timer)


# --- FUNGSI UTAMA UANG ---
func add_money(amount: float) -> void:
	money += amount


func spend_money(amount: float) -> bool:
	if money >= amount:
		money -= amount
		return true # Transaksi sukses
	return false # Uang tidak cukup


# --- SISTEM SAVE & LOAD (FORMAT JSON) ---
func save_game() -> void:
	var save_data := {
		"money": money,
		"current_level": current_level,
		"bahan": bahan,
		"bakso": bakso,
	}

	# Membuka file dengan mode WRITE untuk menimpa data lama
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data))
		file.close()
		print("Game berhasil disimpan otomatis!")


func load_game() -> void:
	# Periksa apakah file save sudah ada di HP
	if not FileAccess.file_exists(SAVE_PATH):
		print("Tidak ada save data lama. Memulai game baru.")
		return

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return

	var json_string := file.get_as_text()
	file.close()

	var json := JSON.new()
	var parse_result := json.parse(json_string)

	if parse_result == OK:
		var data: Dictionary = json.get_data()
		money = data.get("money", 0.0)
		current_level = data.get("current_level", 1)

		var loaded_bahan: Dictionary = data.get("bahan", {})
		for key in bahan.keys():
			bahan[key] = int(loaded_bahan.get(key, 0))

		var loaded_bakso: Dictionary = data.get("bakso", {})
		for key in bakso.keys():
			bakso[key] = int(loaded_bakso.get(key, 0))

		print("Data berhasil dimuat!")


# Menyimpan data otomatis saat pemain menekan tombol home / keluar di Android/iOS
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST or what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_game()
