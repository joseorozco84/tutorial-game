extends Control

@onready var countdown_label: Label = $CountdownLabel
@onready var instruction_label: Label = $InstructionLabel  # Agrega esta línea para el nuevo label
@onready var timer: Timer = $Timer  # Asegúrate de que el nodo Timer tenga este nombre

var countdown_value: int = 3  # Valor inicial para el conteo

func _ready() -> void:
	# Pausar el juego al comenzar
	get_tree().paused = true
	
	# Mostrar el texto de instrucciones antes del countdown
	instruction_label.text = "Collect 100 coins!"
	instruction_label.visible = true  # Asegúrate de que el label sea visible

	# Iniciar el temporizador para ocultar las instrucciones
	await get_tree().create_timer(3.0).timeout  # Espera 3 segundos
	instruction_label.visible = false  # Ocultar las instrucciones

	# Configurar y mostrar el countdown inicial
	countdown_label.text = str(countdown_value)  # Mostrar el valor inicial (3)
	timer.wait_time = 1.0  # Tiempo de espera entre cada actualización (1 segundo)
	timer.connect("timeout", Callable(self, "_on_timer_timeout"))  # Conectar la señal timeout del Timer a una función
	timer.start()  # Iniciar el temporizador

func _on_timer_timeout() -> void:
	if countdown_value > 1:
		countdown_value -= 1  # Decrementar el valor del conteo
		countdown_label.text = str(countdown_value)  # Actualizar el texto
	elif countdown_value == 1:
		countdown_value = 0  # Cambiar a 0 para mostrar "GO!"
		countdown_label.text = "GO!"
		await get_tree().create_timer(1.0).timeout  # Esperar 1 segundo antes de ocultar el texto
		countdown_label.visible = false
		timer.stop()  # Detener el temporizador una vez que llegue a "GO!"

		# Reanudar el juego
		get_tree().paused = false
