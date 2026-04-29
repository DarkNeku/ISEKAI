# COMBATE_BOSS_001.gd - Sistema de combate Y animaciones
extends Node

# ============================================
# VARIABLES DE ESCUDOS
# ============================================
var escudo_fisico_base: int = 0
var escudo_fisico_actual: int = 0
var escudo_especial_base: int = 0
var escudo_especial_actual: int = 0

# ============================================
# REFERENCIAS A NODOS
# ============================================
var lbl_deff: Label = null
var lbl_deff_2: Label = null
var lbl_defs: Label = null
var lbl_defs_2: Label = null
var barra_vida: ProgressBar = null

# Animaciones
var ani_golpe_fisico: AnimatedSprite2D = null
var ani_golpe_especial: AnimatedSprite2D = null
var ani_golpe_directo: AnimatedSprite2D = null
var ani_escudo_fisico: AnimatedSprite2D = null
var ani_escudo_especial: AnimatedSprite2D = null
var boss_1: AnimatedSprite2D = null

# ============================================
# CONFIGURACIÓN INICIAL
# ============================================
func inicializar(
	_lbl_deff: Label, _lbl_deff_2: Label, _lbl_defs: Label, _lbl_defs_2: Label, _barra_vida: ProgressBar,
	_ani_golpe_fisico: AnimatedSprite2D, _ani_golpe_especial: AnimatedSprite2D, _ani_golpe_directo: AnimatedSprite2D,
	_ani_escudo_fisico: AnimatedSprite2D, _ani_escudo_especial: AnimatedSprite2D, _boss_1: AnimatedSprite2D
):
	lbl_deff = _lbl_deff
	lbl_deff_2 = _lbl_deff_2
	lbl_defs = _lbl_defs
	lbl_defs_2 = _lbl_defs_2
	barra_vida = _barra_vida
	ani_golpe_fisico = _ani_golpe_fisico
	ani_golpe_especial = _ani_golpe_especial
	ani_golpe_directo = _ani_golpe_directo
	ani_escudo_fisico = _ani_escudo_fisico
	ani_escudo_especial = _ani_escudo_especial
	boss_1 = _boss_1
	print("✅ Sistema de combate inicializado")

# ============================================
# ACTUALIZAR ESCUDOS CON NUEVOS DADOS
# ============================================
func actualizar_escudos_con_dados(nuevo_fisico: int, nuevo_especial: int):
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
# CÁLCULOS DE DAÑO
# ============================================
func calcular_daño_fisico(golpes: int) -> int:
	if golpes <= 0:
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
	if golpes <= 0:
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
	return golpes

func aplicar_golpe_fisico() -> int:
	if escudo_fisico_actual <= 0:
		return 1
	
	escudo_fisico_actual -= 1
	actualizar_ui_escudo_fisico()
	
	if escudo_fisico_actual == 0:
		return 1
	return 0

func aplicar_golpe_especial() -> int:
	if escudo_especial_actual <= 0:
		return 1
	
	escudo_especial_actual -= 1
	actualizar_ui_escudo_especial()
	
	if escudo_especial_actual == 0:
		return 1
	return 0

func aplicar_daño_a_vida(cantidad: int) -> int:
	if not barra_vida or cantidad <= 0:
		return 0
	
	var vida_anterior = barra_vida.value
	var vida_nueva = max(0, vida_anterior - cantidad)
	barra_vida.value = vida_nueva
	print("💥 Daño a vida: ", cantidad, " | Vida restante: ", vida_nueva)
	
	# Si la vida llegó a 0 y antes había vida, activar muerte
	if vida_nueva <= 0 and vida_anterior > 0:
		_muerte_boss()
	
	return vida_nueva

func _muerte_boss():
	print("💀 BOSS DERROTADO - Reproduciendo MUERTE")
	if boss_1 and boss_1.sprite_frames and boss_1.sprite_frames.has_animation("MUERTE"):
		boss_1.play("MUERTE")
		# Opcional: detener otras animaciones si es necesario
	else:
		print("❌ Animación MUERTE no encontrada en BOSS_1")

func reiniciar_escudos():
	escudo_fisico_actual = escudo_fisico_base
	escudo_especial_actual = escudo_especial_base
	actualizar_ui_escudo_fisico()
	actualizar_ui_escudo_especial()

func get_escudo_fisico_actual() -> int:
	return escudo_fisico_actual

func get_escudo_especial_actual() -> int:
	return escudo_especial_actual

# ============================================
# FUNCIONES DE ANIMACIÓN (1 segundo cada animación)
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
		print("  ➤ GOLPE FÍSICO al ESCUDO")
		_reproducir_animacion(ani_golpe_fisico, "ANI_GOLPE_FISICO", 1.0)
	else:
		print("  ➤ GOLPE FÍSICO directo a VIDA")
		_reproducir_animacion(ani_golpe_fisico, "ANI_GOLPE_FISICO_2", 1.0)

func _escudo_fisico_activo():
	print("  ➤ ESCUDO FÍSICO recibe daño")
	_reproducir_animacion(ani_escudo_fisico, "ANI_ESCUDO_FISICO_ACTIVO", 1.0)

