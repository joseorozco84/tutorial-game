class_name  Player
extends CharacterBody2D

@onready var heart_sprites: Array = [%Heart1, %Heart2, %Heart3]
@onready var hurt_sound: AudioStreamPlayer2D = $HurtSound  # Asegúrate de que el nodo tenga este nombre
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var jump_sound: AudioStreamPlayer2D = $JumpSound
@onready var double_jump_sound: AudioStreamPlayer2D = $DoubleJumpSound
@onready var death_sound: AudioStreamPlayer2D = $DeathSound
@onready var attack_sound: AudioStreamPlayer2D = $AttackSound
@onready var attack_area: Area2D = $AttackArea  # Un área de ataque (Area2D) que detecta enemigos cerca del personaje


const MAX_HEALTH = 3
const HEARTFILL = preload("res://assets/sprites/heartfill.png")
const HEARTEMPTY = preload("res://assets/sprites/heartempty.png")
var current_health = MAX_HEALTH

var is_attacking: bool = false  # Variable para evitar múltiples ataques simultáneos
const ATTACK_COOLDOWN = 0.5  # Tiempo de enfriamiento entre ataques
var attack_cooldown_timer: float = 0.0  # Temporizador para el enfriamiento



# Lógica para detectar si el ataque golpea a un enemigo
func attack() -> void:
	if not is_attacking and attack_cooldown_timer <= 0:
		is_attacking = true
		attack_sound.play()
		animated_sprite.play("attack")
		attack_cooldown_timer = ATTACK_COOLDOWN  # Empezar el cooldown del ataque
		
		# Verificar si hay enemigos en el área de ataque
		for enemy in attack_area.get_overlapping_bodies():
			if enemy is Enemy:  # Asegúrate de que los enemigos usen una clase llamada 'Enemy'
				enemy.take_damage(3)  # Asumimos que los enemigos tienen una función `take_damage`


# Lógica del daño al personaje
func take_damage(amount: int) -> void:
	current_health = clamp(current_health - amount, 0, MAX_HEALTH)  # Limitar current_health entre 0 y MAX_HEALTH
	if current_health > 0:
		print("You took damage!")
		animated_sprite.play("hit")
		hurt_sound.play()
		update_hearts()
	else:
		print("You died!")
		death_sound.play()
		animated_sprite.play("death")
		# Llamar a la función de cambio de escena con call_deferred
		get_tree().call_deferred("change_scene_to_file", "res://scenes/gameover.tscn")


# Lógica para recuperar vida
func heal(amount: int) -> void:
	current_health = clamp(current_health + amount, 0, MAX_HEALTH)  # Limitar current_health entre 0 y MAX_HEALTH
	update_hearts()

func _on_heart_collected(heart: Node) -> void:
	if current_health < MAX_HEALTH:
		current_health += 1  # Recuperar 1 punto de salud
		print("Vida recuperada!")


# Actualizar los corazones en pantalla
func update_hearts() -> void:
	# Iterar sobre los corazones y actualizar su textura según current_health
	for i in range(MAX_HEALTH):
		if i < current_health:
			heart_sprites[i].texture = HEARTFILL  # Mostrar el corazón lleno
		else:
			heart_sprites[i].texture = HEARTEMPTY  # Mostrar el corazón vacío

## Función para probar el daño y la curación
#func _input(event):
	#if Input.is_action_just_pressed("damage"):
		#take_damage(1)
	#elif Input.is_action_just_pressed("heal"):
		#heal(1)

const SPEED = 50.0
const JUMP_VELOCITY = -200.0
const DASH_SPEED = 150.0
const DASH_DURATION = 0.3
const DASH_COOLDOWN = 0.3
const MAX_JUMPS = 2
const DOUBLE_TAP_TIME = 0.4
const GRAVITY = 600.0
const SLOW_FALL_GRAVITY = 100.0


var jumps_left = MAX_JUMPS
var dash_time = 0.0
var dash_direction = Vector2.ZERO
var dash_cooldown = 0.0

var last_tap_time = 0.0  # Tiempo restante para detectar doble toque
var key_released = true  # Verifica si la tecla ha sido soltada entre pulsaciones

