# game.gd

extends Node2D

@onready var menu: Control = $CanvasLayer/Menu  # Referencia al menú

func _ready():
	# Asegúrate de que el menú esté oculto al iniciar el juego
	menu.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	print(global.player_name)

# Detectar cuando se presiona la tecla Esc
func _input(event):
	if event.is_action_pressed("ui_cancel"):  # "ui_cancel" es la acción predeterminada para la tecla Esc
		await get_tree().create_timer(0.2).timeout
		get_tree().paused = !get_tree().paused
		menu.visible = true
