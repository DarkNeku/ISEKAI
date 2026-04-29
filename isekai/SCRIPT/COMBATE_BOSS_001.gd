# COMBATE_BOSS_001.gd
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

# ============================================
# CONFIGURACIÓN INICIAL
# ============================================
func inicializar(_lbl_deff: Label, _lbl_deff_2: Label, _lbl_defs: Label, _lbl_defs_2: Label, _barra_vida: ProgressBar):
	lbl_deff = _lbl_deff
	lbl_deff_2 = _lbl_deff_2
	lbl_defs = _lbl_defs
	lbl_defs_2 = _lbl_defs_2
	barra_vida = _barra_vida
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
	
	print("🛡️ Escudos - Físico: ", escudo_fisico_actual, "/", escudo_fisico_base)
	print("🛡️ Escudos - Especial: ", escudo_especial_actual, "/", escudo_especial_base)

# ============================================
# CALCULAR DAÑO FÍSICO
# ============================================
func calcular_daño_fisico(golpes: int) -> int:
	print("⚔️ Daño FÍSICO: ", golpes, " golpes")
	
	if golpes <= 0:
		return 0
	
	if escudo_fisico_actual <= 0:
		print("  → Escudo roto, daño a vida: ", golpes)
		return golpes
	
	var diferencia = escudo_fisico_actual - golpes
	
	if diferencia >= 0:
		escudo_fisico_actual = diferencia
		if lbl_deff_2:
			lbl_deff_2.text = str(escudo_fisico_actual)
		print("  → Escudo queda: ", escudo_fisico_actual, " | Daño: 0")
		return 0
	else:
		var daño_extra = abs(diferencia)
		escudo_fisico_actual = 0
		if lbl_deff_2:
			lbl_deff_2.text = "0"
		print("  → 💔 ESCUDO FÍSICO ROTO! Daño extra: ", daño_extra)
		return daño_extra

# ============================================
# CALCULAR DAÑO ESPECIAL
# ============================================
func calcular_daño_especial(golpes: int) -> int:
	print("🔮 Daño ESPECIAL: ", golpes, " golpes")
	
	if golpes <= 0:
		return 0
	
	if escudo_especial_actual <= 0:
		print("  → Escudo roto, daño a vida: ", golpes)
		return golpes
	
	var diferencia = escudo_especial_actual - golpes
	
	if diferencia >= 0:
		escudo_especial_actual = diferencia
		if lbl_defs_2:
			lbl_defs_2.text = str(escudo_especial_actual)
		print("  → Escudo queda: ", escudo_especial_actual, " | Daño: 0")
		return 0
	else:
		var daño_extra = abs(diferencia)
		escudo_especial_actual = 0
		if lbl_defs_2:
			lbl_defs_2.text = "0"
		print("  → 💔 ESCUDO ESPECIAL ROTO! Daño extra: ", daño_extra)
		return daño_extra

# ============================================
# CALCULAR DAÑO DIRECTO
# ============================================
func calcular_daño_directo(golpes: int) -> int:
	print("⚡ Daño DIRECTO: ", golpes, " golpes")
	
	if golpes <= 0:
		return 0
	
	# Daño directo normal (sin duplicar por ahora)
	return golpes

# ============================================
# APLICAR DAÑO A LA VIDA
# ============================================
func aplicar_daño_a_vida(cantidad: int) -> int:
	if not barra_vida:
		print("❌ Barra de vida no asignada")
		return 0
	
	if cantidad <= 0:
		return 0
	
	var vida_anterior = barra_vida.value
	var vida_nueva = max(0, vida_anterior - cantidad)
	barra_vida.value = vida_nueva
	
	print("💥 Daño a vida: ", cantidad)
	print("  ❤️ Vida: ", vida_anterior, " → ", vida_nueva)
	
	if vida_nueva <= 0:
		print("💀 ¡BOSS DERROTADO!")
	
	return vida_nueva

# ============================================
# REINICIAR ESCUDOS (al lanzar dados)
# ============================================
func reiniciar_escudos():
	escudo_fisico_actual = escudo_fisico_base
	escudo_especial_actual = escudo_especial_base
	
	if lbl_deff_2:
		lbl_deff_2.text = str(escudo_fisico_actual)
	if lbl_defs_2:
		lbl_defs_2.text = str(escudo_especial_actual)
	
	print("🔄 Escudos reiniciados - Físico: ", escudo_fisico_actual, " | Especial: ", escudo_especial_actual)

# ============================================
# OBTENER ESTADO DE ESCUDOS
# ============================================
func is_escudo_fisico_roto() -> bool:
	return escudo_fisico_actual <= 0

func is_escudo_especial_roto() -> bool:
	return escudo_especial_actual <= 0
