# options.gd

extends Control

# Sliders y botones de BGM y SFX
@onready var master_slider: HSlider = $VBoxContainer/HBoxContainer3/MasterSlider
@onready var master_mute_button: Button = $VBoxContainer/HBoxContainer3/MasterMuteButton
@onready var bgm_slider : HSlider = $VBoxContainer/HBoxContainer/BGMSlider
@onready var bgm_mute_button : Button = $VBoxContainer/HBoxContainer/BGMMuteButton
@onready var sfx_slider : HSlider = $VBoxContainer/HBoxContainer2/SFXSlider
@onready var sfx_mute_button : Button = $VBoxContainer/HBoxContainer2/SFXMuteButton

var master_bus_index : int
var bgm_bus_index : int
var sfx_bus_index : int
var config_file_path : String = "user://settings.cfg"  # Archivo de configuración más general

func _ready():
	if bgm and bgm is AudioStreamPlayer:
		if not bgm.playing:
			bgm.play()
	# Obtener los índices de los buses de audio
	master_bus_index = AudioServer.get_bus_index("Master")
	bgm_bus_index = AudioServer.get_bus_index("BGM")
	sfx_bus_index = AudioServer.get_bus_index("SFX")
	
	# Cargar configuraciones guardadas (si existen)
	load_settings()

	# Asignar valores iniciales a los sliders
	master_slider.value = db_to_linear(AudioServer.get_bus_volume_db((master_bus_index)))
	bgm_slider.value = db_to_linear(AudioServer.get_bus_volume_db(bgm_bus_index))
	sfx_slider.value = db_to_linear(AudioServer.get_bus_volume_db(sfx_bus_index))


func _on_master_slider_value_changed(value):
	AudioServer.set_bus_volume_db(master_bus_index, linear_to_db(value))
	AudioServer.set_bus_mute(master_bus_index, false)
	save_settings()

func _on_master_mute_button_pressed() -> void:
	AudioServer.set_bus_mute(master_bus_index, true)
	master_slider.value = 0
	save_settings()

# Manejar cambios en el slider de BGM
func _on_bgm_slider_value_changed(value):
	AudioServer.set_bus_volume_db(bgm_bus_index, linear_to_db(value))
	AudioServer.set_bus_mute(bgm_bus_index, false)
	save_settings()

# Manejar cambios en el slider de SFX
func _on_sfx_slider_value_changed(value):
	AudioServer.set_bus_volume_db(sfx_bus_index, linear_to_db(value))
	AudioServer.set_bus_mute(sfx_bus_index, false)
	save_settings()

# Manejar botón de mute de BGM
func _on_bgm_mute_button_pressed():
	AudioServer.set_bus_mute(bgm_bus_index, true)
	bgm_slider.value = 0
	save_settings()

# Manejar botón de mute de SFX
func _on_sfx_mute_button_pressed():
	AudioServer.set_bus_mute(sfx_bus_index, true)
	sfx_slider.value = 0
	save_settings()

# Guardar configuraciones en archivo (incluyendo otras futuras opciones)
func save_settings():
	var config = ConfigFile.new()
	config.set_value("audio", "master_volume", master_slider.value)
	config.set_value("audio", "bgm_volume", bgm_slider.value)
	#config.set_value("audio", "bgm_muted", AudioServer.is_bus_mute_enabled(bgm_bus_index))
	config.set_value("audio", "sfx_volume", sfx_slider.value)
	#config.set_value("audio", "sfx_muted", AudioServer.is_bus_mute_enabled(sfx_bus_index))
	# En el futuro puedes agregar más configuraciones bajo otras secciones, por ejemplo:
	# config.set_value("graphics", "fullscreen", fullscreen)
	# config.set_value("controls", "sensitivity", mouse_sensitivity)
	config.save(config_file_path)
	# Imprimir la ruta donde se guarda el archivo
	#print("Configuración guardada en: ", config_file_path)

# Cargar configuraciones desde archivo
func load_settings():
	var config = ConfigFile.new()
	var err = config.load(config_file_path)
	if err == OK:
		# Cargar valores de la sección de audio si existen
		var master_volume = config.get_value("audio", "master_volume", 1.0)
		var master_muted = config.get_value("audio", "master_muted", false)
		var bgm_volume = config.get_value("audio", "bgm_volume", 1.0)  # Volumen por defecto es 1.0
		var bgm_muted = config.get_value("audio", "bgm_muted", false)  # Mute por defecto es false
		var sfx_volume = config.get_value("audio", "sfx_volume", 1.0)
		var sfx_muted = config.get_value("audio", "sfx_muted", false)
		
		# Aplicar los valores a los sliders y al AudioServer
		master_slider.value = master_volume
		AudioServer.set_bus_volume_db(master_bus_index, linear_to_db(master_volume))
		AudioServer.set_bus_mute(master_bus_index, master_muted)
		
		bgm_slider.value = bgm_volume
		AudioServer.set_bus_volume_db(bgm_bus_index, linear_to_db(bgm_volume))
		AudioServer.set_bus_mute(bgm_bus_index, bgm_muted)

		sfx_slider.value = sfx_volume
		AudioServer.set_bus_volume_db(sfx_bus_index, linear_to_db(sfx_volume))
		AudioServer.set_bus_mute(sfx_bus_index, sfx_muted)
		# En el futuro puedes cargar otras configuraciones:
		# fullscreen = config.get_value("graphics", "fullscreen", false)
		# mouse_sensitivity = config.get_value("controls", "sensitivity", 1.0)


# Función llamada al presionar el botón de menú
func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu.tscn")  # Volver al menú
