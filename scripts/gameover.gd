extends CanvasLayer

@onready var gameover_audio: AudioStreamPlayer = $GameoverAudio  # Asegúrate de que esté bien referenciado
@onready var time_label: Label = $Control/VBoxContainer2/TimeLabel  # Asegúrate de tener un nodo Label en la escena
@onready var new_record_label: Label = $Control/VBoxContainer2/NewRecordLabel  # Asegúrate de tener otro nodo Label para "NEW RECORD"
@onready var hover_sound: AudioStreamPlayer = $Control/HoverSound

func _ready() -> void:
	# Agregar un delay
	new_record_label.visible = false
	#await get_tree().create_timer(0.7).timeout
	if bgm and bgm is AudioStreamPlayer:
		bgm.stop()
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
	
# Función para reproducir sonido al hacer mouseover
func _on_button_mouse_entered() -> void:
	if hover_sound:
		hover_sound.stop()
		hover_sound.play()

# Función para formatear el tiempo en mm:ss
func format_time(total_seconds: int) -> String:
	var minutes = total_seconds / 60  # Obtener minutos
	var seconds = total_seconds % 60   # Obtener segundos
	return str(minutes).pad_zeros(2) + ":" + str(seconds).pad_zeros(2)  # Formatear como mm:ss

# Función para manejar el botón de volver al menú
func _on_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
	if bgm and bgm is AudioStreamPlayer:
		bgm.play()

func _on_scoreboard_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/scoreboard.tscn")
	if bgm and bgm is AudioStreamPlayer:
		bgm.play()


func _on_try_again_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")  # Cambia a la escena del juego
