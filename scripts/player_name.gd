# player_name.gd

extends Control

@onready var name_input: LineEdit = $HBoxContainer/NameInput
@onready var submit_button: Button = $HBoxContainer/SubmitButton

func _ready() -> void:
	global.current_scene = get_tree().current_scene.to_string()
	print(global.current_scene)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_submit_button_pressed():
	# Obtén el nombre del jugador desde el LineEdit
	var player_name = name_input.text
	if player_name != "":
		# Guarda el nombre globalmente y continúa con el juego
		global.player_name = player_name
		get_tree().change_scene_to_file("res://scenes/game.tscn")  # Cambia a la escena del juego
	else:
		print("Por favor, ingresa un nombre.")
