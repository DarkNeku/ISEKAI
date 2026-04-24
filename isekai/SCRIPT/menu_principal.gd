extends Control

func _ready():
	print("✅ Menú Principal cargado")

func _on_BTN_INICIO_pressed():
	print("🟢 Botón INICIO presionado")
	# Cambiar a la escena de JUGADORES
	get_tree().change_scene_to_file("res://SCENE/PLAYERS.tscn")
