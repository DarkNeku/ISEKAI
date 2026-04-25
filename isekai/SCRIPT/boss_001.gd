extends Control

@onready var dado = $Panel/DADO
@onready var animated_dado = $Panel/DADO/AnimatedSprite2D

func _ready():
	# Reproducir animación del BOSS
	$Panel/BOSS_1/AnimatedSprite2D.play("QUIETO")
	$Panel/BOSS_2/AnimatedSprite2D.play("QUIETO")
	
	# Configurar barra de vida
	configurar_barra_vida()
	
	# Conectar señal de fin de animación del dado
	animated_dado.animation_finished.connect(_on_dado_animation_finished)
	
	# ACTIVAR EL DADO AL INICIAR LA ESCENA
	dado.visible = true
	animated_dado.play("LANZAMIENTO")

func _on_dado_animation_finished():
	if animated_dado.animation == "LANZAMIENTO":
		dado.visible = false

func configurar_barra_vida():
	var barra = $Panel/VIDA_BOSS
	
	barra.max_value = 100
	barra.min_value = 0
	barra.value = 100
	barra.custom_minimum_size = Vector2(300, 30)
	
	var estilo_lleno = StyleBoxFlat.new()
	estilo_lleno.bg_color = Color(0.9, 0.1, 0.1)
	estilo_lleno.set_border_width_all(4)
	estilo_lleno.border_color = Color(0, 0, 0)
	estilo_lleno.corner_radius_top_left = 8
	estilo_lleno.corner_radius_top_right = 8
	estilo_lleno.corner_radius_bottom_left = 8
	estilo_lleno.corner_radius_bottom_right = 8
	barra.add_theme_stylebox_override("fill", estilo_lleno)
	
	var estilo_fondo = StyleBoxFlat.new()
	estilo_fondo.bg_color = Color(0, 0, 0, 0)
	estilo_fondo.set_border_width_all(4)
	estilo_fondo.border_color = Color(0, 0, 0)
	estilo_fondo.corner_radius_top_left = 8
	estilo_fondo.corner_radius_top_right = 8
	estilo_fondo.corner_radius_bottom_left = 8
	estilo_fondo.corner_radius_bottom_right = 8
	barra.add_theme_stylebox_override("background", estilo_fondo)
	
	barra.show_percentage = false

func reducir_vida_boss(cantidad):
	var barra = $Panel/VIDA_BOSS
	barra.value = max(0, barra.value - cantidad)
	print("Vida del BOSS: ", barra.value, "%")
	
	if barra.value <= 0:
		print("💀 BOSS DERROTADO 💀")

func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		reducir_vida_boss(10)
