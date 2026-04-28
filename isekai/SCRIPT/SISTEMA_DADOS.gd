# SISTEMA_DADOS.gd
extends GridContainer

# Variables
var cantidad_jugadores = 0

# Referencias a los labels
@onready var lbl_ataf = $Panel/LBL_ATAF
@onready var lbl_atas = $Panel2/LBL_ATAS
@onready var lbl_deff = $Panel3/LBL_DEF
@onready var lbl_defs = $Panel4/LBL_DEFS

func _ready():
	# Ocultar al inicio (opcional)
	visible = true

# Función principal: lanzar todos los dados y actualizar UI
func lanzar_todos_los_dados(num_jugadores: int):
	cantidad_jugadores = num_jugadores
	print("🎲 Sistema de dados: lanzando para ", cantidad_jugadores, " jugadores")
	
	# Calcular resultados aleatorios (0 a cantidad_jugadores)
	var resultado_ataf = randi_range(0, cantidad_jugadores)
	var resultado_atas = randi_range(0, cantidad_jugadores)
	var resultado_deff = randi_range(0, cantidad_jugadores)
	var resultado_defs = randi_range(0, cantidad_jugadores)
	
	# Actualizar labels
	actualizar_label(lbl_ataf, resultado_ataf)
	actualizar_label(lbl_atas, resultado_atas)
	actualizar_label(lbl_deff, resultado_deff)
	actualizar_label(lbl_defs, resultado_defs)
	
	# Imprimir resultados
	print("  → ATAQUE FÍSICO: ", resultado_ataf)
	print("  → ATAQUE ESPECIAL: ", resultado_atas)
	print("  → DEFENSA FÍSICA: ", resultado_deff)
	print("  → DEFENSA ESPECIAL: ", resultado_defs)
	
	return {
		"ataf": resultado_ataf,
		"atas": resultado_atas,
		"deff": resultado_deff,
		"defs": resultado_defs
	}

func actualizar_label(label: Label, valor: int):
	if label:
		label.text = str(valor)

# Función para calcular daño total (ataque - defensa)
func calcular_daño_total() -> int:
	var ataque_total = int(lbl_ataf.text) + int(lbl_atas.text)
	var defensa_total = int(lbl_deff.text) + int(lbl_defs.text)
	var daño = max(0, ataque_total - defensa_total)
	print("  → Daño calculado: ", ataque_total, " - ", defensa_total, " = ", daño)
	return daño

# Función para limpiar los labels
func limpiar_resultados():
	actualizar_label(lbl_ataf, 0)
	actualizar_label(lbl_atas, 0)
	actualizar_label(lbl_deff, 0)
	actualizar_label(lbl_defs, 0)
