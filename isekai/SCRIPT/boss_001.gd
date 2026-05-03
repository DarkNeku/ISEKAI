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

# Sistema adaptativo
var defensa_base_actual: int = 0
var rondas_desde_ajuste: int = 0
var danio_recibido_ultimas_rondas: int = 0
var ultima_vida_boss: float = 0

# Control de fases
var fase_2_activada: bool = false

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
@onready var boss_1_anim = $Panel/BOSS_1/AnimatedSprite2D

# Labels de contadores
@onready var lbl_fisico = $Panel/CONTROL_DANO/GridContainer/Panel_FISICO/LBL_FISICO
@onready var lbl_especial = $Panel/CONTROL_DANO/GridContainer/Panel_ESPECIAL/LBL_ESPECIAL
@onready var lbl_directo = $Panel/CONTROL_DANO/GridContainer/Panel_DIRECTO/LBL_DIRECTO

func _ready():
	cargar_jugadores()
	
	# Configurar defensa base según cantidad de jugadores
	if cantidad_jugadores <= 4:
		defensa_base_actual = 2
	else:
		defensa_base_actual = 3
	print("🛡️ Defensa base inicial: ", defensa_base_actual)
	
	# Configurar vida según cantidad de jugadores
	configurar_vida_segun_jugadores()
	
	# Buscar labels de forma segura
	var lbl_deff = find_child("LBL_DEFF", true, false)
	var lbl_deff_2 = find_child("LBL_DEFF_2", true, false)
	var lbl_defs = find_child("LBL_DEFS", true, false)
	var lbl_defs_2 = find_child("LBL_DEFS_2", true, false)
	var lbl_ataf = find_child("LBL_ATAF", true, false)
	var lbl_atas = find_child("LBL_ATAS", true, false)
	
	var callback = Callable(self, "actualizar_contadores_en_tiempo_real")
	
	combate.inicializar(
		lbl_deff, lbl_deff_2, lbl_defs, lbl_defs_2, $Panel/VIDA_BOSS,
		lbl_ataf, lbl_atas,
		$Panel/GOLPE_FISICO, $Panel/GOLPE_ESPECIAL, $Panel/GOLPE_DIRECTO,
		$Panel/ESCUDO_FISICO, $Panel/ESCUDO_ESPECIAL, boss_1_anim, callback
	)
	
	combate.boss_derrotado.connect(_on_boss_1_derrotado)
	
	reproducir_animacion_si_existe(boss_1_anim, "QUIETO", "BOSS_1")
	configurar_barra_vida()
	
	ultima_vida_boss = $Panel/VIDA_BOSS.value
	
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

func ajustar_defensa_segun_danio():
	if rondas_desde_ajuste < 2:
		return
	
	var promedio_danio = danio_recibido_ultimas_rondas / 2.0
	var danio_por_jugador = promedio_danio / cantidad_jugadores
	
	print("📊 Análisis de las últimas 2 rondas:")
	print("  - Daño total: ", danio_recibido_ultimas_rondas)
	print("  - Promedio por ronda: ", promedio_danio)
	print("  - Daño por jugador: ", danio_por_jugador)
	
	if danio_por_jugador > 3:
		defensa_base_actual += 1
		print("🛡️ Los jugadores hicieron MUCHO daño (+1 defensa)")
	elif danio_por_jugador < 1.5:
		defensa_base_actual = max(1, defensa_base_actual - 1)
		print("🛡️ Los jugadores hicieron POCO daño (-1 defensa)")
	else:
		print("🛡️ Defensa equilibrada, se mantiene")
	
	defensa_base_actual = clamp(defensa_base_actual, 1, 6)
	print("  → Nueva defensa base: ", defensa_base_actual)
	
	danio_recibido_ultimas_rondas = 0

func configurar_vida_segun_jugadores():
	var vida_maxima = 20 + (cantidad_jugadores * 10)
	var barra = $Panel/VIDA_BOSS
	barra.max_value = vida_maxima
	barra.value = vida_maxima
	print("❤️ Vida del boss configurada: ", vida_maxima, " para ", cantidad_jugadores, " jugadores")

func actualizar_contadores_en_tiempo_real(fisico: int, especial: int, directo: int):
	if fisico >= 0:
		lbl_fisico.text = str(fisico)
	if especial >= 0:
		lbl_especial.text = str(especial)
	if directo >= 0:
		lbl_directo.text = str(directo)

func _on_boss_1_derrotado():
	print("💀 BOSS_1 derrotado")
	set_botones_activos(false)
	set_botones_visibles(false)
	btn_lanzar.visible = false

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
	if combate.is_boss_muerto():
		return
	contador_fisico += 1
	historial_golpes.append("fisico")
	actualizar_contadores_ui()