func _escudo_fisico_roto():
	print("  ➤ 💔 ESCUDO FÍSICO se ROMPE")
	_reproducir_animacion(ani_escudo_fisico, "ANI_ESCUDO_FISICO_ROTO", 1.0)

# ========== ANIMACIONES ESPECIALES ==========
func _golpe_especial(con_escudo: bool):
	if con_escudo:
		print("  ➤ GOLPE ESPECIAL al ESCUDO")
		_reproducir_animacion(ani_golpe_especial, "ANI_GOLPE_ESPECIAL", 1.0)
	else:
		print("  ➤ GOLPE ESPECIAL directo a VIDA")
		_reproducir_animacion(ani_golpe_especial, "ANI_GOLPE_ESPECIAL_2", 1.0)

func _escudo_especial_activo():
	print("  ➤ ESCUDO ESPECIAL recibe daño")
	_reproducir_animacion(ani_escudo_especial, "ANI_ESCUDO_ESPECIAL_ACTIVO", 1.0)

func _escudo_especial_roto():
	print("  ➤ 💔 ESCUDO ESPECIAL se ROMPE")
	_reproducir_animacion(ani_escudo_especial, "ANI_ESCUDO_ESPECIAL_ROTO", 1.0)

# ========== ANIMACIONES DIRECTAS ==========
func _golpe_directo():
	print("  ➤ GOLPE DIRECTO")
	_reproducir_animacion(ani_golpe_directo, "ANI_GOLPE_DIRECTO", 1.0)

# ========== ANIMACIONES COMUNES ==========
func _hit_boss():
	if boss_1 and boss_1.sprite_frames and boss_1.sprite_frames.has_animation("HIT"):
		print("  ➤ BOSS recibe HIT")
		boss_1.play("HIT")
		await get_tree().create_timer(1.0).timeout
		boss_1.play("QUIETO")

# ============================================
# SECUENCIAS COMPLETAS (2 segundos entre golpes)
# ============================================

# SECUENCIA FÍSICA
func ejecutar_daño_fisico(cantidad_golpes: int):
	print("🎬 ===== INICIO SECUENCIA GOLPES FÍSICOS =====")
	print("🔢 Cantidad de golpes: ", cantidad_golpes)
	
	for i in range(cantidad_golpes):
		print("")
		print("  🔹 Golpe FÍSICO ", i + 1, " de ", cantidad_golpes)
		
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
			
			if daño_vida > 0:
				_hit_boss()
				await get_tree().create_timer(0.2).timeout
		else:
			_golpe_fisico(false)
			await get_tree().create_timer(0.2).timeout
			_hit_boss()
			await get_tree().create_timer(0.2).timeout
			aplicar_daño_a_vida(1)
		
		if i < cantidad_golpes - 1:
			print("  ⏱️ Esperando 2 segundos entre golpes...")
			await get_tree().create_timer(0.8).timeout
	
	print("🎬 ===== FIN SECUENCIA GOLPES FÍSICOS =====")

# SECUENCIA ESPECIAL
func ejecutar_daño_especial(cantidad_golpes: int):
	print("🎬 ===== INICIO SECUENCIA GOLPES ESPECIALES =====")
	print("🔢 Cantidad de golpes: ", cantidad_golpes)
	
	for i in range(cantidad_golpes):
		print("")
		print("  🔹 Golpe ESPECIAL ", i + 1, " de ", cantidad_golpes)
		
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
			
			if daño_vida > 0:
				_hit_boss()
				await get_tree().create_timer(0.2).timeout
		else:
			_golpe_especial(false)
			await get_tree().create_timer(0.2).timeout
			_hit_boss()
			await get_tree().create_timer(0.2).timeout
			aplicar_daño_a_vida(1)
		
		if i < cantidad_golpes - 1:
			print("  ⏱️ Esperando 2 segundos entre golpes...")
			await get_tree().create_timer(0.8).timeout
	
	print("🎬 ===== FIN SECUENCIA GOLPES ESPECIALES =====")

# SECUENCIA DIRECTA
func ejecutar_daño_directo(cantidad_golpes: int):
	print("🎬 ===== INICIO SECUENCIA GOLPES DIRECTOS =====")
	print("🔢 Cantidad de golpes: ", cantidad_golpes)
	
	var ambos_escudos_rotos = (escudo_fisico_actual <= 0 and escudo_especial_actual <= 0)
	var daño_por_golpe = 2 if ambos_escudos_rotos else 1
	
	print("  🛡️ Escudo Físico: ", escudo_fisico_actual)
	print("  🛡️ Escudo Especial: ", escudo_especial_actual)
	print("  💥 Daño por golpe: ", daño_por_golpe, " (", "DOBLE" if ambos_escudos_rotos else "NORMAL", ")")
	
	for i in range(cantidad_golpes):
		print("")
		print("  🔹 Golpe DIRECTO ", i + 1, " de ", cantidad_golpes)
		
		_golpe_directo()
		await get_tree().create_timer(0.2).timeout
		_hit_boss()
		await get_tree().create_timer(0.2).timeout
		aplicar_daño_a_vida(daño_por_golpe)
		
		if i < cantidad_golpes - 1:
			print("  ⏱️ Esperando 2 segundos entre golpes...")
			await get_tree().create_timer(0.8).timeout
	
	print("🎬 ===== FIN SECUENCIA GOLPES DIRECTOS =====")
