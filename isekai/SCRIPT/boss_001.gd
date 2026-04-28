extends Control

# Variables
var cantidad_jugadores = 0
var contador_ok = 0
var indice_jugador_actual = 0
var indice_inicio_ronda = 0
var lista_jugadores = []

# Nodos
@onready var dado = $Panel/DADO
@onready var animated_dado = $Panel/DADO/AnimatedSprite2D
@onready var btn_lanzar = $Panel/Control2/BTN_LANZAR
@onready var btn_ok = $Panel/Control2/BTN_OK
@onready var btn_dano = $Panel/Control2/BTN_DANO
@onready var btn_directo = $Panel/Control2/BTN_DIRECTO
@onready var btn_restar = $Panel/Control2/BTN_RESTAR
@onready var lbl_nom_jug = $Panel/LBL_NOM_JUG

func _ready():
	cargar_jugadores()
	
	$Panel/BOSS_1/AnimatedSprite2D.play("QUIETO")
	$Panel/BOSS_2/AnimatedSprite2D.play("QUIETO")
	
	configurar_barra_vida()
	
	animated_dado.animation_finished.connect(_on_dado_animation_finished)
	
	if btn_lanzar:
		btn_lanzar.pressed.connect(_on_BTN_LANZAR_pressed)
		btn_lanzar.visible = false
	
	if btn_ok:
		btn_ok.pressed.connect(_on_BTN_OK_pressed)
	
	# Inicializar la primera ronda
	indice_inicio_ronda = 0
	indice_jugador_actual = 0
	actualizar_nombre_jugador()
	
	# DESACTIVAR BOTONES AL INICIO (antes de la animación inicial)
	set_botones_activos(false)
	
	# Lanzar el dado al iniciar la escena
	lanzar_dado()

# Función para activar/desactivar botones (excepto BTN_LANZAR)
func set_botones_activos(activo: bool):
	if btn_ok:
		btn_ok.disabled = !activo
	if btn_dano:
		btn_dano.disabled = !activo
	if btn_directo:
		btn_directo.disabled = !activo
	if btn_restar:
		btn_restar.disabled = !activo
	
	var estado = "ACTIVOS" if activo else "DESACTIVADOS"
	print("🔘 Botones ", estado)

func cargar_jugadores():
	var ruta = "user://" + "jugadores.json"
	
	if not FileAccess.file_exists(ruta):
		print("❌ No se encontró el archivo de jugadores")
		lista_jugadores = ["Jugador 1", "Jugador 2", "Jugador 3"]
		cantidad_jugadores = lista_jugadores.size()
		return
	
	var archivo = FileAccess.open(ruta, FileAccess.READ)
	var contenido = archivo.get_as_text()
	archivo.close()
	
	var datos = JSON.parse_string(contenido)
	
	if datos and datos is Array:
		lista_jugadores = []
		for jugador in datos:
			lista_jugadores.append(jugador["nombre"])
		cantidad_jugadores = lista_jugadores.size()
		print("✅ Jugadores cargados: ", lista_jugadores)
	else:
		lista_jugadores = ["Jugador 1", "Jugador 2", "Jugador 3"]
		cantidad_jugadores = lista_jugadores.size()

func obtener_nombre_rotado(indice):
	var posicion_real = (indice_inicio_ronda + indice) % cantidad_jugadores
	return lista_jugadores[posicion_real]

func actualizar_nombre_jugador():
	if lbl_nom_jug and lista_jugadores.size() > 0:
		var nombre_actual = obtener_nombre_rotado(indice_jugador_actual)
		lbl_nom_jug.text = nombre_actual
		print("📝 Turno de: ", nombre_actual)

func _on_BTN_OK_pressed():
	print("🔘 Botón OK presionado")
	
	indice_jugador_actual += 1
	contador_ok += 1
	
	print("  → OK presionados en esta ronda: ", contador_ok, "/", cantidad_jugadores)
	
	if indice_jugador_actual >= cantidad_jugadores:
		print("🎉 ¡Ronda completa! Mostrando botón LANZAR")
		btn_lanzar.visible = true
		# DESACTIVAR BOTONES CUANDO APARECE BTN_LANZAR
		set_botones_activos(false)
	else:
		actualizar_nombre_jugador()

func _on_BTN_LANZAR_pressed():
	print("🔘 Botón LANZAR presionado")
	
	btn_lanzar.visible = false
	
	# Avanzar el inicio de la ronda
	indice_inicio_ronda += 1
	if indice_inicio_ronda >= cantidad_jugadores:
		indice_inicio_ronda = 0
	
	# Resetear para la nueva ronda
	indice_jugador_actual = 0
	contador_ok = 0
	
	actualizar_nombre_jugador()
	
	# Los botones se reactivarán cuando termine la animación
	lanzar_dado()
	
	print("  → Nueva ronda. Inicia con: ", obtener_nombre_rotado(0))

func lanzar_dado():
	dado.visible = true
	animated_dado.play("LANZAMIENTO")
	print("🎲 Dado lanzado")

func _on_dado_animation_finished():
	if animated_dado.animation == "LANZAMIENTO":
		dado.visible = false
		print("🎲 Animación terminada, dado oculto")
		
		# REACTIVAR BOTONES CUANDO TERMINA LA ANIMACIÓN
		set_botones_activos(true)

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
