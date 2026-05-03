# COMBATE_BOSS_001.gd - Sistema de combate Y animaciones para BOSS_1
extends Node

signal boss_derrotado
signal boss_ataca

# ============================================
# VARIABLES DE ESCUDOS
# ============================================
var escudo_fisico_base: int = 0
var escudo_fisico_actual: int = 0
var escudo_especial_base: int = 0
var escudo_especial_actual: int = 0
var boss_muerto: bool = false

# ============================================
# REFERENCIAS A NODOS
# ============================================
var lbl_deff: Label = null
var lbl_deff_2: Label = null
var lbl_defs: Label = null
var lbl_defs_2: Label = null
var barra_vida: ProgressBar = null
var lbl_ataf: Label = null
var lbl_atas: Label = null

# Animaciones
var ani_golpe_fisico: AnimatedSprite2D = null
var ani_golpe_especial: AnimatedSprite2D = null
var ani_golpe_directo: AnimatedSprite2D = null
var ani_escudo_fisico: AnimatedSprite2D = null
var ani_escudo_especial: AnimatedSprite2D = null
var boss_1: AnimatedSprite2D = null

# Callback para actualizar UI de contadores
var actualizar_contadores_callback: Callable = Callable()

# ============================================
# CONFIGURACIÓN INICIAL
# ============================================
func inicializar(
	_lbl_deff: Label, _lbl_deff_2: Label, _lbl_defs: Label, _lbl_defs_2: Label, _barra_vida: ProgressBar,
	_lbl_ataf: Label, _lbl_atas: Label,
	_ani_golpe_fisico: AnimatedSprite2D, _ani_golpe_especial: AnimatedSprite2D, _ani_golpe_directo: AnimatedSprite2D,
	_ani_escudo_fisico: AnimatedSprite2D, _ani_escudo_especial: AnimatedSprite2D, _boss_1: AnimatedSprite2D,
	_callback: Callable
):
	lbl_deff = _lbl_deff
	lbl_deff_2 = _lbl_deff_2
	lbl_defs = _lbl_defs
	lbl_defs_2 = _lbl_defs_2
	barra_vida = _barra_vida
	lbl_ataf = _lbl_ataf
	lbl_atas = _lbl_atas
	ani_golpe_fisico = _ani_golpe_fisico
	ani_golpe_especial = _ani_golpe_especial
	ani_golpe_directo = _ani_golpe_directo
	ani_escudo_fisico = _ani_escudo_fisico
	ani_escudo_especial = _ani_escudo_especial
	boss_1 = _boss_1
	boss_muerto = false
	actualizar_contadores_callback = _callback
	print("✅ Sistema de combate BOSS_1 inicializado")

# ============================================
# ACTUALIZAR ESCUDOS CON NUEVOS DADOS
# ============================================
func actualizar_escudos_con_dados(nuevo_fisico: int, nuevo_especial: int):
	if boss_muerto:
		return
	
	escudo_fisico_base = nuevo_fisico
	escudo_fisico_actual = nuevo_fisico
	escudo_especial_base = nuevo_especial
	escudo_especial_actual = nuevo_especial
	
	if lbl_deff:
		lbl_deff.text = str(escudo_fisico_base)
	if lbl_deff_2:
		lbl_deff_2.text = str(escudo_fisico_actual)
	if lbl_defs:
		lbl_defs.text = str(escudo_especial_base)
	if lbl_defs_2:
		lbl_defs_2.text = str(escudo_especial_actual)
	
	print("🛡️ Escudos BOSS_1 -> Físico: ", escudo_fisico_actual, "/", escudo_fisico_base)
	print("🛡️ Escudos BOSS_1 -> Especial: ", escudo_especial_actual, "/", escudo_especial_base)

# ============================================
# ACTUALIZAR UI DE ESCUDOS EN TIEMPO REAL
# ============================================
func actualizar_ui_escudo_fisico():
	if lbl_deff_2:
		lbl_deff_2.text = str(escudo_fisico_actual)

func actualizar_ui_escudo_especial():
	if lbl_defs_2:
		lbl_defs_2.text = str(escudo_especial_actual)

# ============================================
# ATAQUE DEL BOSS A LOS JUGADORES
# ============================================
func ejecutar_ataque_boss():
	if boss_muerto:
		return
	
	var vida_actual = barra_vida.value
	var vida_maxima = barra_vida.max_value
	var porcentaje_vida = (vida_actual / vida_maxima) * 100
	
	var daño_fisico: int
	var daño_especial: int
	
	if porcentaje_vida > 50:
		daño_fisico = randi_range(1, 10)
		daño_especial = randi_range(1, 10)
		print("💀 ATAQUE BOSS (vida > 50%): Físico: ", daño_fisico, " | Especial: ", daño_especial)
	else:
		daño_fisico = randi_range(1, 10) + randi_range(1, 4)
		daño_especial = randi_range(1, 10) + randi_range(1, 4)
		print("💀 ATAQUE BOSS (vida ≤ 50% - BOOST): Físico: ", daño_fisico, " | Especial: ", daño_especial)
	
	if lbl_ataf:
		lbl_ataf.text = str(daño_fisico)
	if lbl_atas:
		lbl_atas.text = str(daño_especial)

