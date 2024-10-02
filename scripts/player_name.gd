extends Control

@onready var name_input: LineEdit = $HBoxContainer/NameInput
@onready var submit_button: Button = $HBoxContainer/SubmitButton
@onready var play_button: Button = $HBoxContainer3/VBoxContainer/PlayButton
@onready var name_list: ItemList = $HBoxContainer2/NameList
@onready var delete_button: Button = $HBoxContainer/DeleteButton  # Botón para eliminar
@onready var back_button: Button = $HBoxContainer3/VBoxContainer/BackButton
@onready var hover_sound: AudioStreamPlayer = $HoverSound

var selected_name_index: int = -1  # Para guardar el índice del nombre seleccionado

func _ready() -> void:
	global.current_scene = get_tree().current_scene.to_string()
	print(global.current_scene)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	# Cargar la lista de nombres guardados
	_load_name_list()

	# Ocultar el botón Delete al principio
	delete_button.visible = false
	
	# Deshabilita el botón Play
	play_button.disabled = true
	
func _load_name_list() -> void:
	# Carga los nombres únicos desde scoreboard_data.json
	var scores = _load_scores()
	var unique_names = []  # Lista para nombres únicos
	
	# Recopilar nombres únicos
	for score in scores:
		if score["name"] not in unique_names:
			unique_names.append(score["name"])
	
	# Agregar los nombres únicos al ItemList (lista visible)
	name_list.clear()  # Limpiamos el ItemList antes de agregar los nombres
	for name in unique_names:
		name_list.add_item(name)

func _load_scores() -> Array:
	var file_path = "user://scoreboard_data.json"
	var scores = []

	if FileAccess.file_exists(file_path):
		var file = FileAccess.open(file_path, FileAccess.READ)
		if file:
			var content = file.get_as_text()
			var json = JSON.new()
			if json.parse(content) == OK:
				scores = json.get_data()
			file.close()
	return scores

func _save_scores(scores: Array) -> void:
	var file_path = "user://scoreboard_data.json"
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(scores))
		file.close()

# Función para manejar el evento de SubmitButton
func _on_submit_button_pressed() -> void:
	# Obtén el nombre del jugador desde el LineEdit
	var player_name = name_input.text

	if player_name != "":
		# Cargar los puntajes actuales
		var scores = _load_scores()

		# Verificar si el nombre ya existe en la lista
		var name_exists = false
		for score in scores:
			if score["name"] == player_name:
				name_exists = true
				break

		# Si el nombre no existe, agregarlo con un tiempo nulo
		if not name_exists:
			var new_score = {"name": player_name, "time": null}
			scores.append(new_score)
			_save_scores(scores)  # Guardar los cambios en el archivo
			_load_name_list()  # Actualizar la lista en la UI
		else:
			print("El nombre ya existe en la lista.")

		# Limpiar el campo de texto
		name_input.clear()
	else:
		print("Por favor, ingresa un nombre.")

# Función para manejar el evento de PlayButton
func _on_play_button_pressed() -> void:
	# Verifica si el jugador tiene un nombre asignado
	if global.player_name != "":
		get_tree().change_scene_to_file("res://scenes/game.tscn")  # Cambia a la escena del juego
	else:
		print("Por favor, ingresa un nombre o selecciona uno de la lista.")

# Función para manejar la selección de un nombre en la lista
func _on_name_list_item_selected(index: int) -> void:
	# Guardamos el índice del nombre seleccionado
	selected_name_index = index
	var selected_name = name_list.get_item_text(selected_name_index)
	print("Nombre seleccionado: ", selected_name)
	global.player_name = selected_name  # Guarda el nombre del jugador seleccionado

	# Cambiar visibilidad de los botones
	delete_button.visible = true  # Mostrar el botón Delete
	submit_button.visible = false  # Ocultar el botón Submit
	play_button.disabled = false

# Función para manejar el evento de DeleteButton
func _on_delete_button_pressed() -> void:
	if selected_name_index != -1:  # Verifica si hay un nombre seleccionado
		# Cargar los puntajes actuales
		var scores = _load_scores()

		# Encontrar y eliminar el nombre seleccionado
		var selected_name = name_list.get_item_text(selected_name_index)
		for i in range(scores.size()):
			if scores[i]["name"] == selected_name:
				scores.remove_at(i)
				break

		# Guardar los puntajes actualizados
		_save_scores(scores)

		# Actualizar la lista de nombres en la UI
		_load_name_list()

		# Reiniciar el índice seleccionado
		selected_name_index = -1

		# Cambiar visibilidad de los botones
		delete_button.visible = false  # Ocultar el botón Delete
		submit_button.visible = true  # Mostrar el botón Submit
	else:
		print("No hay ningún nombre seleccionado para eliminar.")

# Función que se ejecuta cuando el LineEdit recibe foco
func _on_name_input_focus_entered() -> void:
	# Cambiar visibilidad de los botones
	delete_button.visible = false  # Ocultar el botón Delete
	submit_button.visible = true  # Mostrar el botón Submit
	
	# Deseleccionar el ítem actualmente seleccionado en el ItemList
	if selected_name_index != -1:
		name_list.deselect(selected_name_index)
		selected_name_index = -1  # Reiniciar el índice seleccionado

	# Deshabilitar el botón Play ya que no hay nombre seleccionado
	play_button.disabled = true


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu.tscn")  # Volver al menú


func _on_mouse_button_entered() -> void:
	if hover_sound:
		hover_sound.stop()
		hover_sound.play()
