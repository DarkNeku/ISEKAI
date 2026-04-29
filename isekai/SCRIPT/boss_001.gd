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
var historial_golpes = []

# Nodos principales
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
@onready var combate = $COMBATE_BOSS_001

# Labels de contadores
@onready var lbl_fisico = $Panel/CONTROL_DANO/GridContainer/Panel_FISICO/LBL_FISICO
@onready var lbl_especial = $Panel/CONTROL_DANO/GridContainer/Panel_ESPECIAL/LBL_ESPECIAL
@onready var lbl_directo = $Panel/CONTROL_DANO/GridContainer/Panel_DIRECTO/LBL_DIRECTO

func _ready():
	cargar_jugadores()
	
	combate.inicializar(
		$Panel/Control/GridContainer/Panel3/LBL_DEFF,
		$Panel/Control/GridContainer/Panel3/LBL_DEFF_2,
		$Panel/Control/GridContainer/Panel4/LBL_DEFS,
		$Panel/Control/GridContainer/Panel4/LBL_DEFS_2,
		$Panel/VIDA_BOSS,
		$Panel/GOLPE_FISICO,
		$Panel/GOLPE_ESPECIAL,
		$Panel/GOLPE_DIRECTO,
		$Panel/ESCUDO_FISICO,
		$Panel/ESCUDO_ESPECIAL,
		$Panel/BOSS_1/AnimatedSprite2D
	)
	
	reproducir_animacion_si_existe($Panel/BOSS_1/AnimatedSprite2D, "QUIETO", "BOSS_1")
	reproducir_animacion_si_existe($Panel/BOSS_2/AnimatedSprite2D, "QUIETO", "BOSS_2")
	
	configurar_barra_vida()
	
	if animated_dado:
		animated_dado.animation_finished.connect(_on_dado_animation_finished)
	
	if btn_lanzar:
		btn_lanzar.pressed.connect(_on_BTN_LANZAR_pressed)
		btn_lanzar.visible = false
	
	if btn_ok:
		btn_ok.pressed.connect(_on_BTN_OK_pressed)
	
	if btn_directo:
		btn_directo.pressed.connect(_on_BTN_DIRECTO_pressed)
	
	if btn_dano_fisico:
		btn_dano_fisico.pressed.connect(_on_BTN_DANO_FISICO_pressed)
	
	if btn_dano_especial:
		btn_dano_especial.pressed.connect(_on_BTN_DANO_ESPECIAL_pressed)
	
	if btn_restar:
		btn_restar.pressed.connect(_on_BTN_RESTAR_pressed)
	
	indice_inicio_ronda = 0
	indice_jugador_actual = 0
	actualizar_nombre_jugador()
	actualizar_contadores_ui()
	ocultar_animaciones()
	
	set_botones_activos(false)
	set_botones_visibles(true)
	
	lanzar_dado()

func ocultar_animaciones():
	for anim in [$Panel/GOLPE_FISICO, $Panel/GOLPE_ESPECIAL, $Panel/GOLPE_DIRECTO, $Panel/ESCUDO_FISICO, $Panel/ESCUDO_ESPECIAL]:
		if anim:
			anim.visible = false

func reproducir_animacion_si_existe(animated_sprite: AnimatedSprite2D, anim_name: String, nombre_nodo: String):
	if animated_sprite and animated_sprite.sprite_frames and animated_sprite.sprite_frames.has_animation(anim_name):
		animated_sprite.play(anim_name)

func actualizar_contadores_ui():
	lbl_fisico.text = str(contador_fisico)
	lbl_especial.text = str(contador_especial)
	lbl_directo.text = str(contador_directo)

func reiniciar_contadores():
	contador_fisico = 0
	contador_especial = 0
	contador_directo = 0
	historial_golpes.clear()
	actualizar_contadores_ui()

func set_botones_visibles(visible: bool):
	for btn in [btn_ok, btn_dano_fisico, btn_dano_especial, btn_directo, btn_restar]:
		if btn:
			btn.visible = visible

func set_botones_activos(activo: bool):
	for btn in [btn_ok, btn_dano_fisico, btn_dano_especial, btn_directo, btn_restar]:
		if btn:
			btn.disabled = !activo

func _on_BTN_DANO_FISICO_pressed():
	contador_fisico += 1
	historial_golpes.append("fisico")
	actualizar_contadores_ui()

func _on_BTN_DANO_ESPECIAL_pressed():
	contador_especial += 1
	historial_golpes.append("especial")
	actualizar_contadores_ui()

func _on_BTN_DIRECTO_pressed():
	contador_directo += 1
	historial_golpes.append("directo")
	actualizar_contadores_ui()

func _on_BTN_RESTAR_pressed():
	if historial_golpes.is_empty():
		return
	var ultimo = historial_golpes.pop_back()
	match ultimo:
		"fisico": contador_fisico -= 1
		"especial": contador_especial -= 1
		"directo": contador_directo -= 1
	actualizar_contadores_ui()

