
extends Node2D

# ==========================================
# RUTAS
# ==========================================

const RUTA_DIALOGOS: String = "res://escenas/escena_1/imagenes/dialogos/"
const RUTA_PUZZLE: String = "res://escenas/escena_1/puzzle_alacena.tscn"

const RUTA_TUTORIAL: String = RUTA_DIALOGOS + "indicaciones/tutorial_movimiento.png"
const RUTA_MISIONES: String = RUTA_DIALOGOS + "misiones/carta_misiones.png"

const MUSICA_ESCENAS = preload("res://audio/musica_escenas.mp3")


# ==========================================
# NODOS
# ==========================================

@onready var video_entrada: VideoStreamPlayer = $CapaVideo/VideoEntrada

@onready var sol = $Sol

@onready var fundido: ColorRect = $Interfaz/Fundido

@onready var dialogos: Control = $Interfaz/Dialogos
@onready var imagen_dialogo: TextureRect = $Interfaz/Dialogos/ImagenDialogo
@onready var boton_siguiente: Button = $Interfaz/Dialogos/BotonSiguiente
@onready var voz_mama: AudioStreamPlayer = $Interfaz/Dialogos/VozMama

@onready var carta_misiones: TextureRect = $Interfaz/CartaMisiones

@onready var flecha_patio: Button = $Interfaz/FlechaPatio


# ==========================================
# DIÁLOGOS INICIALES
# ==========================================

var dialogos_inicio: Array[Dictionary] = [
	{"personaje": "mama", "imagen": RUTA_DIALOGOS + "mama/mama01.png"},
	{"personaje": "sol", "imagen": RUTA_DIALOGOS + "sol/sol01.png"},
	{"personaje": "mama", "imagen": RUTA_DIALOGOS + "mama/mama02.png"},
	{"personaje": "mama", "imagen": RUTA_DIALOGOS + "mama/mama03.png"},
	{"personaje": "mama", "imagen": RUTA_DIALOGOS + "mama/mama04.png"},
	{"personaje": "mama", "imagen": RUTA_DIALOGOS + "mama/mama05.png"},
	{"personaje": "sol", "imagen": RUTA_DIALOGOS + "sol/sol02.png"}
]


# ==========================================
# DIÁLOGOS DESPUÉS DE LA ALACENA
# ==========================================

var dialogos_regreso: Array[Dictionary] = [
	{"personaje": "sol", "imagen": RUTA_DIALOGOS + "sol/sol08.png"},
	{"personaje": "mama", "imagen": RUTA_DIALOGOS + "mama/mama06.png"},
	{"personaje": "mama", "imagen": RUTA_DIALOGOS + "mama/mama07.png"},
	{"personaje": "sol", "imagen": RUTA_DIALOGOS + "sol/sol09.png"},
	{"personaje": "sol", "imagen": RUTA_DIALOGOS + "sol/sol10.png"},
	{"personaje": "mama", "imagen": RUTA_DIALOGOS + "mama/mama08.png"},
	{"personaje": "sol", "imagen": RUTA_DIALOGOS + "sol/sol11.png"}
]


# ==========================================
# VARIABLES
# ==========================================

var secuencia_actual: Array[Dictionary] = []

var indice_dialogo: int = 0

var dialogo_activo: bool = false
var mostrando_tutorial: bool = false
var conversacion_inicial: bool = false

# Recuerda si ya se mostró la conversación
# de regreso durante esta ejecución.
static var regreso_ya_mostrado: bool = false


# ==========================================
# INICIO
# ==========================================

