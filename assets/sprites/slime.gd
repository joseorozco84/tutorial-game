class_name Enemy
extends CharacterBody2D

# Constantes
const SPEED = 20  # Velocidad de movimiento horizontal
const GRAVITY = 500  # Intensidad de la gravedad
const MAX_FALL_SPEED = 400  # Velocidad máxima de caída
const MAX_HEALTH = 3  # Salud máxima
const KNOCKBACK_FORCE = 100  # Fuerza de retroceso cuando recibe daño
const KNOCKBACK_JUMP = -200  # Impulso hacia arriba cuando recibe daño
const KNOCKBACK_DURATION = 0.2  # Duración del retroceso

# Variables
var current_health = MAX_HEALTH
var direction = 1  # Dirección de movimiento (1 = derecha, -1 = izquierda)
var is_dead = false  # Control de si el enemigo está muerto
var is_knockback = false  # Control del estado de knockback
var knockback_time = 0  # Temporizador para controlar la duración del knockback
var signal_connected = false  # Control de conexión de señales

# Nodos
@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer: Timer = $Timer
@onready var killzone: Area2D = $Killzone
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

# Conectar señales importantes al iniciar el juego
func _ready() -> void:
	if not signal_connected:
		_connect_signals()
		signal_connected = true

# Conectar señales de animaciones y del temporizador
func _connect_signals() -> void:
	print("Connecting signals...")

	if not animated_sprite.is_connected("animation_finished", Callable(self, "_on_animation_finished")):
		animated_sprite.connect("animation_finished", Callable(self, "_on_animation_finished"))

	if not timer.is_connected("timeout", Callable(self, "_on_timer_timeout")):
		timer.connect("timeout", Callable(self, "_on_timer_timeout"))

	print("Signals connected!")


# Función para manejar cuando una animación termina
func _on_animation_finished() -> void:
	if animated_sprite.animation == "death":
		_start_death_timer()

# Iniciar el temporizador para eliminar el Slime después de la animación
func _start_death_timer() -> void:
	timer.start(1.0)  # Esperar 1 segundo antes de eliminar el Slime

# Función para eliminar el Slime cuando el temporizador se agota
func _on_timer_timeout() -> void:
	print("Removing Slime...")
	queue_free()  # Eliminar el nodo Slime

# Lógica para aplicar daño al Slime
func take_damage(amount: int) -> void:
	if is_dead or is_knockback:
		return  # Si ya está muerto o en knockback, no hacer nada
	
	_reduce_health(amount)

	if current_health > 0:
		_on_hit()
	else:
		_on_death()

# Reducir la salud del Slime
func _reduce_health(amount: int) -> void:
	current_health = clamp(current_health - amount, 0, MAX_HEALTH)  # Limitar entre 0 y MAX_HEALTH

# Comportamiento cuando el Slime es golpeado
func _on_hit() -> void:
	print("Slime took damage!")
	_apply_knockback()  # Aplica el retroceso cuando recibe daño
	animated_sprite.play("hit")

# Aplicar el retroceso y el pequeño salto hacia atrás
func _apply_knockback() -> void:
	is_knockback = true
	knockback_time = KNOCKBACK_DURATION  # Iniciar temporizador de knockback
	velocity.x = -direction * KNOCKBACK_FORCE  # Retroceso en la dirección opuesta
	velocity.y = KNOCKBACK_JUMP  # Pequeño salto hacia arriba

# Comportamiento cuando el Slime muere
func _on_death() -> void:
	is_dead = true  # Marcar como muerto
	print("Slime died!")
	_disable_collision()
	animated_sprite.play("death")  # Reproducir animación de muerte

# Desactivar las colisiones del Slime cuando muere
func _disable_collision() -> void:
	collision_shape_2d.queue_free()
	killzone.queue_free()
	velocity = Vector2.ZERO  # Detener cualquier movimiento

# Lógica principal de movimiento y colisiones
func _physics_process(delta: float) -> void:
	if is_dead:
		return  # No hacer nada si está muerto
	
	_apply_gravity(delta)
	_limit_fall_speed()

	# Controlar el knockback si está activo
	if is_knockback:
		knockback_time -= delta
		if knockback_time <= 0:
			is_knockback = false  # Finaliza el knockback
	else:
		_handle_direction_change()  # Cambiar dirección si no está en knockback
		_move_enemy()  # Mover al enemigo si no está en knockback

# Aplicar gravedad al Slime si no está en el suelo
func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		velocity.y = 0

# Limitar la velocidad de caída para que no caiga demasiado rápido
func _limit_fall_speed() -> void:
	if velocity.y > MAX_FALL_SPEED:
		velocity.y = MAX_FALL_SPEED

# Cambiar la dirección del movimiento si hay colisiones con los raycasts
func _handle_direction_change() -> void:
	if ray_cast_right.is_colliding():
		_change_direction(-1)
	elif ray_cast_left.is_colliding():
		_change_direction(1)

# Cambiar la dirección y actualizar la animación
func _change_direction(new_direction: int) -> void:
	direction = new_direction
	animated_sprite.flip_h = (direction == -1)

# Mover al Slime y aplicar la velocidad
func _move_enemy() -> void:
	velocity.x = direction * SPEED
	move_and_slide()  # Mover al enemigo basado en su velocidad actual

	# Si se está moviendo horizontalmente, reproducir la animación de "walk"
	if velocity.x != 0:
		animated_sprite.play("walk")
	else:
		animated_sprite.play("idle")  # Si no se mueve, reproducir "idle"
