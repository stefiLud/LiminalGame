
extends Node2D

# ==========================================
# RUTAS
# ==========================================

const RUTA_DIALOGOS: String = "res://escenas/escena_1/imagenes/dialogos/"
const RUTA_COCINA: String = "res://escenas/escena_1/cocina.tscn"


# ==========================================
# NODOS
# ==========================================

@onready var carita_sharon: TextureButton = $SharonUI/CaritaSharon
@onready var dialogo_sharon: TextureRect = $SharonUI/DialogoSharon
@onready var sonido_sharon: AudioStreamPlayer = $SharonUI/SonidoSharon
@onready var vineta_rosa: TextureRect = $SharonUI/VinetaRosa

@onready var palo_rosa: Sprite2D = $Objetos/PaloAmasar/PaloRosa
@onready var oso_rosa: Sprite2D = $Objetos/Oso/OsoRosa


# ==========================================
# DIÁLOGOS DE SHARON Y SOL
# ==========================================

var dialogos_sharon: Array[Dictionary] = [
	{"personaje": "sharon", "imagen": RUTA_DIALOGOS + "sharon/sharon01.png"},
	{"personaje": "sharon", "imagen": RUTA_DIALOGOS + "sharon/sharon02.png"},
	{"personaje": "sol", "imagen": RUTA_DIALOGOS + "sol/sol03.png"},
	{"personaje": "sharon", "imagen": RUTA_DIALOGOS + "sharon/sharon03.png"},
	{"personaje": "sol", "imagen": RUTA_DIALOGOS + "sol/sol04.png"},
	{"personaje": "sol", "imagen": RUTA_DIALOGOS + "sol/sol05.png"},
	{"personaje": "sharon", "imagen": RUTA_DIALOGOS + "sharon/sharon04.png"},
	{"personaje": "sol", "imagen": RUTA_DIALOGOS + "sol/sol06.png"}
]


# ==========================================
# VARIABLES
# ==========================================

var objetos_encontrados: Array[String] = []

var objetos_obligatorios: Array[String] = [
	"Cuchara",
	"PaloAmasar",
	"Receta"
]

var puzzle_terminado: bool = false
var indice_sharon: int = 0

# ESTADOS DE SHARON
# 0 = Buscando los tres objetos
# 1 = Conversación activa
# 2 = Pista de Sharon visible
# 3 = Oso desbloqueado
# 4 = Transición de la pista

var estado_sharon: int = 0
var bloquear_click_hasta: int = 0


# ==========================================
# INICIO
# ==========================================

func _ready() -> void:

	# La música de MusicaGlobal continúa
	# desde la cocina sin reiniciarse.

	dialogo_sharon.hide()
	carita_sharon.hide()
	vineta_rosa.hide()

	# El palo ya no es la pista.
	palo_rosa.hide()

	# El oso rosa aparece más adelante.
	oso_rosa.hide()

	configurar_interfaz_sharon()

	# Conectar carita de Sharon.
	if not carita_sharon.pressed.is_connected(
		_on_carita_sharon_pressed
	):
		carita_sharon.pressed.connect(
			_on_carita_sharon_pressed
		)

	# Conectar objetos.
	for nombre in ["Cuchara", "PaloAmasar", "Receta", "Oso"]:

		var objeto: Area2D = get_node(
			"Objetos/" + nombre
		)

		objeto.input_pickable = true

		var callback := _on_objeto_click.bind(nombre)

		if not objeto.input_event.is_connected(callback):
			objeto.input_event.connect(callback)

		# Crear tilde verde.
		if not objeto.has_node("Tilde"):

			var tilde := Label.new()
			tilde.name = "Tilde"
			tilde.text = "✓"

			tilde.add_theme_font_size_override(
				"font_size", 42
			)

			tilde.add_theme_color_override(
				"font_color",
				Color(0.2, 0.9, 0.3)
			)

			tilde.position = Vector2(20, -45)
			tilde.mouse_filter = Control.MOUSE_FILTER_IGNORE
			tilde.hide()

			objeto.add_child(tilde)

	print("Puzzle iniciado.")
	print("Buscá cuchara, receta y palo de amasar.")


# ==========================================
# INTERFAZ DE SHARON
# ==========================================

