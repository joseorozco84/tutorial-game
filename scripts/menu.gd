extends Control

@onready var menu: Control = $"." 
@onready var player_option_button: OptionButton = $VBoxContainer/HBoxContainer/PlayerOptionButton
@onready var plus_button: Button = $VBoxContainer/HBoxContainer/PlusButton
@onready var play_button: Button = $VBoxContainer/PlayButton
@onready var restart_button: Button = $VBoxContainer/RestartButton
@onready var scoreboard_button: Button = $VBoxContainer/ScoreboardButton
@onready var custom_cursor: Texture = preload("res://assets/sprites/cursor.png")
@onready var hover_sound: AudioStreamPlayer = $HoverSound
@onready var panel: Panel = $Panel

var config_file_path: String = "user://settings.cfg"  # Archivo de configuración general

func _ready():
	global.current_scene = get_tree().current_scene.to_string()
	print(global.current_scene)
	restart_button.visible = false
	_custom_cursor()
	if bgm and bgm is AudioStreamPlayer:
		if not bgm.playing:
			bgm.play()
			
	fill_player_option_button()
	
# Cambia el puntero del mouse al sprite personalizado
func _custom_cursor() -> void:
	Input.set_custom_mouse_cursor(custom_cursor)

# Cambia elementos del menu segun
func _input(_event: InputEvent) -> void:
	#print(_event.as_text())
	if Input.is_action_just_pressed("ui_cancel"):
		_toggle_cursor()
		panel.visible = true
		play_button.text = "CONTINUE"  # Actualiza el texto del botón "Play" al mostrar el menú
		restart_button.disabled = false
		restart_button.visible = true
		$VBoxContainer/HBoxContainer.visible = false
		$VBoxContainer/HSeparator.visible = false
		await get_tree().create_timer(0.2).timeout
		if get_tree().paused:
			_toggle_menu()

# Función para reproducir sonido al hacer mouseover
func _on_button_mouse_entered() -> void:
	if hover_sound:
		hover_sound.stop()
		hover_sound.play()

func fill_player_option_button() -> void:
	# Limpiar las opciones anteriores (si existen)
	player_option_button.clear()

	# Iterar sobre los nombres en la lista global.unique_names y agregarlos al OptionButton
	for name in global.unique_names:
		player_option_button.add_item(name)

func _on_player_option_button_selected(index: int) -> void:
	# Obtener el nombre seleccionado usando el índice y guardarlo en global.player_name
	global.player_name = player_option_button.get_item_text(index)
	print("Nombre seleccionado: %s" % global.player_name)

# Función para iniciar la partida
func _on_play_button_pressed() -> void:
	_toggle_cursor()
	if get_tree().paused:
		print("Continue game")
		_toggle_menu()
	else:
		print("New game")
		if global.player_name != "":
			get_tree().change_scene_to_file("res://scenes/game.tscn")  # Cambia a la escena del juego
		else:
			print("Por favor, ingresa un nombre o selecciona uno de la lista.")

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
	await get_tree().create_timer(0.7).timeout
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

func _on_options_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/options.tscn")  # Cambiar a la escena de puntajes

func _on_plus_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/player_name.tscn")
