extends LineEdit

func _ready():
	text_changed.connect(_on_text_changed)

func _on_text_changed(nuevo_texto: String):
	# Guardar posición del cursor
	var pos_actual = caret_column
	# Convertir a mayúsculas
	text = nuevo_texto.to_upper()
	# Restaurar posición del cursor
	caret_column = min(pos_actual, text.length())