# ============================================
# CÁLCULOS DE DAÑO
# ============================================
func calcular_daño_fisico(golpes: int) -> int:
	if boss_muerto or golpes <= 0:
		return 0
	
	if escudo_fisico_actual <= 0:
		return golpes
	
	var diferencia = escudo_fisico_actual - golpes
	if diferencia >= 0:
		escudo_fisico_actual = diferencia
		if lbl_deff_2:
			lbl_deff_2.text = str(escudo_fisico_actual)
		return 0
	else:
		var daño_extra = abs(diferencia)
		escudo_fisico_actual = 0
		if lbl_deff_2:
			lbl_deff_2.text = "0"
		return daño_extra

func calcular_daño_especial(golpes: int) -> int:
	if boss_muerto or golpes <= 0:
		return 0
	
	if escudo_especial_actual <= 0:
		return golpes
	
	var diferencia = escudo_especial_actual - golpes
	if diferencia >= 0:
		escudo_especial_actual = diferencia
		if lbl_defs_2:
			lbl_defs_2.text = str(escudo_especial_actual)
		return 0
	else:
		var daño_extra = abs(diferencia)
		escudo_especial_actual = 0
		if lbl_defs_2:
			lbl_defs_2.text = "0"
		return daño_extra

func calcular_daño_directo(golpes: int) -> int:
	if boss_muerto:
		return 0
	return golpes

# ============================================
# APLICAR GOLPES
# ============================================
func aplicar_golpe_fisico() -> int:
	if boss_muerto:
		return 0
	
	if escudo_fisico_actual <= 0:
		escudo_fisico_actual -= 1
		actualizar_ui_escudo_fisico()
		return 1
	
	escudo_fisico_actual -= 1
	actualizar_ui_escudo_fisico()
	
	if escudo_fisico_actual < 0:
		return 1
	return 0

func aplicar_golpe_especial() -> int:
	if boss_muerto:
		return 0
	
	if escudo_especial_actual <= 0:
		escudo_especial_actual -= 1
		actualizar_ui_escudo_especial()
		return 1
	
	escudo_especial_actual -= 1
	actualizar_ui_escudo_especial()
	
	if escudo_especial_actual < 0:
		return 1
	return 0

func aplicar_daño_a_vida(cantidad: int) -> int:
	if boss_muerto or not barra_vida or cantidad <= 0:
		return 0
	
	var vida_anterior = barra_vida.value
	var vida_nueva = max(0, vida_anterior - cantidad)
	barra_vida.value = vida_nueva
	print("💥 Daño a BOSS_1: ", cantidad, " | Vida restante: ", vida_nueva, "/", barra_vida.max_value)
	
	if vida_nueva <= 0 and vida_anterior > 0:
		boss_muerto = true
		boss_derrotado.emit()
		_muerte_boss()
	
	return vida_nueva

func reiniciar_contadores_escudos():
	if escudo_fisico_actual < 0:
		escudo_fisico_actual = 0
	if escudo_especial_actual < 0:
		escudo_especial_actual = 0
	actualizar_ui_escudo_fisico()
	actualizar_ui_escudo_especial()
	print("🔄 Contadores de escudos BOSS_1 reiniciados a 0")

func reiniciar_escudos():
	if boss_muerto:
		return
	
	escudo_fisico_actual = escudo_fisico_base
	escudo_especial_actual = escudo_especial_base
	actualizar_ui_escudo_fisico()
	actualizar_ui_escudo_especial()

func get_escudo_fisico_actual() -> int:
	return escudo_fisico_actual

func get_escudo_especial_actual() -> int:
	return escudo_especial_actual

func is_boss_muerto() -> bool:
	return boss_muerto

func get_vida_actual() -> float:
	if barra_vida:
		return barra_vida.value
	return 0

func get_vida_maxima() -> float:
	if barra_vida:
		return barra_vida.max_value
	return 100

# ============================================
# FUNCIONES DE ANIMACIÓN
# ============================================
func _reproducir_animacion(sprite: AnimatedSprite2D, anim_name: String, duracion: float = 1.0):
	if not sprite or not sprite.sprite_frames:
		return
	if not sprite.sprite_frames.has_animation(anim_name):
		print("❌ ", sprite.name, " no tiene animación: ", anim_name)
		return
	
	sprite.visible = true
	sprite.play(anim_name)
	await get_tree().create_timer(duracion).timeout
	sprite.visible = false
	sprite.stop()

