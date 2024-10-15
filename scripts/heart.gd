class_name Heart
extends Area2D

@onready var animated_sprite: Sprite2D = $Sprite2D  # Asegúrate de que este sea el nombre correcto del nodo
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

# Variables de animación
var initial_position: Vector2
var jump_height: float = -20.0  # Altura del salto


func _ready() -> void:
	#$AnimationPlayer.play("heart_idle")
	initial_position = position
	
	# Iniciar la animación del salto
	animate_jump()

# Cuando el jugador toca el corazón, se emite una señal
func _on_body_entered(body: CharacterBody2D) -> void:
	print(body)
	if body.name == "Player" and body.current_health < 3:  # Asume que el nodo jugador tiene el nombre "Player"
		body.heal(1)
		call_deferred("queue_free")  # Programar la eliminación del corazón


# Animar el salto del corazón al aparecer
func animate_jump() -> void:
	# Creamos un tween para animar el corazón
	var tween := create_tween()

	# Primera parte de la animación: salto hacia arriba
	tween.tween_property(self, "position:y", initial_position.y + jump_height, 0.5)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUAD)

	# Segunda parte de la animación: caída hacia abajo
	tween.tween_property(self, "position:y", initial_position.y, 0.5)
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_QUAD)
