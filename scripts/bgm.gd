extends AudioStreamPlayer

func _ready():
	## Cambia el puntero del mouse al sprite personalizado
	#Input.set_custom_mouse_cursor(custom_cursor)
	
	# Verifica si el bgm está presente y es del tipo correcto
	if bgm and bgm is AudioStreamPlayer2D:
		# Solo reproducir si no está ya en reproducción
		if not bgm.playing:
			bgm.play()
