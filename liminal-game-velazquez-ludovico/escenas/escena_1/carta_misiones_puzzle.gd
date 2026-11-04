
extends CanvasLayer

const RUTA_MISIONES: String = "res://escenas/escena_1/imagenes/dialogos/misiones/carta_misiones.png"

@onready var carta_misiones: TextureRect = $CartaMisiones


func _ready() -> void:
	# Mantener la carta fija en pantalla.
	layer = 5

	carta_misiones.set_anchors_and_offsets_preset(
		Control.PRESET_CENTER_TOP
	)

	# Tamaño: 600 x 190
	carta_misiones.offset_left = -300
	carta_misiones.offset_right = 300
	carta_misiones.offset_top = 20
	carta_misiones.offset_bottom = 210

	carta_misiones.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	carta_misiones.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	carta_misiones.mouse_filter = Control.MOUSE_FILTER_IGNORE

	carta_misiones.scale = Vector2.ONE
	carta_misiones.modulate = Color.WHITE

	# Cargar la imagen de la misión.
	if ResourceLoader.exists(RUTA_MISIONES):
		carta_misiones.texture = load(RUTA_MISIONES)
	else:
		push_error("No se encontró la carta: " + RUTA_MISIONES)

	# Mostrarla mientras el puzzle esté pendiente.
	carta_misiones.visible = not ProgresoJuego.alacena_completada


func _process(_delta: float) -> void:
	# Cuando el puzzle se completa,
	# la carta desaparece automáticamente.
	if ProgresoJuego.alacena_completada:
		if carta_misiones.visible:
			carta_misiones.hide()
