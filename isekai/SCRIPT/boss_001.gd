extends Control

# Variables
var cantidad_jugadores = 0
var contador_ok = 0
var indice_jugador_actual = 0
var indice_inicio_ronda = 0
var lista_jugadores = []

# Contadores de daño
var contador_fisico = 0
var contador_especial = 0
var contador_directo = 0
var historial_golpes = []  # Historial de golpes

# Nodos
@onready var dado = $Panel/DADO
@onready var animated_dado = $Panel/DADO/AnimatedSprite2D
@onready var btn_lanzar = $Panel/Control2/BTN_LANZAR
@onready var btn_ok = $Panel/Control2/BTN_OK
@onready var btn_dano_fisico = $Panel/Control2/BTN_DANO_FISICO
@onready var btn_dano_especial = $Panel/Control2/BTN_DANO_ESPECIAL
@onready var btn_directo = $Panel/Control2/BTN_DIRECTO
@onready var btn_restar = $Panel/Control2/BTN_RESTAR
@onready var lbl_nom_jug = $Panel/Control3/LBL_NOM_JUG
@onready var sistema_dados = $Panel/Control/GridContainer

# Labels de contadores
@onready var lbl_fisico = $Panel/CONTROL_DANO/GridContainer/Panel_FISICO/LBL_FISICO
@onready var lbl_especial = $Panel/CONTROL_DANO/GridContainer/Panel_ESPECIAL/LBL_ESPECIAL
@onready var lbl_directo = $Panel/CONTROL_DANO/GridContainer/Panel_DIRECTO/LBL_DIRECTO

func _ready():
	cargar_jugadores()
	
	reproducir_animacion_si_existe($Panel/BOSS_1/AnimatedSprite2D, "QUIETO", "BOSS_1")
	reproducir_animacion_si_existe($Panel/BOSS_2/AnimatedSprite2D, "QUIETO", "BOSS_2")
	
	configurar_barra_vida()
	
	if animated_dado:
		if not animated_dado.animation_finished.is_connected(_on_dado_animation_finished):
			animated_dado.animation_finished.connect(_on_dado_animation_finished)
	
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
	
	if btn_dano_fisico:
		if not btn_dano_fisico.pressed.is_connected(_on_BTN_DANO_FISICO_pressed):
			btn_dano_fisico.pressed.connect(_on_BTN_DANO_FISICO_pressed)
		print("✅ Botón DAÑO FÍSICO conectado")
	
	if btn_dano_especial:
		if not btn_dano_especial.pressed.is_connected(_on_BTN_DANO_ESPECIAL_pressed):
			btn_dano_especial.pressed.connect(_on_BTN_DANO_ESPECIAL_pressed)
		print("✅ Botón DAÑO ESPECIAL conectado")
	
	if btn_restar:
		if not btn_restar.pressed.is_connected(_on_BTN_RESTAR_pressed):
			btn_restar.pressed.connect(_on_BTN_RESTAR_pressed)
		print("✅ Botón RESTAR conectado")
	
	indice_inicio_ronda = 0
	indice_jugador_actual = 0
	actualizar_nombre_jugador()
	
	actualizar_contadores_ui()
	
	set_botones_activos(false)
	set_botones_visibles(true)
	
	lanzar_dado()

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

func actualizar_contadores_ui():
	if lbl_fisico:
		lbl_fisico.text = str(contador_fisico)
	if lbl_especial:
		lbl_especial.text = str(contador_especial)
	if lbl_directo:
		lbl_directo.text = str(contador_directo)
	print("📊 Contadores - Físico: ", contador_fisico, " | Especial: ", contador_especial, " | Directo: ", contador_directo)

func reiniciar_contadores():
	contador_fisico = 0
	contador_especial = 0
	contador_directo = 0
	historial_golpes.clear()
	actualizar_contadores_ui()
	print("🔄 Contadores e historial reiniciados")

func set_botones_visibles(visible: bool):
	var botones = [btn_ok, btn_dano_fisico, btn_dano_especial, btn_directo, btn_restar]
	for boton in botones:
		if boton:
			boton.visible = visible
	print("🔘 Botones: ", "VISIBLES" if visible else "INVISIBLES")

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
	print("🔘 Botones estado: ", "ACTIVOS" if activo else "DESACTIVADOS")

func _on_BTN_DANO_FISICO_pressed():
	print("🔘 Botón DAÑO FÍSICO presionado")
	contador_fisico += 1
	historial_golpes.append("fisico")
	actualizar_contadores_ui()

func _on_BTN_DANO_ESPECIAL_pressed():
	print("🔘 Botón DAÑO ESPECIAL presionado")
	contador_especial += 1
	historial_golpes.append("especial")
	actualizar_contadores_ui()

func _on_BTN_DIRECTO_pressed():
	print("🔘 Botón DIRECTO presionado")
	contador_directo += 1
	historial_golpes.append("directo")
	actualizar_contadores_ui()
	
	if sistema_dados and sistema_dados.has_method("get_resultados_actuales"):
		var resultados = sistema_dados.get_resultados_actuales()
		var daño = resultados.get("ataf", 0) + resultados.get("atas", 0)
		reducir_vida_boss(daño)
	else:
		reducir_vida_boss(10)

func _on_BTN_RESTAR_pressed():
	print("🔘 Botón RESTAR presionado")
	
	if historial_golpes.is_empty():
		print("  → No hay nada que deshacer")
		return
	
	var ultimo = historial_golpes.pop_back()
	
	match ultimo:
		"fisico":
			contador_fisico -= 1
			print("  → Deshaciendo 1 Físico")
		"especial":
			contador_especial -= 1
			print("  → Deshaciendo 1 Especial")
		"directo":
			contador_directo -= 1
			print("  → Deshaciendo 1 Directo")
	
	actualizar_contadores_ui()

func lanzar_y_calcular_dados():
	print("🎲 Lanzando dados...")
	if sistema_dados and sistema_dados.has_method("lanzar_todos_los_dados"):
		var resultados = sistema_dados.lanzar_todos_los_dados(cantidad_jugadores)
		print("📊 Resultados: ", resultados)
		return resultados
	else:
		print("❌ Sistema de dados no disponible")
		return null

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
	
	print("  → Resumen del turno:")
	print("     Físico: ", contador_fisico)
	print("     Especial: ", contador_especial)
	print("     Directo: ", contador_directo)
	
	reiniciar_contadores()
	
	indice_jugador_actual += 1
	contador_ok += 1
	
	print("  → OK: ", contador_ok, "/", cantidad_jugadores)
	
	if indice_jugador_actual >= cantidad_jugadores:
		print("🎉 Ronda completa! Mostrando LANZAR")
		btn_lanzar.visible = true
		set_botones_activos(false)
		set_botones_visibles(false)
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
	reiniciar_contadores()
	if dado:
		dado.visible = true
	if animated_dado and animated_dado.sprite_frames and animated_dado.sprite_frames.has_animation("LANZAMIENTO"):
		animated_dado.play("LANZAMIENTO")
		print("🎲 Dado lanzado")
	else:
		print("❌ No se puede reproducir animación LANZAMIENTO del dado")
		set_botones_activos(true)
		set_botones_visibles(true)

func _on_dado_animation_finished():
	if animated_dado and animated_dado.animation == "LANZAMIENTO":
		if dado:
			dado.visible = false
		print("🎲 Animación terminada")
		set_botones_activos(true)
		set_botones_visibles(true)

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
	pass