func _ready() -> void:

	# Música de ambiente.
	MusicaGlobal.reproducir(MUSICA_ESCENAS, 3.0)

	# Silenciar audio del video.
	video_entrada.volume_db = -80.0

	# Ocultar interfaces.
	dialogos.hide()
	imagen_dialogo.hide()
	voz_mama.stop()

	# La flecha empieza oculta.
	flecha_patio.hide()

	# Configurar diálogos.
	dialogos.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	configurar_imagen_dialogo()

	boton_siguiente.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	boton_siguiente.mouse_filter = Control.MOUSE_FILTER_STOP
	boton_siguiente.flat = true
	boton_siguiente.text = ""

	# Conectar botón de diálogos.
	if not boton_siguiente.pressed.is_connected(avanzar_dialogo):
		boton_siguiente.pressed.connect(avanzar_dialogo)

	# Conectar voz de mamá.
	if not voz_mama.finished.is_connected(_on_voz_mama_finished):
		voz_mama.finished.connect(_on_voz_mama_finished)

	# Configurar carta de misiones.
	configurar_carta_misiones()

	# ======================================
	# REGRESO DESDE LA ALACENA
	# ======================================

	if ProgresoJuego.alacena_completada:

		video_entrada.stop()
		video_entrada.hide()

		fundido.hide()
		carta_misiones.hide()

		sol.show()
		sol.puede_moverse = false

		if not regreso_ya_mostrado:

			regreso_ya_mostrado = true
			conversacion_inicial = false

			# Todavía no aparece la flecha.
			flecha_patio.hide()

			iniciar_dialogos(dialogos_regreso)

		else:

			# Si vuelve a la cocina después
			# de haber hablado con mamá.
			sol.puede_moverse = true
			flecha_patio.show()

		return

	# ======================================
	# PRIMERA ENTRADA A LA COCINA
	# ======================================

	sol.hide()
	sol.puede_moverse = false

	video_entrada.show()

	fundido.color = Color.BLACK
	fundido.modulate.a = 1.0
	fundido.show()

	if not video_entrada.finished.is_connected(
		_on_video_entrada_finished
	):
		video_entrada.finished.connect(
			_on_video_entrada_finished
		)

	await get_tree().process_frame

	var tween := create_tween()

	tween.tween_property(
		fundido,
		"modulate:a",
		0.0,
		1.5
	)

	await tween.finished

	fundido.hide()


# ==========================================
# CONFIGURAR IMAGEN DE DIÁLOGO
# ==========================================

func configurar_imagen_dialogo() -> void:

	imagen_dialogo.scale = Vector2.ONE

	imagen_dialogo.set_anchors_and_offsets_preset(
		Control.PRESET_BOTTOM_WIDE
	)

	imagen_dialogo.offset_left = 30
	imagen_dialogo.offset_right = -30
	imagen_dialogo.offset_top = -220
	imagen_dialogo.offset_bottom = -20

	imagen_dialogo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	imagen_dialogo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

	imagen_dialogo.mouse_filter = Control.MOUSE_FILTER_IGNORE

	imagen_dialogo.modulate = Color.WHITE
	imagen_dialogo.self_modulate = Color.WHITE


# ==========================================
# CONFIGURAR CARTA DE MISIONES
# ==========================================

func configurar_carta_misiones() -> void:

	carta_misiones.set_anchors_and_offsets_preset(
		Control.PRESET_CENTER_TOP
	)

	# Tamaño grande de la carta.
	carta_misiones.offset_left = -300
	carta_misiones.offset_right = 300
	carta_misiones.offset_top = 20
	carta_misiones.offset_bottom = 210

	carta_misiones.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	carta_misiones.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

	carta_misiones.mouse_filter = Control.MOUSE_FILTER_IGNORE

	carta_misiones.z_index = 10

	if ResourceLoader.exists(RUTA_MISIONES):

		carta_misiones.texture = load(RUTA_MISIONES)

	else:

		push_warning("No se encontró: " + RUTA_MISIONES)

	carta_misiones.hide()


# ==========================================
# TERMINÓ EL VIDEO DE SOL
# ==========================================

func _on_video_entrada_finished() -> void:

	video_entrada.hide()

	sol.show()
	sol.puede_moverse = false

	conversacion_inicial = true

	iniciar_dialogos(dialogos_inicio)


# ==========================================
# INICIAR DIÁLOGOS
# ==========================================

func iniciar_dialogos(nueva_secuencia: Array[Dictionary]) -> void:

	secuencia_actual = nueva_secuencia.duplicate(true)

	indice_dialogo = 0

	dialogo_activo = true
	mostrando_tutorial = false

	sol.puede_moverse = false

	# No mostrar salida mientras se habla.
	flecha_patio.hide()

	configurar_imagen_dialogo()

	dialogos.show()
	imagen_dialogo.show()

	if secuencia_actual.is_empty():

		terminar_dialogos()
		return

	mostrar_dialogo_actual()


