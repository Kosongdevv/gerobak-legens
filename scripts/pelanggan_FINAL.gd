extends CharacterBody2D
# pelanggan.gd - FINAL VERSION for Godot Mobile 4.x
# Pasang di customer.tscn (CharacterBody2D + AnimatedSprite2D + ProgressBar + Timer)
# Sistem Tipe A, B, C sesuai ide lu di Discord: income x1, x2, x1.5

enum TipePelanggan { A_BIASA, B_SULTAN, C_VLOGGER }

@export var tipe: TipePelanggan = TipePelanggan.A_BIASA
@export var move_speed: float = 80.0 # pelanin biar ringan di Android 10

var multiplier: float = 1.0
var patience_max: float = 12.0
var patience: float = 12.0
var bill: int = 0
var is_served: bool = false
var target_meja: Node2D = null

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var bar: ProgressBar = $PatienceBar
@onready var patience_timer: Timer = $PatienceTimer

signal pelanggan_pergi(tipe_pelanggan)
signal pelanggan_puas(income: int, tipe_pelanggan)

func _ready() -> void:
	setup_tipe()
	
	
	if bar:
		bar.max_value = patience_max
		bar.value = patience
	
	if patience_timer:
		patience_timer.wait_time = 0.1
		patience_timer.timeout.connect(_on_patience_tick)
		patience_timer.start()
	
	add_to_group("pelanggan")

func setup_tipe():
	match tipe:
		TipePelanggan.A_BIASA: # 60% spawn - Warga biasa
			multiplier = 1.0
			patience_max = 15.0
			modulate = Color(1, 1, 1)
		TipePelanggan.B_SULTAN: # 15% spawn - Bayar x2
			multiplier = 2.0
			patience_max = 6.0
			modulate = Color(1, 0.9, 0.35) # gold biar keliatan sultan
			move_speed = 100.0
		TipePelanggan.C_VLOGGER: # 25% spawn - Bayar x1.5 + efek reputasi
			multiplier = 1.5
			patience_max = 10.0
			modulate = Color(0.7, 1, 0.7) # hijau muda

func _physics_process(delta: float) -> void:
	if is_served:
		return
	
	# Gerakan simpel ke meja (tanpa NavigationAgent biar ringan)
	if target_meja and global_position.distance_to(target_meja.global_position) > 5.0:
		var dir = global_position.direction_to(target_meja.global_position)
		velocity = dir * move_speed
		move_and_slide()
		# Animasi
		if sprite and dir != Vector2.ZERO:
			if abs(dir.x) > abs(dir.y):
				sprite.play("kekanan" if dir.x > 0 else "kekiri")
			else:
				sprite.play("kebelakang" if dir.y < 0 else "kedepan")
	else:
		velocity = Vector2.ZERO
		if sprite:
			sprite.play("idle")

func _on_patience_tick():
	if is_served:
		return
	patience -= 0.1
	if bar:
		bar.value = patience
		# Warna bar jadi merah kalau mau pergi
		if patience < 3.0:
			bar.modulate = Color(1, 0.3, 0.3)
	
	if patience <= 0:
		pergi_kecewa()

# Dipanggil saat pemain tap pelanggan / klik layani
func layani_pelanggan() -> bool:
	if is_served:
		return false
	
	var final_income = bill
	
	# Bonus sultan
	if tipe == TipePelanggan.B_SULTAN:
		var tips = randi_range(2000, 8000)
		final_income += tips
		print("Sultan kasih tips: ", tips)
	
	GameManager.add_money(final_income)
	pelanggan_puas.emit(final_income, tipe)
	
	# Efek Vlogger
	if tipe == TipePelanggan.C_VLOGGER:
		# Panggil GameManager atau Spawner buat boost
		get_tree().call_group("spawner", "boost_spawn_rate", 2.0, 30.0)
	
	# Animasi hilang
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_callback(queue_free)
	return true

func pergi_kecewa():
	pelanggan_pergi.emit(tipe)
	if tipe == TipePelanggan.C_VLOGGER:
		# Vlogger kecewa = sepi 20 detik
		get_tree().call_group("spawner", "slow_spawn_rate", 0.5, 20.0)
		print("Vlogger kecewa, reputasi turun!")
	queue_free()

# Untuk di-set dari Spawner
func set_target_meja(meja: Node2D):
	target_meja = meja