func configurar_interfaz_sharon() -> void:

	# Restaurar escalas.
	vineta_rosa.scale = Vector2.ONE
	dialogo_sharon.scale = Vector2.ONE
	carita_sharon.scale = Vector2.ONE

	vineta_rosa.rotation = 0.0
	dialogo_sharon.rotation = 0.0
	carita_sharon.rotation = 0.0

	# ======================================
	# VIÑETA ROSA
	# ======================================

	vineta_rosa.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	vineta_rosa.offset_left = 0
	vineta_rosa.offset_top = 0
	vineta_rosa.offset_right = 0
	vineta_rosa.offset_bottom = 0

	vineta_rosa.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	vineta_rosa.stretch_mode = TextureRect.STRETCH_SCALE
	vineta_rosa.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# ======================================
	# DIÁLOGOS INFERIORES
	# ======================================

	dialogo_sharon.set_anchors_and_offsets_preset(
		Control.PRESET_BOTTOM_WIDE
	)

	dialogo_sharon.offset_left = 30
	dialogo_sharon.offset_right = -30
	dialogo_sharon.offset_top = -220
	dialogo_sharon.offset_bottom = -20

	dialogo_sharon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	dialogo_sharon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	dialogo_sharon.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# ======================================
	# CARITA DE SHARON
	# ======================================

	carita_sharon.set_anchors_and_offsets_preset(
		Control.PRESET_BOTTOM_LEFT
	)

	carita_sharon.offset_left = 60
	carita_sharon.offset_top = -300
	carita_sharon.offset_right = 300
	carita_sharon.offset_bottom = -60

	carita_sharon.ignore_texture_size = true
	carita_sharon.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	carita_sharon.mouse_filter = Control.MOUSE_FILTER_STOP

	vineta_rosa.z_index = 0
	dialogo_sharon.z_index = 1
	carita_sharon.z_index = 2


# ==========================================
# CLIC EN LOS OBJETOS
# ==========================================

func _on_objeto_click(
	_viewport: Node,
	event: InputEvent,
	_shape_idx: int,
	nombre: String
) -> void:

	if puzzle_terminado:
		return

	if not event is InputEventMouseButton:
		return

	if event.button_index != MOUSE_BUTTON_LEFT or not event.pressed:
		return

	if nombre in objetos_encontrados:
		return

	# Durante los diálogos no se recogen objetos.
	if estado_sharon == 1:
		return

	if estado_sharon == 2:
		return

	if estado_sharon == 4:
		return

	# ======================================
	# OSO SECRETO
	# ======================================

	if nombre == "Oso":

		# No se puede recoger hasta
		# terminar los diálogos de Sharon.
		if estado_sharon != 3:
			print("El oso todavía está oculto.")
			return

		recoger_objeto(nombre)

		ProgresoJuego.oso_encontrado = true

		print("¡Encontraste el oso secreto!")

		completar_puzzle()
		return

	# ======================================
	# OBJETOS PRINCIPALES
	# ======================================

	# Solo se recogen durante la búsqueda.
	if estado_sharon != 0:
		return

	recoger_objeto(nombre)

	comprobar_progreso()


# ==========================================
# REGISTRAR OBJETO
# ==========================================

func recoger_objeto(nombre: String) -> void:

	if nombre in objetos_encontrados:
		return

	objetos_encontrados.append(nombre)

	var objeto: Area2D = get_node(
		"Objetos/" + nombre
	)

	var tilde: Label = objeto.get_node("Tilde")

	tilde.show()

	print("Objeto encontrado: ", nombre)


# ==========================================
# COMPROBAR LOS TRES OBJETOS
# ==========================================

func comprobar_progreso() -> void:

	if estado_sharon != 0:
		return

	var cantidad: int = 0

	for nombre in objetos_obligatorios:

		if nombre in objetos_encontrados:
			cantidad += 1

	print("Progreso: ", cantidad, "/3")

	# Sharon aparece al encontrar los tres.
	if cantidad >= 3:

		print("Los tres objetos fueron encontrados.")
		print("Ahora comienza la conversación de Sharon.")

		iniciar_dialogo_sharon()


# ==========================================
# INICIAR CONVERSACIÓN
# ==========================================

func iniciar_dialogo_sharon() -> void:

	if estado_sharon != 0:
		return

	estado_sharon = 1
	indice_sharon = 0

	bloquear_click_hasta = Time.get_ticks_msec() + 200

	mostrar_dialogo_sharon()


# ==========================================
# MOSTRAR DIÁLOGO
# ==========================================