func _on_BTN_DANO_ESPECIAL_pressed():
	if combate.is_boss_muerto():
		return
	contador_especial += 1
	historial_golpes.append("especial")
	actualizar_contadores_ui()

func _on_BTN_DIRECTO_pressed():
	if combate.is_boss_muerto():
		return
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
		print("🎲 Resultados dados -> ATAF: ", resultados.get("ataf", 0), " | ATAS: ", resultados.get("atas", 0))
		
		# Escudos: base de 1 a 10
		var escudo_fisico = randi_range(1, 10)
		var escudo_especial = randi_range(1, 10)
		
		# Verificar si el boss tiene menos del 50% de vida
		var vida_actual = $Panel/VIDA_BOSS.value
		var vida_maxima = $Panel/VIDA_BOSS.max_value
		var porcentaje_vida = (vida_actual / vida_maxima) * 100
		
		if porcentaje_vida <= 50:
			# Si vida ≤ 50%, se suma un dado de 1 a 4
			escudo_fisico += randi_range(1, 4)
			escudo_especial += randi_range(1, 4)
			print("🛡️ ESCUDOS BOOSTEADOS (vida ≤ 50%): +1d4")
		
		print("🛡️ Escudos finales -> Físico: ", escudo_fisico, " | Especial: ", escudo_especial)
		
		if not combate.is_boss_muerto():
			combate.actualizar_escudos_con_dados(escudo_fisico, escudo_especial)
		
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
	if combate.is_boss_muerto():
		print("⚠️ BOSS_1 ya está muerto, no se puede atacar")
		return
	
	# Guardar vida antes del daño
	var vida_antes = $Panel/VIDA_BOSS.value
	
	var escudo_fisico_actual = combate.get_escudo_fisico_actual()
	var escudo_especial_actual = combate.get_escudo_especial_actual()
	
	var atacar_primero_fisico = escudo_fisico_actual <= escudo_especial_actual
	
	print("🎯 ORDEN DE ATAQUE:")
	print("  🛡️ Escudo Físico: ", escudo_fisico_actual)
	print("  🛡️ Escudo Especial: ", escudo_especial_actual)
	
	if atacar_primero_fisico:
		if contador_fisico > 0:
			await combate.ejecutar_daño_fisico(contador_fisico, contador_fisico)
			await get_tree().create_timer(0.5).timeout
		
		if contador_especial > 0:
			await combate.ejecutar_daño_especial(contador_especial, contador_especial)
			await get_tree().create_timer(0.5).timeout
	else:
		if contador_especial > 0:
			await combate.ejecutar_daño_especial(contador_especial, contador_especial)
			await get_tree().create_timer(0.5).timeout
		
		if contador_fisico > 0:
			await combate.ejecutar_daño_fisico(contador_fisico, contador_fisico)
			await get_tree().create_timer(0.5).timeout
	
	if contador_directo > 0:
		await combate.ejecutar_daño_directo(contador_directo, contador_directo)
		await get_tree().create_timer(0.5).timeout
	
	# Calcular daño de esta ronda
	var vida_despues = $Panel/VIDA_BOSS.value
	var daño_ronda = vida_antes - vida_despues
	danio_recibido_ultimas_rondas += daño_ronda
	
	combate.reiniciar_contadores_escudos()
	reiniciar_contadores()
	
	indice_jugador_actual += 1
	contador_ok += 1
	
	if indice_jugador_actual >= cantidad_jugadores:
		btn_lanzar.visible = true
		set_botones_activos(false)
		set_botones_visibles(false)
	else:
		actualizar_nombre_jugador()

func _on_BTN_LANZAR_pressed():
	if combate.is_boss_muerto():
		return
	
	combate.ejecutar_ataque_boss()
	
	# Cada 2 rondas, ajustar defensa
	rondas_desde_ajuste += 1
	if rondas_desde_ajuste >= 2:
		ajustar_defensa_segun_danio()
		rondas_desde_ajuste = 0
	
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
		
		if combate.is_boss_muerto():
			set_botones_activos(false)
			set_botones_visibles(false)
			btn_lanzar.visible = false
			return
		
		boss_1_anim.play("ATAQUE")
		await get_tree().create_timer(0.7).timeout
		
		if not combate.is_boss_muerto():
			boss_1_anim.play("QUIETO")
		
		set_botones_activos(true)
		set_botones_visibles(true)

func configurar_barra_vida():
	var barra = $Panel/VIDA_BOSS
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

func _process(_delta):
	pass
