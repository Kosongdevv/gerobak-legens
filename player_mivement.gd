extends CharacterBody2D
@export var speed: float = 300.0
@export var accel: float = 1500.0
@export var friction: float = 1200

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	var input_vector: Vector2 = Input.get_vector("ui_kiri","ui_kanan","ui_depan(atas)","ui_belakang(bawah)")
	
	if input_vector !=Vector2.ZERO:
		input_vector = input_vector.normalized()
		velocity = velocity.move_toward(input_vector * speed, accel * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
			
	move_and_slide()
	update_animation(input_vector)
	
func update_animation(input_vector: Vector2) -> void:
	if input_vector != Vector2.ZERO:
		
		if abs(input_vector.x) >= abs(input_vector.y):
			if input_vector.x > 0:
				animated_sprite.play("kekiri")
			else:
				animated_sprite.play("kekanan")
		else:
			if input_vector.y > 0:
				animated_sprite.play("kedepan")
			else:
				animated_sprite.play("kebelakang")
	else:
		animated_sprite.play("idle")
# test movement git
