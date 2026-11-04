
extends Node2D

@onready var paisaje: Sprite2D = $Paisaje
@onready var camara: Camera2D = $Camara
@onready var fundido: ColorRect = $CanvasLayer/Fundido

@export var duracion_descenso: float = 4.0
@export var duracion_zoom: float = 5.0
@export var duracion_fundido: float = 2.0


# Posiciones de la camara
@export var inicio_camara: Vector2 = Vector2(0, -100)
@export var fin_descenso: Vector2 = Vector2(0, 0)
@export var destino_ventana: Vector2 = Vector2(-430, 210)


# Zoom mas suave

@export var zoom_inicio: float = 0.65
@export var zoom_final: float = 1.8


var transicion_iniciada := false


func _ready() -> void:
	camara.enabled = true
	camara.position = inicio_camara
	camara.zoom = Vector2.ONE * zoom_inicio

	fundido.color = Color.BLACK
	fundido.color.a = 0.0
	fundido.mouse_filter = Control.MOUSE_FILTER_IGNORE

	await get_tree().process_frame
	iniciar_transicion()


func iniciar_transicion() -> void:
	if transicion_iniciada:
		return

	transicion_iniciada = true

	# 1. Descenso lento hacia la casa
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

	# 2. Zoom hacia la ventana
	var acercamiento := create_tween()
	acercamiento.set_trans(Tween.TRANS_SINE)
	acercamiento.set_ease(Tween.EASE_IN_OUT)

	acercamiento.tween_property(
		camara,
		"position",
		destino_ventana,
		duracion_zoom
	)

	acercamiento.parallel().tween_property(
		camara,
		"zoom",
		Vector2.ONE * zoom_final,
		duracion_zoom
	)

	# 3. Fundido negro durante los ultimos segundos
	acercamiento.parallel().tween_property(
		fundido,
		"color:a",
		1.0,
		duracion_fundido
	).set_delay(
		maxf(0.0, duracion_zoom - duracion_fundido)
	)

	await acercamiento.finished

	# 4. Entrar a la cocina
	var ruta := "res://escenas/escena_1/cocina.tscn"

	if ResourceLoader.exists(ruta):
		get_tree().change_scene_to_file(ruta)
	else:
		push_warning("No se encontro la escena de cocina.")
