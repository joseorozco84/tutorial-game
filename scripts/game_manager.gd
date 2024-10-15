extends Node

# Variables globales
var total_coins: int = 0  # Inicializamos la variable con 0
var collected_coins: int = 0  # Monedas recogidas por el jugador
var score: int = 0  # Puntaje total del jugador
var timer: float = 0.0  # Variable para llevar el conteo del tiempo en segundos
var is_timer_running: bool = false  # Para controlar si el timer está activo
var player_name: String = ""  # Variable para almacenar el nombre del jugador

@onready var coins_label: Label = %CoinsLabel
@onready var timer_label: Label = %TimerLabel

func _ready():
	# Inicializamos el conteo total de monedas después de que la escena esté lista
	total_coins = get_tree().get_nodes_in_group("Coins").size()
	#total_coins = 10
	_start_timer()

func _process(delta: float) -> void:
	if is_timer_running:
		timer += delta  # Aumentar el timer con el tiempo transcurrido
		_update_timer_label()

# Funciones de Temporizador
func _start_timer() -> void:
	is_timer_running = true

func _stop_timer() -> void:
	is_timer_running = false

func _reset_timer() -> void:
	timer = 0
	_update_timer_label()

func _update_timer_label() -> void:
	var minutes = int(timer) / 60
	var seconds = int(timer) % 60
	timer_label.text = str(minutes).pad_zeros(2) + ":" + str(seconds).pad_zeros(2)

# Funciones de Puntaje
func add_point() -> void:
	collected_coins += 1
	score += 1
	coins_label.text = str(score).pad_zeros(2)

	if collected_coins >= total_coins:
		end_game()

func end_game() -> void:
	_stop_timer()  # Detener el temporizador al final del juego
	if bgm and bgm is AudioStreamPlayer:
		bgm.stop()

	print("¡Todas las monedas recogidas! ¡Ganaste!")
	print("Nombre del jugador: ", global.player_name)

	global.final_time = int(timer)  # Guardar el tiempo final

	if is_new_record(int(timer)):
		print("¡Es un nuevo récord!")

	_save_score(global.player_name, int(timer))
	call_deferred("_change_to_gameover_scene")

func _change_to_gameover_scene() -> void:
	get_tree().change_scene_to_file("res://scenes/gameover.tscn")

# Funciones de Guardado de Puntajes
func _save_score(name: String, time: int) -> void:
	var scores = _load_scores()
	scores.insert(0, {"name": name, "time": time})  # Insertar al principio de la lista
	_save_scores(scores)


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
		print("Nuevo puntaje guardado.")
	else:
		print("Error al abrir el archivo para guardar.")

# Función para verificar si el nuevo tiempo es un récord
func is_new_record(new_time: int) -> bool:
	var scores = _load_scores()
	if scores.size() == 0:
		print("No hay récords previos. Este tiempo es un nuevo récord.")
		global.record_time = new_time
		global.new_record_time = true
		return true

	# Asegúrate de que el primer puntaje sea válido
	var best_time = scores[0]["time"]
	if best_time == null:
		print("Error: el mejor tiempo es Nil, no se puede comparar.")
		return false  # Salimos si no hay un mejor tiempo válido

	for score in scores:
		if score["time"] != null and score["time"] < best_time:
			best_time = score["time"]

	if new_time < best_time:
		print("Nuevo récord encontrado:", new_time, "<", best_time)
		global.record_time = new_time
		global.new_record_time = true
		return true

	print("No es un nuevo récord:", new_time)
	global.new_record_time = false
	return false
