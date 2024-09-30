extends CanvasLayer

@onready var gameover_audio: AudioStreamPlayer = $GameoverAudio  # Asegúrate de que esté bien referenciado
@onready var time_label: Label = $Control/TimeLabel  # Asegúrate de tener un nodo Label en la escena
@onready var new_record_label: Label = $Control/NewRecordLabel  # Asegúrate de tener otro nodo Label para "NEW RECORD"

func _ready() -> void:
	new_record_label.visible = false
	global.current_scene = get_tree().current_scene.to_string()
	#print(global.current_scene)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# Reproduce la música de game over
	gameover_audio.play()  # Reproducir el audio de Game Over
	
	# Mostrar el tiempo y verificar si es un nuevo récord
	var time = global.final_time  # Usar la variable global final_time
	time_label.text = format_time(time)  # Mostrar el tiempo en el formato adecuado

	if global.new_record_time:
		new_record_label.visible = true
		
	print("TIME: " + str(global.final_time))
	print("RECORD: " + str(global.record_time))
	

# Función para formatear el tiempo en mm:ss
func format_time(total_seconds: int) -> String:
	var minutes = total_seconds / 60  # Obtener minutos
	var seconds = total_seconds % 60   # Obtener segundos
	return str(minutes).pad_zeros(2) + ":" + str(seconds).pad_zeros(2)  # Formatear como mm:ss

# Función para manejar el botón de volver al menú
func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
	if bgm and bgm is AudioStreamPlayer2D:
		bgm.play()

func _on_scoreboard_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/scoreboard.tscn")
