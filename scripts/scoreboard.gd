extends CanvasLayer

@onready var back_button: Button = $Control/Back
@onready var score_list: VBoxContainer = $VBoxContainer2/ScoreList
@onready var hover_sound: AudioStreamPlayer = $Control/HoverSound

func _ready():
	global.current_scene = get_tree().current_scene.get_path()
	print(global.current_scene)
	_load_scores()  # Cargar los puntajes al inicio
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	print("Ruta del archivo JSON: ", ProjectSettings.globalize_path("user://scoreboard_data.json"))
	

# Función para cargar los puntajes guardados
func _load_scores():
	var file_path = "user://scoreboard_data.json"

	# Verificar si el archivo existe
	if not FileAccess.file_exists(file_path):
		_create_score_file(file_path)  # Crear el archivo si no existe

	var file = FileAccess.open(file_path, FileAccess.READ)  # Abrir el archivo para lectura

	# Verificar si el archivo fue abierto correctamente
	if file:
		var content = file.get_as_text()
		var json = JSON.new()  # Crear una instancia de JSON
		var parse_result = json.parse(content)  # Usar la instancia para parsear

		if parse_result == OK:  # Verificar si el parseo fue exitoso
			var scores = json.get_data()  # Obtener los datos del JSON

			# Recorrer los puntajes y mostrarlos en la interfaz
			for score in scores:
				var name = score["name"]  # Acceder a 'name' como un diccionario
				var time = score["time"]  # Acceder a 'time' como un diccionario
				
				# Verificar si 'time' es un número válido (entero o flotante que pueda ser entero)
				if typeof(time) != TYPE_INT and typeof(time) != TYPE_FLOAT:
					print("Valor de tiempo no válido para el jugador: ", name)
					continue  # Saltar este puntaje si 'time' no es un número
				
				# Crear un nuevo HBoxContainer para cada puntaje
				var score_label = HBoxContainer.new()  

				# Crear una etiqueta para el nombre con ajuste de tamaño
				var name_label = Label.new()
				name_label.text = name
				name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL  # Hacer que el nombre ocupe el espacio necesario
				
				# Formatear el tiempo como mm:ss
				var minutes = int(time) / 60  # Convertir a minutos
				var seconds = int(time) % 60  # Convertir a segundos
				var formatted_time = str(minutes).pad_zeros(2) + ":" + str(seconds).pad_zeros(2)  # Formatear como 00:00

				# Crear una etiqueta para el tiempo con ajuste de tamaño
				var time_label = Label.new()
				time_label.text = formatted_time  # Asignar el tiempo formateado
				time_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL  # Hacer que el tiempo ocupe el espacio necesario

				# Alinear correctamente los elementos
				score_label.add_child(name_label)
				score_label.add_child(VSeparator.new())  # Separador vertical
				score_label.add_child(time_label)

				# Agregar el HBoxContainer al VBoxContainer de la lista de puntajes
				score_list.add_child(score_label)
		else:
			print("Error al parsear el JSON.")
		
		file.close()  # Cerrar el archivo
	else:
		print("Error al abrir el archivo.")


# Función para crear el archivo de puntajes sin contenido inicial
func _create_score_file(file_path: String) -> void:
	var file = FileAccess.open(file_path, FileAccess.WRITE)  # Abrir el archivo para escritura
	if file:
		file.store_string("")  # Escribir una cadena vacía en el archivo
		file.close()  # Cerrar el archivo
		print("Archivo de puntajes creado sin contenido inicial.")
	else:
		print("Error al crear el archivo de puntajes.")

# Función llamada al presionar el botón de menú
func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu.tscn")  # Volver al menú

func _on_button_mouse_entered() -> void:
	if hover_sound:
		hover_sound.stop()
		hover_sound.play()
