# menu.gd

extends Control
@onready var menu: Control = $"."
@onready var play: Button = $VBoxContainer/Play
@onready var restart: Button = $VBoxContainer/Restart
@onready var scoreboard: Button = $VBoxContainer/Scoreboard
@onready var custom_cursor: Texture = preload("res://assets/sprites/cursor.png")


func _ready():
	global.current_scene = get_tree().current_scene.to_string()
	print(global.current_scene)
	# Cambia el puntero del mouse al sprite personalizado
	Input.set_custom_mouse_cursor(custom_cursor)
	if bgm and bgm is AudioStreamPlayer2D:
		if not bgm.playing:
			bgm.play()

func _input(_event: InputEvent) -> void:
	#print(_event.as_text())
	if Input.is_action_just_pressed("ui_cancel"):
		_toggle_cursor()
		play.text = "Continue"  # Actualiza el texto del botón "Play" al mostrar el menú
		restart.disabled = false
		await get_tree().create_timer(0.2).timeout
		if get_tree().paused:
			_toggle_menu()
	

# Función para iniciar la partida
func _on_play_button_pressed() -> void:
	_toggle_cursor()
	if get_tree().paused:
		print("Continue game")
		_toggle_menu()
	else:
		print("New game")
		#get_tree().paused = true
		await get_tree().create_timer(0.7).timeout
		#get_tree().change_scene_to_file("res://scenes/game.tscn")  # Cambia a la escena del juego
		get_tree().change_scene_to_file("res://scenes/player_name.tscn")
		

# Función para reiniciar la partida
func _on_restart_button_pressed() -> void:
	await get_tree().create_timer(0.7).timeout
	get_tree().paused = false  # Despausa antes de recargar la escena
	get_tree().reload_current_scene()  # Recarga la escena actual (suponiendo que ya es la escena del juego)
	print("Reload scene")
	
func _on_scoreboard_button_pressed():
	global.previous_scene = get_tree().current_scene.name  # Guardar el nombre de la escena actual
	get_tree().change_scene_to_file("res://scenes/scoreboard.tscn")  # Cambiar a la escena de puntajes

	
	

# Función para salir del juego
func _on_exit_button_pressed() -> void:
	print("Exit game")
	get_tree().quit()  # Sale del juego

# Función para mostrar/ocultar menu
func _toggle_menu() -> void:
	if get_tree().paused:
		get_tree().paused = !get_tree().paused
		menu.visible = !menu.visible

func _toggle_cursor() -> void:
	if get_tree().paused:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


		
