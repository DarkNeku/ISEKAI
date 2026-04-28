extends Control

var contador = 1
const MAX = 6
const MIN = 1
const MINIMO_JUGADORES = 3
const NOMBRE_ARCHIVO = "jugadores.json"

@onready var dialogo = $Panel/CONFIRMAR
@onready var btn_listo = null  # Lo vamos a buscar

func _ready():
	print("✅ Script listo para Android")
	print("📁 Ruta Android: ", OS.get_user_data_dir())
	
	# Buscar el botón LISTO dentro de CONT_LISTO_VOLVER
	var contenedor = $Panel/CONT_LISTO_VOLVER
	if contenedor:
		for hijo in contenedor.get_children():
			if hijo is Button:
				btn_listo = hijo
				print("✅ Botón LISTO encontrado: ", hijo.name)
				break
	
	if btn_listo:
		actualizar_boton_listo()
	else:
		print("❌ No se encontró el botón LISTO")
	
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
	nuevo.get_node("CONT_LABEL/LBL_NUMERO").text = " " + str(contador)
	nuevo.get_node("LE_NOMBRE").text = ""
	
	$Panel/LISTA_JUGADORES.add_child(nuevo)
	print("✅ Jugador #", contador)
	
	actualizar_boton_listo()

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
	
	actualizar_boton_listo()

func _on_LISTO_pressed():
	if contador < MINIMO_JUGADORES:
		print("⚠️ Necesitas al menos ", MINIMO_JUGADORES, " jugadores. Actualmente: ", contador)
		mostrar_advertencia()
		return
	
	if dialogo:
		dialogo.popup_centered()

func actualizar_boton_listo():
	if btn_listo:
		if contador < MINIMO_JUGADORES:
			btn_listo.disabled = true
			btn_listo.modulate = Color(0.5, 0.5, 0.5)
			print("🔒 Botón LISTO deshabilitado. Faltan ", MINIMO_JUGADORES - contador, " jugador(es)")
		else:
			btn_listo.disabled = false
			btn_listo.modulate = Color(1, 1, 1)
			print("🔓 Botón LISTO habilitado")

func mostrar_advertencia():
	var advertencia = AcceptDialog.new()
	advertencia.title = "⚠️ Atención"
	advertencia.dialog_text = "Necesitas al menos " + str(MINIMO_JUGADORES) + " jugadores para continuar.\nActualmente tienes: " + str(contador)
	advertencia.ok_button_text = "Entendido"
	advertencia.min_size = Vector2(400, 200)
	add_child(advertencia)
	advertencia.popup_centered()

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