func _physics_process(delta: float) -> void:
	
	# Reducir el cooldown del ataque
	if attack_cooldown_timer > 0:
		attack_cooldown_timer -= delta
	else:
		is_attacking = false
	# Reducir el tiempo del cooldown del dash
	if dash_cooldown > 0:
		dash_cooldown -= delta

	# Actualizar el tiempo de última pulsación
	if last_tap_time > 0:
		last_tap_time -= delta

	# Manejar la gravedad
	if not is_on_floor() and dash_time <= 0:
		# Solo aplicar el "glide" si el personaje está cayendo (velocidad Y positiva)
		if jumps_left <= 1 and velocity.y > 0 and Input.is_action_pressed("jump"):
			velocity.y += SLOW_FALL_GRAVITY * delta
			# Si está en caída lenta, reproducir la animación "glide"
			animated_sprite.play("glide")
		else:
			velocity.y += GRAVITY * delta
	elif is_on_floor():
		jumps_left = MAX_JUMPS

	# Manejar el salto
	if Input.is_action_just_pressed("jump") and jumps_left > 0 and dash_time <= 0:
		velocity.y = JUMP_VELOCITY
		if jumps_left == 2:
			jump_sound.play()
			animated_sprite.play("jump")
		elif jumps_left == 1:
			double_jump_sound.play()
			animated_sprite.play("double_jump")
		jumps_left -= 1

	# Obtener la dirección del input
	var direction := Input.get_axis("move_left", "move_right")
	
	# Manejar el dash
	if direction != 0 and dash_cooldown <= 0 and dash_time <= 0:
		if last_tap_time > 0 and key_released:  # Detecta si el segundo toque fue rápido
			# No permitir dash si se está en caída lenta
			if not (jumps_left == 0 and velocity.y > 0):
				dash_time = DASH_DURATION
				dash_direction = Vector2(direction, 0)
				velocity.x = dash_direction.x * DASH_SPEED
				dash_cooldown = DASH_COOLDOWN
				animated_sprite.play("dash")
				last_tap_time = 0
				key_released = false  # Resetear el estado de la tecla
		elif key_released:  # Si se presionó la tecla, comenzar a contar el tiempo de doble toque
			last_tap_time = DOUBLE_TAP_TIME
			key_released = false  # Indicar que la tecla está presionada
	elif direction == 0:
		key_released = true  # Solo cuando no se mueve, se puede considerar liberada

	# Manejar la duración del dash
	if dash_time > 0:
		dash_time -= delta
		if dash_time <= 0:
			velocity.x = 0
			
	# Llamar a la lógica de dash attack durante el dash
	if dash_time > 0:
		dash_attack(delta)
	else:
		# Movimiento normal si no está en dash
		move_and_slide()
	
	# Voltear el sprite
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true

	# Animaciones si no se está haciendo dash y no está en modo "glide"
	if dash_time <= 0 and not (jumps_left == 0 and velocity.y > 0 and Input.is_action_pressed("jump")):
		if is_on_floor():
			if direction == 0:
				animated_sprite.play("idle")
			else:
				animated_sprite.play("run")
		elif jumps_left < MAX_JUMPS:
			if jumps_left == 1:
				animated_sprite.play("jump")
			elif jumps_left == 0:
				animated_sprite.play("double_jump")

	# Movimiento horizontal si no se está haciendo dash
	if dash_time <= 0:
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

	# Lógica de ataque
	if Input.is_action_just_pressed("attack"):
		attack()
	

	# Aplicar el movimiento
	move_and_slide()


# Detectar colisiones durante el dash
func dash_attack(delta: float) -> void:
	# Verificamos si el dash está activo y movemos al personaje con move_and_collide()
	if dash_time > 0:
		# Mover con colisiones (para detectar colisiones con enemigos)
		var collision = move_and_collide(Vector2(dash_direction.x * DASH_SPEED, velocity.y) * delta)

		if collision:
			# Si la colisión es con un enemigo, le hacemos daño
			if collision.get_collider() is Enemy:
				var enemy = collision.get_collider() as Enemy
				enemy.take_damage(3)  # Asumimos que el daño durante el dash es 3
				print("Enemigo dañado por el dash!")
			
		# Reducir el tiempo del dash
		dash_time -= delta
		if dash_time <= 0:
			velocity.x = 0  # Detener el movimiento horizontal después del dash
