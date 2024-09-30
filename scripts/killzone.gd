extends Area2D

@onready var timer: Timer = $Timer
#@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

# Función que se ejecuta cuando otro cuerpo (como el jugador) entra en el área de colisión de este nodo.
func _on_body_entered(body: Node2D) -> void:
	#var animated_sprite = body.get_node("AnimatedSprite2D")
	if body.is_in_group("Player"):  # Suponiendo que tu personaje pertenece al grupo "Player"
		body.take_damage(1)  # Restar 1 de vida al personaje
	# Comprobar si la salud del jugador ha llegado a 0 (el jugador ha muerto)
	if body.current_health == 0:
		Engine.time_scale = 0.75
		body.get_node("CollisionShape2D").queue_free()
		timer.start()

# Función que se ejecuta cuando el temporizador se agota
func _on_timer_timeout() -> void:
	Engine.time_scale = 1
	get_tree().reload_current_scene()
