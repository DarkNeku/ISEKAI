extends Control

func _ready():
	# Reproducir animación del BOSS
	$Panel/BOSS_1/AnimatedSprite2D.play("QUIETO")
	
	# Configurar barra de vida
	configurar_barra_vida()

func configurar_barra_vida():
	var barra = $Panel/VIDA_BOSS
	
	# Configurar valores
	barra.max_value = 100
	barra.min_value = 0
	barra.value = 100
	
	# Tamaño de la barra
	barra.custom_minimum_size = Vector2(300, 30)
	
	# Estilo de la barra llena (vida) - Rojo con borde negro
	var estilo_lleno = StyleBoxFlat.new()
	estilo_lleno.bg_color = Color(0.9, 0.1, 0.1)  # Rojo vivo
	estilo_lleno.set_border_width_all(4)  # Borde grueso
	estilo_lleno.border_color = Color(0, 0, 0)  # Negro
	estilo_lleno.corner_radius_top_left = 8
	estilo_lleno.corner_radius_top_right = 8
	estilo_lleno.corner_radius_bottom_left = 8
	estilo_lleno.corner_radius_bottom_right = 8
	barra.add_theme_stylebox_override("fill", estilo_lleno)
	
	# Estilo del fondo (vacío) - Transparente con borde negro
	var estilo_fondo = StyleBoxFlat.new()
	estilo_fondo.bg_color = Color(0, 0, 0, 0)  # Transparente
	estilo_fondo.set_border_width_all(4)  # Borde grueso
	estilo_fondo.border_color = Color(0, 0, 0)  # Negro
	estilo_fondo.corner_radius_top_left = 8
	estilo_fondo.corner_radius_top_right = 8
	estilo_fondo.corner_radius_bottom_left = 8
	estilo_fondo.corner_radius_bottom_right = 8
	barra.add_theme_stylebox_override("background", estilo_fondo)
	
	# Ocultar porcentaje
	barra.show_percentage = false

# Función para quitar vida al BOSS
func reducir_vida_boss(cantidad):
	var barra = $Panel/VIDA_BOSS
	barra.value = max(0, barra.value - cantidad)
	print("Vida del BOSS: ", barra.value, "%")
	
	if barra.value <= 0:
		print("💀 BOSS DERROTADO 💀")

# Prueba: presiona espacio para dañar al boss
func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		reducir_vida_boss(10)
