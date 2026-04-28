# SISTEMA_DADOS.gd - Agregar esta función
extends GridContainer

var cantidad_jugadores = 0
var ultimos_resultados = {}

@onready var lbl_ataf = $Panel/LBL_ATAF
@onready var lbl_atas = $Panel2/LBL_ATAS
@onready var lbl_deff = $Panel3/LBL_DEFF
@onready var lbl_defs = $Panel4/LBL_DEFS

func _ready():
	print("✅ Sistema de dados iniciado")
	visible = true
	limpiar_resultados()

func lanzar_todos_los_dados(num_jugadores: int):
	cantidad_jugadores = num_jugadores
	print("🎲 Sistema de dados: lanzando para ", cantidad_jugadores, " jugadores")
	
	var resultado_ataf = randi_range(0, cantidad_jugadores)
	var resultado_atas = randi_range(0, cantidad_jugadores)
	var resultado_deff = randi_range(0, cantidad_jugadores)
	var resultado_defs = randi_range(0, cantidad_jugadores)
	
	# Guardar resultados
	ultimos_resultados = {
		"ataf": resultado_ataf,
		"atas": resultado_atas,
		"deff": resultado_deff,
		"defs": resultado_defs
	}
	
	actualizar_label(lbl_ataf, resultado_ataf)
	actualizar_label(lbl_atas, resultado_atas)
	actualizar_label(lbl_deff, resultado_deff)
	actualizar_label(lbl_defs, resultado_defs)
	
	print("  → ATAQUE FÍSICO: ", resultado_ataf)
	print("  → ATAQUE ESPECIAL: ", resultado_atas)
	print("  → DEFENSA FÍSICA: ", resultado_deff)
	print("  → DEFENSA ESPECIAL: ", resultado_defs)
	
	return ultimos_resultados

# NUEVA FUNCIÓN: obtener resultados actuales
func get_resultados_actuales() -> Dictionary:
	return ultimos_resultados

func actualizar_label(label: Label, valor: int):
	if label:
		label.text = str(valor)

func limpiar_resultados():
	actualizar_label(lbl_ataf, 0)
	actualizar_label(lbl_atas, 0)
	actualizar_label(lbl_deff, 0)
	actualizar_label(lbl_defs, 0)
	ultimos_resultados = {"ataf": 0, "atas": 0, "deff": 0, "defs": 0}