# ========== ANIMACIONES FÍSICAS ==========
func _golpe_fisico(con_escudo: bool):
	if con_escudo:
		print("  ➤ GOLPE FÍSICO al ESCUDO BOSS_1")
		_reproducir_animacion(ani_golpe_fisico, "ANI_GOLPE_FISICO", 1.0)
	else:
		print("  ➤ GOLPE FÍSICO directo a VIDA BOSS_1")
		_reproducir_animacion(ani_golpe_fisico, "ANI_GOLPE_FISICO_2", 1.0)

func _escudo_fisico_activo():
	print("  ➤ ESCUDO FÍSICO BOSS_1 recibe daño")
	_reproducir_animacion(ani_escudo_fisico, "ANI_ESCUDO_FISICO_ACTIVO", 1.0)

func _escudo_fisico_roto():
	print("  ➤ 💔 ESCUDO FÍSICO BOSS_1 se ROMPE")
	_reproducir_animacion(ani_escudo_fisico, "ANI_ESCUDO_FISICO_ROTO", 1.0)

# ========== ANIMACIONES ESPECIALES ==========
func _golpe_especial(con_escudo: bool):
	if con_escudo:
		print("  ➤ GOLPE ESPECIAL al ESCUDO BOSS_1")
		_reproducir_animacion(ani_golpe_especial, "ANI_GOLPE_ESPECIAL", 1.0)
	else:
		print("  ➤ GOLPE ESPECIAL directo a VIDA BOSS_1")
		_reproducir_animacion(ani_golpe_especial, "ANI_GOLPE_ESPECIAL_2", 1.0)

func _escudo_especial_activo():
	print("  ➤ ESCUDO ESPECIAL BOSS_1 recibe daño")
	_reproducir_animacion(ani_escudo_especial, "ANI_ESCUDO_ESPECIAL_ACTIVO", 1.0)

func _escudo_especial_roto():
	print("  ➤ 💔 ESCUDO ESPECIAL BOSS_1 se ROMPE")
	_reproducir_animacion(ani_escudo_especial, "ANI_ESCUDO_ESPECIAL_ROTO", 1.0)

# ========== ANIMACIONES DIRECTAS ==========
func _golpe_directo():
	print("  ➤ GOLPE DIRECTO a BOSS_1")
	_reproducir_animacion(ani_golpe_directo, "ANI_GOLPE_DIRECTO", 1.0)

# ========== ANIMACIONES COMUNES ==========
func _hit_boss():
	if boss_muerto:
		return
	if boss_1 and boss_1.sprite_frames and boss_1.sprite_frames.has_animation("HIT"):
		print("  ➤ BOSS_1 recibe HIT")
		boss_1.play("HIT")
		await get_tree().create_timer(1.0).timeout
		if not boss_muerto:
			boss_1.play("QUIETO")

func _muerte_boss():
	print("💀 BOSS_1 DERROTADO - Reproduciendo MUERTE")
	if boss_1 and boss_1.sprite_frames and boss_1.sprite_frames.has_animation("MUERTE"):
		boss_1.play("MUERTE")
	else:
		print("❌ Animación MUERTE no encontrada en BOSS_1")
		boss_1.visible = false

# ============================================
# SECUENCIAS COMPLETAS
# ============================================

func ejecutar_daño_fisico(cantidad_golpes: int, contador_original: int):
	if boss_muerto:
		print("⚠️ BOSS_1 ya está muerto, no se ejecuta daño físico")
		return
	
	print("🎬 ===== INICIO SECUENCIA GOLPES FÍSICOS BOSS_1 =====")
	print("🔢 Cantidad de golpes: ", cantidad_golpes)
	
	for i in range(cantidad_golpes):
		if boss_muerto:
			break
		
		print("")
		print("  🔹 Golpe FÍSICO BOSS_1 ", i + 1, " de ", cantidad_golpes)
		
		var golpes_restantes = cantidad_golpes - i - 1
		if actualizar_contadores_callback.is_valid():
			actualizar_contadores_callback.call(golpes_restantes, -1, -1)
		
		var escudo_antes = escudo_fisico_actual
		var golpe_con_escudo = escudo_antes > 0
		
		if golpe_con_escudo:
			_golpe_fisico(true)
			await get_tree().create_timer(0.2).timeout
			
			var daño_vida = aplicar_golpe_fisico()
			
			if escudo_fisico_actual == 0 and escudo_antes > 0:
				_escudo_fisico_roto()
			else:
				_escudo_fisico_activo()
			await get_tree().create_timer(0.2).timeout
			
			if daño_vida > 0 and not boss_muerto:
				_hit_boss()
				await get_tree().create_timer(0.2).timeout
		else:
			_golpe_fisico(false)
			await get_tree().create_timer(0.2).timeout
			if not boss_muerto:
				_hit_boss()
			await get_tree().create_timer(0.2).timeout
			if not boss_muerto:
				aplicar_daño_a_vida(1)
		
		if i < cantidad_golpes - 1 and not boss_muerto:
			print("  ⏱️ Esperando 0.8 segundos entre golpes...")
			await get_tree().create_timer(0.8).timeout
	
	if actualizar_contadores_callback.is_valid():
		actualizar_contadores_callback.call(0, -1, -1)
	
	print("🎬 ===== FIN SECUENCIA GOLPES FÍSICOS BOSS_1 =====")

