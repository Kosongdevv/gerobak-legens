extends Node

# File path penyimpan data di storage lokal HP
const SAVE_PATH = "user://tycoon_savegame.json"

# Signal untuk memperbarui tampilan UI saat uang berubah
signal money_changed(new_amount: float)

# Variabel Utama Game Tycoon
var money: float = 0.0:
	set(value):
		money = max(0.0, value) # Memastikan uang tidak minus
		money_changed.emit(money)

var income_per_second: float = 1.0
var current_level: int = 1

# Timer otomatis untuk sistem pendapatan (Idle Income) dan Autosave
var income_timer: Timer
var save_timer: Timer

func _ready() -> void:
	load_game()          # Muat data lama saat game dibuka
	setup_timers()       # Jalankan penghitung waktu otomatis

# --- SISTEM IDLE INCOME & AUTOSAVE TIMERS ---
func setup_timers() -> void:
	# Timer Pendapatan: Menambah uang setiap 1 detik
	income_timer = Timer.new()
	income_timer.wait_time = 1.0
	income_timer.autostart = true
	income_timer.timeout.connect(_on_income_tick)
	add_child(income_timer)
	
	# Timer Autosave: Menyimpan otomatis ke HP setiap 10 detik
	save_timer = Timer.new()
	save_timer.wait_time = 10.0
	save_timer.autostart = true
	save_timer.timeout.connect(save_game)
	add_child(save_timer)

func _on_income_tick() -> void:
	money += income_per_second

# --- FUNGSI UTAMA UPGRADE & UANG ---
func add_money(amount: float) -> void:
	money += amount

func spend_money(amount: float) -> bool:
	if money >= amount:
		money -= amount
		return true # Transaksi sukses
	return false # Uang tidak cukup

# --- SISTEM AUTOSAVE & LOAD (FORMAT JSON) ---
func save_game() -> void:
	var save_data = {
		"money": money,
		"income_per_second": income_per_second,
		"current_level": current_level
	}
	
	# Membuka file dengan mode WRITE untuk menimpa data lama
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(save_data)
		file.store_string(json_string)
		file.close()
		print("Game Berhasil Disimpan Otomatis!")

func load_game() -> void:
	# Periksa apakah file save sudah ada di HP
	if not FileAccess.file_exists(SAVE_PATH):
		print("Tidak ada save data lama. Memulai game baru.")
		return
		
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		
		if parse_result == OK:
			var data = json.get_data()
			# Memasukkan kembali data ke dalam variabel game
			money = data.get("money", 0.0)
			income_per_second = data.get("income_per_second", 1.0)
			current_level = data.get("current_level", 1)
			print("Data Berhasil Dimuat!")

# Menyimpan data otomatis saat pemain menekan tombol home / keluar di Android/iOS
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST or what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_game()
