
extends Control

# ==========================================
# NODOS
# ==========================================

@onready var video_fondo: VideoStreamPlayer = $VideoFondo
@onready var musica: AudioStreamPlayer = $Musica
@onready var boton_jugar: TextureButton = $BotonJugar

@onready var vista_transicion: SubViewportContainer = $VistaTransicion
@onready var vista: SubViewport = $VistaTransicion/Vista
@onready var camara: Camera2D = $VistaTransicion/Vista/Mundo/Camara


# ==========================================
# RESOLUCIÓN
# ==========================================

const RESOLUCION: Vector2i = Vector2i(1920, 1080)


# ==========================================
# DURACIONES
# ==========================================

@export var duracion_mezcla: float = 1.5
@export var duracion_descenso: float = 7.0
@export var duracion_zoom: float = 5.0
@export var duracion_fundido: float = 2.0


# ==========================================
# POSICIONES DE CÁMARA
# ==========================================

@export var inicio_camara: Vector2 = Vector2(0, -1080)
@export var fin_descenso: Vector2 = Vector2(0, 70)
@export var destino_ventana: Vector2 = Vector2(-430, 210)


# ==========================================
# ZOOM
# ==========================================

@export var zoom_inicio: float = 1.67
@export var zoom_final: float = 3.0


# ==========================================
# VARIABLES
# ==========================================

var animacion_boton: Tween
var transicion_iniciada: bool = false
var fundido: ColorRect


# ==========================================
# INICIO
# ==========================================

func _ready() -> void:

	# ======================================
	# VIDEO DEL MENÚ
	# ======================================

	if video_fondo.stream != null:
		video_fondo.play()

	# ======================================
	# PRIMERA CANCIÓN: MENÚ
	# ======================================

	# Usamos la música asignada al nodo Musica.
	# MusicaGlobal se encarga de reproducirla.

	if musica.stream != null:
		MusicaGlobal.reproducir(musica.stream, 0.5)

	# ======================================
	# PREPARAR SUBVIEWPORT
	# ======================================

	vista.size = RESOLUCION

	vista_transicion.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	vista_transicion.stretch = true
	vista_transicion.modulate.a = 0.0
	vista_transicion.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# ======================================
	# PREPARAR CÁMARA
	# ======================================

	camara.enabled = true
	camara.position = inicio_camara
	camara.zoom = Vector2.ONE * zoom_inicio
	camara.offset = Vector2.ZERO

	# ======================================
	# PREPARAR BOTÓN JUGAR
	# ======================================

	boton_jugar.visible = true
	boton_jugar.disabled = false
	boton_jugar.ignore_texture_size = true
	boton_jugar.stretch_mode = TextureButton.STRETCH_SCALE

	boton_jugar.anchor_left = 0.5
	boton_jugar.anchor_right = 0.5
	boton_jugar.anchor_top = 0.82
	boton_jugar.anchor_bottom = 0.82

	boton_jugar.offset_left = -150
	boton_jugar.offset_right = 150
	boton_jugar.offset_top = -50
	boton_jugar.offset_bottom = 50

	boton_jugar.pivot_offset = boton_jugar.size / 2
	boton_jugar.scale = Vector2.ONE

	if not boton_jugar.mouse_entered.is_connected(_al_entrar):
		boton_jugar.mouse_entered.connect(_al_entrar)

	if not boton_jugar.mouse_exited.is_connected(_al_salir):
		boton_jugar.mouse_exited.connect(_al_salir)

	if not boton_jugar.pressed.is_connected(_jugar):
		boton_jugar.pressed.connect(_jugar)

	# ======================================
	# FUNDIDO NEGRO
	# ======================================

	var capa := CanvasLayer.new()
	capa.layer = 10
	add_child(capa)

	fundido = ColorRect.new()
	fundido.color = Color.BLACK
	fundido.color.a = 0.0
	fundido.mouse_filter = Control.MOUSE_FILTER_IGNORE

	capa.add_child(fundido)

	fundido.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)


# ==========================================
# ANIMACIÓN DEL BOTÓN
# ==========================================

func _al_entrar() -> void:

	if not transicion_iniciada:
		animar_boton(Vector2(1.10, 1.10))


func _al_salir() -> void:

	if not transicion_iniciada:
		animar_boton(Vector2.ONE)


func animar_boton(escala: Vector2) -> void:

	if animacion_boton:
		animacion_boton.kill()

	animacion_boton = create_tween()

	animacion_boton.tween_property(
		boton_jugar,
		"scale",
		escala,
		0.2
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


# ==========================================
# AL PRESIONAR JUGAR
# ==========================================

func _jugar() -> void:

	if transicion_iniciada:
		return

	transicion_iniciada = true
	boton_jugar.disabled = true

	if animacion_boton:
		animacion_boton.kill()

	# ======================================
	# OCULTAR BOTÓN
	# ======================================

	var ocultar_boton := create_tween()

	ocultar_boton.tween_property(
		boton_jugar,
		"modulate:a",
		0.0,
		0.4
	)

	await ocultar_boton.finished

	# ======================================
	# MEZCLAR VIDEO CON TRANSICIÓN
	# ======================================

	var mezcla := create_tween()

	mezcla.tween_property(
		vista_transicion,
		"modulate:a",
		1.0,
		duracion_mezcla
	)

	await mezcla.finished

	# ======================================
	# DESCENSO DEL CIELO AL PAISAJE
	# ======================================

	var descenso := create_tween()

	descenso.set_trans(Tween.TRANS_SINE)
	descenso.set_ease(Tween.EASE_IN_OUT)

	descenso.tween_property(
		camara,
		"position",
		fin_descenso,
		duracion_descenso
	)

	await descenso.finished

	# ======================================
	# APAGAR PRIMERA CANCIÓN SUAVEMENTE
	# ======================================

	# La música del menú baja durante
	# los 5 segundos del zoom final.

	MusicaGlobal.bajar_volumen(duracion_zoom)

	# ======================================
	# ZOOM HACIA LA VENTANA
	# ======================================

	var zoom := create_tween()

	zoom.set_trans(Tween.TRANS_SINE)
	zoom.set_ease(Tween.EASE_IN_OUT)

	zoom.tween_property(
		camara,
		"position",
		destino_ventana,
		duracion_zoom
	)

	zoom.parallel().tween_property(
		camara,
		"zoom",
		Vector2.ONE * zoom_final,
		duracion_zoom
	)

	# ======================================
	# FUNDIDO NEGRO
	# ======================================

	zoom.parallel().tween_property(
		fundido,
		"color:a",
		1.0,
		duracion_fundido
	).set_delay(
		maxf(0.0, duracion_zoom - duracion_fundido)
	)

	await zoom.finished

	# ======================================
	# CAMBIO A LA COCINA
	# ======================================

	var ruta := "res://escenas/escena_1/cocina.tscn"

	if ResourceLoader.exists(ruta):
		get_tree().change_scene_to_file(ruta)
	else:
		push_warning("No se encontró cocina.tscn")
