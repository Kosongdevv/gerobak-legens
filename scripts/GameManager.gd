extends Node

# File path penyimpan data di storage lokal HP
const SAVE_PATH := "user://tycoon_savegame.json"

# Signal untuk memperbarui tampilan UI saat ada perubahan
signal stok_changed
signal money_changed(new_amount: float)
signal furniture_changed

# --- VARIABEL UTAMA GAME TYCOON ---

# 7 Slot bahan utama (sesuai request slotnya 7)
var bahan: Dictionary = {
	"stok_bakso": 20,
	"stok_sayur": 20,
	"stock_toge": 20,
	"stok_kecap": 20,
	"stok_saos": 20,
	"stok_bihun": 20,
	"stok_pangsit": 20
}

# Furniture dipisah biar slot bahan gak penuh
var furniture: Dictionary = {
	"kerusi_biasa": 2,
	"meja": 1,
	"kerusi_panjang": 0
}

# Uang & Level (gabungan dari GameManager lama lu)
var money: float = 100.0:
	set(v):
		money = max(0.0, v)
		money_changed.emit(money)

var current_level: int = 1
var income_per_second: float = 0.0 # Gak idle lagi, income dari pelanggan

var menu : Dictionary = {
  "baksobiasa" = 8000.0,
  "baksopedas" = 9000.0,
  "baksokomplit" = 12000.0
}

func _ready() -> void:
	load_game()
	setup_timers()


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
		"pangsit" : 1
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


# --- SISTEM AUTOSAVE (TIMER) ---
func setup_timers() -> void:
	save_timer = Timer.new()
	save_timer.wait_time = 10.0
	save_timer.autostart = true
	save_timer.timeout.connect(save_game)
	add_child(save_timer)

func tambah_stok(id: String, jumlah: int):
	if bahan.has(id):
		bahan[id] += jumlah
		stok_changed.emit()
		save_game()

func beli_furniture(id: String, harga: int) -> bool:
	if money >= harga:
		money -= harga
		if furniture.has(id):
			furniture[id] += 1
		else:
			furniture[id] = 1
		furniture_changed.emit()
		save_game()
		return true
	return false

func get_total_kursi() -> int:
	return furniture.get("kerusi_biasa", 0) + (furniture.get("kerusi_panjang", 0) * 2)


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
		"furniture": furniture
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

		var loaded_furniture: Dictionary = data.get("furniture", {})
		for key in furniture.keys():
			furniture[key] = int(loaded_furniture.get(key, 0))

		print("Data berhasil dimuat!")


# Menyimpan data otomatis saat pemain menekan tombol home / keluar di Android/iOS
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST or what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_game()