func ejecutar_daño_especial(cantidad_golpes: int, contador_original: int):
	if boss_muerto:
		print("⚠️ BOSS_1 ya está muerto, no se ejecuta daño especial")
		return
	
	print("🎬 ===== INICIO SECUENCIA GOLPES ESPECIALES BOSS_1 =====")
	print("🔢 Cantidad de golpes: ", cantidad_golpes)
	
	for i in range(cantidad_golpes):
		if boss_muerto:
			break
		
		print("")
		print("  🔹 Golpe ESPECIAL BOSS_1 ", i + 1, " de ", cantidad_golpes)
		
		var golpes_restantes = cantidad_golpes - i - 1
		if actualizar_contadores_callback.is_valid():
			actualizar_contadores_callback.call(-1, golpes_restantes, -1)
		
		var escudo_antes = escudo_especial_actual
		var golpe_con_escudo = escudo_antes > 0
		
		if golpe_con_escudo:
			_golpe_especial(true)
			await get_tree().create_timer(0.2).timeout
			
			var daño_vida = aplicar_golpe_especial()
			
			if escudo_especial_actual == 0 and escudo_antes > 0:
				_escudo_especial_roto()
			else:
				_escudo_especial_activo()
			await get_tree().create_timer(0.2).timeout
			
			if daño_vida > 0 and not boss_muerto:
				_hit_boss()
				await get_tree().create_timer(0.2).timeout
		else:
			_golpe_especial(false)
			await get_tree().create_timer(0.2).timeout
			if not boss_muerto:
				_hit_boss()
			await get_tree().create_timer(0.2).timeout
			if not boss_muerto:
				aplicar_daño_a_vida(1)
		
		if i < cantidad_golpes - 1 and not boss_muerto:
			print("  ⏱️ Esperando 0.8 segundos entre golpes...")
			await get_tree().create_timer(0.8).timeout
	
	if actualizar_contadores_callback.is_valid():
		actualizar_contadores_callback.call(-1, 0, -1)
	
	print("🎬 ===== FIN SECUENCIA GOLPES ESPECIALES BOSS_1 =====")

func ejecutar_daño_directo(cantidad_golpes: int, contador_original: int):
	if boss_muerto:
		print("⚠️ BOSS_1 ya está muerto, no se ejecuta daño directo")
		return
	
	print("🎬 ===== INICIO SECUENCIA GOLPES DIRECTOS BOSS_1 =====")
	print("🔢 Cantidad de golpes: ", cantidad_golpes)
	
	var ambos_escudos_rotos = (escudo_fisico_actual <= 0 and escudo_especial_actual <= 0)
	var daño_por_golpe = 2 if ambos_escudos_rotos else 1
	
	print("  🛡️ Escudo Físico BOSS_1: ", escudo_fisico_actual)
	print("  🛡️ Escudo Especial BOSS_1: ", escudo_especial_actual)
	print("  💥 Daño por golpe: ", daño_por_golpe, " (", "DOBLE" if ambos_escudos_rotos else "NORMAL", ")")
	
	for i in range(cantidad_golpes):
		if boss_muerto:
			break
		
		print("")
		print("  🔹 Golpe DIRECTO BOSS_1 ", i + 1, " de ", cantidad_golpes)
		
		var golpes_restantes = cantidad_golpes - i - 1
		if actualizar_contadores_callback.is_valid():
			actualizar_contadores_callback.call(-1, -1, golpes_restantes)
		
		_golpe_directo()
		await get_tree().create_timer(0.2).timeout
		if not boss_muerto:
			_hit_boss()
		await get_tree().create_timer(0.2).timeout
		if not boss_muerto:
			aplicar_daño_a_vida(daño_por_golpe)
		
		if i < cantidad_golpes - 1 and not boss_muerto:
			print("  ⏱️ Esperando 0.8 segundos entre golpes...")
			await get_tree().create_timer(0.8).timeout
	
	if actualizar_contadores_callback.is_valid():
		actualizar_contadores_callback.call(-1, -1, 0)
	
	print("🎬 ===== FIN SECUENCIA GOLPES DIRECTOS BOSS_1 =====")
