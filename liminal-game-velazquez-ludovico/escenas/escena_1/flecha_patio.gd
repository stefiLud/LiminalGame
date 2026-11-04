
extends Button

const RUTA_PATIO: String = "res://escenas/escena_2/patio.tscn"


func _ready() -> void:
	# Posicionar flecha en el margen izquierdo.
	set_anchors_and_offsets_preset(
		Control.PRESET_CENTER_LEFT
	)

	offset_left = 20
	offset_right = 110
	offset_top = -55
	offset_bottom = 55

	# Configurar apariencia.
	text = "←"
	add_theme_font_size_override("font_size", 55)

	mouse_filter = Control.MOUSE_FILTER_STOP

	# La flecha empieza oculta.
	hide()

	# Conectar el botón.
	if not pressed.is_connected(ir_al_patio):
		pressed.connect(ir_al_patio)


func ir_al_patio() -> void:
	# No permitir salir antes de completar
	# el puzzle de la alacena.
	if not ProgresoJuego.alacena_completada:
		return

	if not ResourceLoader.exists(RUTA_PATIO):
		push_error("No existe patio.tscn")
		return

	print("Sol sale de la cocina hacia el patio.")

	get_tree().call_deferred(
		"change_scene_to_file",
		RUTA_PATIO
	)
