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
@onready var btn_dano_fisico = $Panel/Control2/BTN_DANO_FISICO
@onready var btn_dano_especial = $Panel/Control2/BTN_DANO_ESPECIAL
@onready var btn_directo = $Panel/Control2/BTN_DIRECTO
@onready var btn_restar = $Panel/Control2/BTN_RESTAR
@onready var lbl_nom_jug = $Panel/LBL_NOM_JUG
@onready var sistema_dados = $Panel/Control/GridContainer

func _ready():
	cargar_jugadores()
	
	# Reproducir animaciones con verificación de errores
	reproducir_animacion_si_existe($Panel/BOSS_1/AnimatedSprite2D, "QUIETO", "BOSS_1")
	reproducir_animacion_si_existe($Panel/BOSS_2/AnimatedSprite2D, "QUIETO", "BOSS_2")
	
	configurar_barra_vida()
	
	# Conectar señal de animación del dado
	if animated_dado:
		if not animated_dado.animation_finished.is_connected(_on_dado_animation_finished):
			animated_dado.animation_finished.connect(_on_dado_animation_finished)
	
	# Conectar botones
	if btn_lanzar:
		if not btn_lanzar.pressed.is_connected(_on_BTN_LANZAR_pressed):
			btn_lanzar.pressed.connect(_on_BTN_LANZAR_pressed)
		btn_lanzar.visible = false
	
	if btn_ok:
		if not btn_ok.pressed.is_connected(_on_BTN_OK_pressed):
			btn_ok.pressed.connect(_on_BTN_OK_pressed)
	
	if btn_directo:
		if not btn_directo.pressed.is_connected(_on_BTN_DIRECTO_pressed):
			btn_directo.pressed.connect(_on_BTN_DIRECTO_pressed)
		print("✅ Botón DIRECTO conectado")
	
	# Inicializar la primera ronda
	indice_inicio_ronda = 0
	indice_jugador_actual = 0
	actualizar_nombre_jugador()
	
	# Desactivar botones al inicio
	set_botones_activos(false)
	
	# Lanzar el dado al iniciar
	lanzar_dado()

# Función auxiliar para reproducir animaciones de forma segura
func reproducir_animacion_si_existe(animated_sprite: AnimatedSprite2D, anim_name: String, nombre_nodo: String):
	if not animated_sprite:
		print("❌ ", nombre_nodo, " no encontrado")
		return
	
	if not animated_sprite.sprite_frames:
		print("❌ ", nombre_nodo, " no tiene sprite_frames asignados")
		return
	
	if animated_sprite.sprite_frames.has_animation(anim_name):
		animated_sprite.play(anim_name)
		print("✅ ", nombre_nodo, " reproduciendo: ", anim_name)
	else:
		print("❌ ", nombre_nodo, " no tiene la animación: ", anim_name)
		print("   Animaciones disponibles: ", animated_sprite.sprite_frames.get_animation_names())

func _on_BTN_DIRECTO_pressed():
	print("🔘 Botón DIRECTO presionado")
	
	if sistema_dados and sistema_dados.has_method("get_resultados_actuales"):
		var resultados = sistema_dados.get_resultados_actuales()
		var daño = resultados.get("ataf", 0) + resultados.get("atas", 0)
		reducir_vida_boss(daño)
		print("  → Daño directo: ", daño)
	else:
		reducir_vida_boss(10)
		print("  → Daño directo fijo: 10")

func lanzar_y_calcular_dados():
	print("🎲 Lanzando dados...")
	if sistema_dados and sistema_dados.has_method("lanzar_todos_los_dados"):
		var resultados = sistema_dados.lanzar_todos_los_dados(cantidad_jugadores)
		print("📊 Resultados: ", resultados)
		return resultados
	else:
		print("❌ Sistema de dados no disponible")
		return null

func set_botones_activos(activo: bool):
	if btn_ok:
		btn_ok.disabled = !activo
	if btn_dano_fisico:
		btn_dano_fisico.disabled = !activo
	if btn_dano_especial:
		btn_dano_especial.disabled = !activo
	if btn_directo:
		btn_directo.disabled = !activo
	if btn_restar:
		btn_restar.disabled = !activo
	print("🔘 Botones: ", "ACTIVOS" if activo else "DESACTIVADOS")

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
	
	print("  → OK: ", contador_ok, "/", cantidad_jugadores)
	
	if indice_jugador_actual >= cantidad_jugadores:
		print("🎉 Ronda completa! Mostrando LANZAR")
		btn_lanzar.visible = true
		set_botones_activos(false)
	else:
		actualizar_nombre_jugador()

func _on_BTN_LANZAR_pressed():
	print("🔘 Botón LANZAR presionado")
	
	btn_lanzar.visible = false
	
	indice_inicio_ronda += 1
	if indice_inicio_ronda >= cantidad_jugadores:
		indice_inicio_ronda = 0
	
	indice_jugador_actual = 0
	contador_ok = 0
	
	actualizar_nombre_jugador()
	
	lanzar_dado()
	
	print("  → Nueva ronda con: ", obtener_nombre_rotado(0))

func lanzar_dado():
	lanzar_y_calcular_dados()
	if dado:
		dado.visible = true
	if animated_dado and animated_dado.sprite_frames and animated_dado.sprite_frames.has_animation("LANZAMIENTO"):
		animated_dado.play("LANZAMIENTO")
		print("🎲 Dado lanzado")
	else:
		print("❌ No se puede reproducir animación LANZAMIENTO del dado")
		set_botones_activos(true)  # Activar botones si no hay animación

func _on_dado_animation_finished():
	if animated_dado and animated_dado.animation == "LANZAMIENTO":
		if dado:
			dado.visible = false
		print("🎲 Animación terminada")
		set_botones_activos(true)

func configurar_barra_vida():
	var barra = $Panel/VIDA_BOSS
	if not barra:
		print("❌ No se encontró VIDA_BOSS")
		return
	
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
	if not barra:
		return
	barra.value = max(0, barra.value - cantidad)
	print("💥 BOSS recibe ", cantidad, " de daño")
	print("  ❤️ Vida restante: ", barra.value, "%")
	
	if barra.value <= 0:
		print("💀 BOSS DERROTADO 💀")

func _process(_delta):
	# Tecla ESPACIO ya no hace daño, ahora solo BTN_DIRECTO
	pass
