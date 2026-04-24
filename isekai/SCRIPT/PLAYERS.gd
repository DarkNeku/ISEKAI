extends Control

var contador = 1
const MAX = 6
const MIN = 1
const NOMBRE_ARCHIVO = "jugadores.json"

@onready var dialogo = $Panel/CONFIRMAR  # Ruta corregida

func _ready():
	print("✅ Script listo para Android")
	print("📁 Ruta Android: ", OS.get_user_data_dir())
	
	# Verificar si el diálogo existe
	if dialogo:
		print("✅ Diálogo CONFIRMAR encontrado")
	else:
		print("❌ No se encontró CONFIRMAR")

func _on_AGREGAR_pressed():
	if contador >= MAX:
		return
	
	contador += 1
	
	var nuevo = $Panel/LISTA_JUGADORES/CONT_JUGADORES.duplicate()
	nuevo.name = "Jugador_" + str(contador)
	nuevo.get_node("CONT_LABEL/LBL_NUMERO").text = "#" + str(contador)
	nuevo.get_node("LE_NOMBRE").text = ""
	
	$Panel/LISTA_JUGADORES.add_child(nuevo)
	print("✅ Jugador #", contador)

func _on_BORRAR_pressed():
	if contador <= MIN:
		return
	
	var hijos = $Panel/LISTA_JUGADORES.get_children()
	
	for i in range(hijos.size() - 1, -1, -1):
		if str(hijos[i].name).begins_with("Jugador_"):
			hijos[i].queue_free()
			contador -= 1
			print("🗑️ Jugador borrado. Quedan: ", contador)
			break

func _on_LISTO_pressed():
	if dialogo:
		dialogo.popup_centered()

func _on_CONFIRMAR_confirmed():
	print("✅ Usuario confirmó")
	guardar_datos()
	cambiar_a_boss()

func guardar_datos():
	print("=== GUARDANDO DATOS ===")
	
	var jugadores_data = []
	var hijos = $Panel/LISTA_JUGADORES.get_children()
	
	for hijo in hijos:
		if hijo.name == "CONT_JUGADORES" or str(hijo.name).begins_with("Jugador_"):
			var nombre = hijo.get_node("LE_NOMBRE").text.strip_edges()
			var numero = hijo.get_node("CONT_LABEL/LBL_NUMERO").text
			
			if nombre != "":
				jugadores_data.append({
					"numero": numero,
					"nombre": nombre
				})
				print("📝 ", numero, " - ", nombre)
	
	if jugadores_data.size() == 0:
		print("❌ No hay jugadores con nombre")
		return
	
	var archivo = FileAccess.open("user://" + NOMBRE_ARCHIVO, FileAccess.WRITE)
	
	if archivo:
		var json_string = JSON.stringify(jugadores_data, "\t")
		archivo.store_string(json_string)
		archivo.close()
		print("✅ ARCHIVO GUARDADO")
		print("📁 Ruta: ", OS.get_user_data_dir(), "/", NOMBRE_ARCHIVO)
		print("✅ Total: ", jugadores_data.size(), " jugadores")
	else:
		print("❌ ERROR: No se pudo guardar")

func cambiar_a_boss():
	print("🔄 Cambiando a escena BOSS_001...")
	get_tree().change_scene_to_file("res://SCENE/BOSS_001.tscn")