func mostrar_dialogo_sharon() -> void:

	if indice_sharon >= dialogos_sharon.size():
		return

	var ruta: String = dialogos_sharon[indice_sharon]["imagen"]

	if ResourceLoader.exists(ruta):

		dialogo_sharon.texture = load(ruta)
		dialogo_sharon.show()

		print("Diálogo cargado: ", ruta)

	else:

		dialogo_sharon.texture = null
		push_warning("No se encontró: " + ruta)


# ==========================================
# AVANZAR DIÁLOGOS CON CLIC
# ==========================================

func _unhandled_input(event: InputEvent) -> void:

	if estado_sharon != 1:
		return

	if not event is InputEventMouseButton:
		return

	if event.button_index != MOUSE_BUTTON_LEFT or not event.pressed:
		return

	if Time.get_ticks_msec() < bloquear_click_hasta:
		return

	avanzar_dialogo_sharon()

	get_viewport().set_input_as_handled()


# ==========================================
# AVANZAR CONVERSACIÓN
# ==========================================

func avanzar_dialogo_sharon() -> void:

	if estado_sharon != 1:
		return

	# Después de sol04 aparece la pista.
	if indice_sharon == 4:

		dialogo_sharon.hide()

		mostrar_pista_sharon()
		return

	indice_sharon += 1

	if indice_sharon >= dialogos_sharon.size():

		finalizar_conversacion_sharon()

	else:

		mostrar_dialogo_sharon()


# ==========================================
# MOSTRAR PISTA ROSA
# ==========================================

func mostrar_pista_sharon() -> void:

	estado_sharon = 2

	dialogo_sharon.hide()

	# Mostrar viñeta rosa.
	vineta_rosa.modulate.a = 0.0
	vineta_rosa.show()

	# Mostrar carita de Sharon.
	carita_sharon.modulate.a = 0.0
	carita_sharon.show()

	# Sonido especial de Sharon.
	if sonido_sharon.stream != null:
		sonido_sharon.play()

	# Animación de aparición.
	var tween := create_tween()
	tween.set_parallel(true)

	tween.tween_property(
		vineta_rosa,
		"modulate:a",
		1.0,
		0.7
	)

	tween.tween_property(
		carita_sharon,
		"modulate:a",
		1.0,
		0.5
	)

	print("Pista de Sharon visible.")


# ==========================================
# TOCAR CARITA DE SHARON
# ==========================================

func _on_carita_sharon_pressed() -> void:

	if estado_sharon != 2:
		return

	estado_sharon = 4

	# Ocultar carita.
	carita_sharon.hide()

	# Mostrar el oso rosa.
	oso_rosa.modulate.a = 0.0
	oso_rosa.show()

	var aparicion_oso := create_tween()

	aparicion_oso.tween_property(
		oso_rosa,
		"modulate:a",
		1.0,
		0.8
	)

	print("¡OSO ROSA VISIBLE!")

	# Desvanecer viñeta.
	var tween := create_tween()

	tween.tween_property(
		vineta_rosa,
		"modulate:a",
		0.0,
		0.7
	)

	await tween.finished

	vineta_rosa.hide()

	# Continuar desde sol05.
	indice_sharon = 5
	estado_sharon = 1

	bloquear_click_hasta = Time.get_ticks_msec() + 200

	mostrar_dialogo_sharon()

	print("Pista tocada. Oso desbloqueándose.")


# ==========================================
# TERMINAR CONVERSACIÓN
# ==========================================

func finalizar_conversacion_sharon() -> void:

	dialogo_sharon.hide()

	# Ahora sí se puede recoger el oso.
	estado_sharon = 3

	print("Terminó la conversación con Sharon.")
	print("Ahora podés tocar el oso rosa.")


# ==========================================
# COMPLETAR PUZZLE
# ==========================================

func completar_puzzle() -> void:

	if puzzle_terminado:
		return

	puzzle_terminado = true

	estado_sharon = 0

	ProgresoJuego.alacena_completada = true

	print("PUZZLE COMPLETADO.")
	print("Se encontraron los tres objetos y el oso.")
	print("Regresando a la cocina...")

	await get_tree().create_timer(1.5).timeout

	terminar_puzzle()


# ==========================================
# REGRESAR A LA COCINA
# ==========================================

func terminar_puzzle() -> void:

	print("Cambiando a cocina.tscn")

	var error := get_tree().change_scene_to_file(
		RUTA_COCINA
	)

	if error != OK:

		push_error(
			"No se pudo abrir cocina.tscn. Error: " + str(error)
		)