func lanzar_y_calcular_dados():
	if sistema_dados and sistema_dados.has_method("lanzar_todos_los_dados"):
		var resultados = sistema_dados.lanzar_todos_los_dados(cantidad_jugadores)
		combate.actualizar_escudos_con_dados(resultados.get("deff", 0), resultados.get("defs", 0))
		return resultados
	return null

func cargar_jugadores():
	var ruta = "user://jugadores.json"
	if not FileAccess.file_exists(ruta):
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

func obtener_nombre_rotado(indice):
	var posicion_real = (indice_inicio_ronda + indice) % cantidad_jugadores
	return lista_jugadores[posicion_real]

func actualizar_nombre_jugador():
	if lbl_nom_jug and lista_jugadores.size() > 0:
		lbl_nom_jug.text = obtener_nombre_rotado(indice_jugador_actual)

func _on_BTN_OK_pressed():
	# Guardar valores actuales de escudos
	var escudo_fisico_actual = combate.get_escudo_fisico_actual()
	var escudo_especial_actual = combate.get_escudo_especial_actual()
	
	# Determinar orden de ataque (primero el escudo con MENOS vida)
	var atacar_primero_fisico = escudo_fisico_actual <= escudo_especial_actual
	
	print("🎯 ORDEN DE ATAQUE:")
	print("  🛡️ Escudo Físico: ", escudo_fisico_actual)
	print("  🛡️ Escudo Especial: ", escudo_especial_actual)
	print("  → Atacar PRIMERO al: ", "FÍSICO" if atacar_primero_fisico else "ESPECIAL")
	
	# ============================================
	# PASO 1: Atacar al escudo con MENOS vida
	# ============================================
	if atacar_primero_fisico:
		if contador_fisico > 0:
			print("🎬 PASO 1: Atacando escudo FÍSICO (menor)")
			await combate.ejecutar_daño_fisico(contador_fisico)
			await get_tree().create_timer(0.5).timeout
		
		if contador_especial > 0:
			print("🎬 PASO 2: Atacando escudo ESPECIAL (mayor)")
			await combate.ejecutar_daño_especial(contador_especial)
			await get_tree().create_timer(0.5).timeout
	else:
		if contador_especial > 0:
			print("🎬 PASO 1: Atacando escudo ESPECIAL (menor)")
			await combate.ejecutar_daño_especial(contador_especial)
			await get_tree().create_timer(0.5).timeout
		
		if contador_fisico > 0:
			print("🎬 PASO 2: Atacando escudo FÍSICO (mayor)")
			await combate.ejecutar_daño_fisico(contador_fisico)
			await get_tree().create_timer(0.5).timeout
	
	# ============================================
	# PASO 3: Daño DIRECTO (siempre al final)
	# ============================================
	if contador_directo > 0:
		print("🎬 PASO 3: Daño DIRECTO")
		await combate.ejecutar_daño_directo(contador_directo)
		await get_tree().create_timer(0.5).timeout
	
	# Reiniciar contadores
	reiniciar_contadores()
	
	# Cambiar de jugador
	indice_jugador_actual += 1
	contador_ok += 1
	
	if indice_jugador_actual >= cantidad_jugadores:
		btn_lanzar.visible = true
		set_botones_activos(false)
		set_botones_visibles(false)
	else:
		actualizar_nombre_jugador()

func _on_BTN_LANZAR_pressed():
	btn_lanzar.visible = false
	indice_inicio_ronda = (indice_inicio_ronda + 1) % cantidad_jugadores
	indice_jugador_actual = 0
	contador_ok = 0
	actualizar_nombre_jugador()
	combate.reiniciar_escudos()
	lanzar_dado()

func lanzar_dado():
	lanzar_y_calcular_dados()
	reiniciar_contadores()
	dado.visible = true
	animated_dado.play("LANZAMIENTO")

func _on_dado_animation_finished():
	if animated_dado.animation == "LANZAMIENTO":
		dado.visible = false
		$Panel/BOSS_1/AnimatedSprite2D.play("ATAQUE")
		$Panel/BOSS_2/AnimatedSprite2D.play("ATAQUE")
		await get_tree().create_timer(0.7).timeout
		$Panel/BOSS_1/AnimatedSprite2D.play("QUIETO")
		$Panel/BOSS_2/AnimatedSprite2D.play("QUIETO")
		set_botones_activos(true)
		set_botones_visibles(true)

func configurar_barra_vida():
	var barra = $Panel/VIDA_BOSS
	barra.max_value = 100
	barra.min_value = 0
	barra.value = 100
	barra.custom_minimum_size = Vector2(300, 30)
	
	# Conectar señal para detectar cuando la vida llega a 0
	barra.value_changed.connect(_on_vida_cambiada)
	
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

# Señal para detectar cuando la vida cambia
func _on_vida_cambiada(nuevo_valor: float):
	if nuevo_valor <= 0:
		print("💀 BOSS DERROTADO - Activando animación de MUERTE desde señal")
		$Panel/BOSS_1/AnimatedSprite2D.play("MUERTE")
		# Deshabilitar botones al morir
		set_botones_activos(false)
		set_botones_visibles(false)

func _process(_delta):
	pass
