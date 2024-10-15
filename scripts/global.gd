extends Node

var config_file_path : String = "user://settings.cfg"  # Archivo de configuración general

var final_time = 0
var record_time = 0
var new_record_time : bool = false
var player_name : String = ""
var datetime = 0
var previous_scene: String = ""
var current_scene: String = ""
var unique_names = []
var scores = []

var master_volume : float = 1.0 # Valor inicial por defecto
var master_muted : bool = false
var bgm_volume : float = 1.0  # Valor inicial por defecto
var bgm_muted : bool = false
var sfx_volume: float = 1.0   # Valor inicial por defecto
var sfx_muted : bool = false

func _ready() -> void:
	load_settings()
	_load_scores()
	_load_name_list(scores)
	if not unique_names:
		player_name = "Guest"
	else:
		player_name = unique_names[0]
	print(unique_names)
	# Aplicar los volúmenes cargados
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(master_volume))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("BGM"), linear_to_db(bgm_volume))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(sfx_volume))


func load_settings():
	var config = ConfigFile.new()
	var err = config.load(config_file_path)

	if err == OK:
		# Cargar valores de la sección de audio si existen y asignarlos a las variables globales
		master_volume = config.get_value("audio", "master_volume", 1.0)
		master_muted = config.get_value("audio", "master_muted", false)
		bgm_volume = config.get_value("audio", "bgm_volume", 1.0)
		bgm_muted = config.get_value("audio", "bgm_muted", false)
		sfx_volume = config.get_value("audio", "sfx_volume", 1.0)
		sfx_muted = config.get_value("audio", "sfx_muted", false)
	else:
		print("No se pudo cargar el archivo de configuración. Creando un nuevo archivo con valores por defecto.")
		save_default_settings()

func save_default_settings():
	var config = ConfigFile.new()
	
	# Guardar valores por defecto
	config.set_value("audio", "master_volume", master_volume)
	config.set_value("audio", "master_muted", master_muted)
	config.set_value("audio", "bgm_volume", bgm_volume)
	config.set_value("audio", "bgm_muted", bgm_muted)
	config.set_value("audio", "sfx_volume", sfx_volume)
	config.set_value("audio", "sfx_muted", sfx_muted)
	
	# Guardar el archivo de configuración en la ruta especificada
	var err = config.save(config_file_path)
	
	if err == OK:
		print("Archivo de configuración creado en:", config_file_path)
	else:
		print("Error al crear el archivo de configuración.")
		
		
# Cargar los nombre guardados
func _load_scores() -> Array:
	var file_path = "user://scoreboard_data.json"

	if FileAccess.file_exists(file_path):
		var file = FileAccess.open(file_path, FileAccess.READ)
		if file:
			var content = file.get_as_text()
			var json = JSON.new()
			if json.parse(content) == OK:
				scores = json.get_data()
			file.close()
	return scores

func _load_name_list(scores) -> Array:
	# Carga los nombres únicos desde scoreboard_data.json
	
	# Recopilar nombres únicos
	for score in scores:
		if score["name"] not in unique_names:
			unique_names.append(score["name"])
	return unique_names