# ==========================================
# MOSTRAR DIÁLOGO ACTUAL
# ==========================================

func mostrar_dialogo_actual() -> void:

	if not dialogo_activo:
		return

	var datos: Dictionary = secuencia_actual[indice_dialogo]

	var personaje: String = datos["personaje"]
	var ruta_imagen: String = datos["imagen"]

	voz_mama.stop()

	if ResourceLoader.exists(ruta_imagen):

		imagen_dialogo.texture = load(ruta_imagen)
		imagen_dialogo.show()

	else:

		imagen_dialogo.texture = null
		push_warning("No se encontró: " + ruta_imagen)

	if personaje == "mama" and voz_mama.stream != null:
		voz_mama.play()


# ==========================================
# AVANZAR DIÁLOGOS
# ==========================================

func avanzar_dialogo() -> void:

	# Si está el tutorial, cerrarlo.
	if mostrando_tutorial:

		terminar_tutorial()
		return

	if not dialogo_activo:
		return

	indice_dialogo += 1

	if indice_dialogo >= secuencia_actual.size():

		if conversacion_inicial:

			conversacion_inicial = false

			mostrar_tutorial()

		else:

			terminar_dialogos()

	else:

		mostrar_dialogo_actual()


# ==========================================
# MOSTRAR TUTORIAL DE MOVIMIENTO
# ==========================================

func mostrar_tutorial() -> void:

	dialogo_activo = false
	mostrando_tutorial = true

	sol.puede_moverse = false

	voz_mama.stop()

	imagen_dialogo.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	imagen_dialogo.offset_left = 0
	imagen_dialogo.offset_right = 0
	imagen_dialogo.offset_top = 0
	imagen_dialogo.offset_bottom = 0

	imagen_dialogo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	imagen_dialogo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

	if ResourceLoader.exists(RUTA_TUTORIAL):

		imagen_dialogo.texture = load(RUTA_TUTORIAL)

	else:

		push_warning("No se encontró: " + RUTA_TUTORIAL)

	dialogos.show()
	imagen_dialogo.show()


# ==========================================
# TERMINAR TUTORIAL
# ==========================================

func terminar_tutorial() -> void:

	mostrando_tutorial = false

	imagen_dialogo.hide()
	dialogos.hide()

	configurar_imagen_dialogo()

	if not ProgresoJuego.alacena_completada:
		carta_misiones.show()

	sol.puede_moverse = true

	# Todavía no se puede salir al patio.
	flecha_patio.hide()

	print("Tutorial terminado.")
	print("Carta de misiones visible.")


# ==========================================
# REPETIR VOZ DE MAMÁ
# ==========================================

func _on_voz_mama_finished() -> void:

	if not dialogo_activo:
		return

	if indice_dialogo >= secuencia_actual.size():
		return

	var datos: Dictionary = secuencia_actual[indice_dialogo]

	if datos["personaje"] == "mama" and voz_mama.stream != null:
		voz_mama.play()


# ==========================================
# TERMINAR DIÁLOGOS
# ==========================================

func terminar_dialogos() -> void:

	dialogo_activo = false

	voz_mama.stop()

	imagen_dialogo.hide()
	dialogos.hide()

	sol.puede_moverse = true

	# ======================================
	# DESBLOQUEAR SALIDA AL PATIO
	# ======================================

	if ProgresoJuego.alacena_completada:

		flecha_patio.show()

		print("Terminó la conversación con mamá.")
		print("¡Ahora Sol puede salir al patio!")


# ==========================================
# ABRIR PUZZLE DE ALACENA
# ==========================================

func _on_alacena_abrir_puzzle() -> void:

	if ProgresoJuego.alacena_completada:
		return

	if dialogo_activo or mostrando_tutorial:
		return

	get_tree().call_deferred(
		"change_scene_to_file",
		RUTA_PUZZLE
	)
