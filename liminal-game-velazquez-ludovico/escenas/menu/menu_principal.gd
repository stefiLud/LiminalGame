
extends Control

@onready var video_fondo: VideoStreamPlayer = $VideoFondo
@onready var boton_jugar: TextureButton = $BotonJugar
@onready var musica: AudioStreamPlayer = $Musica

var animacion: Tween

const ESCALA_NORMAL = Vector2(1.0, 1.0)
const ESCALA_HOVER = Vector2(1.10, 1.10)
const ESCALA_PRESION = Vector2(1.15, 1.15)


func _ready():

	# ---------------- VIDEO DE FONDO ----------------

	video_fondo.play()

	# ---------------- MUSICA ----------------

	if musica.stream != null:
		musica.play()

	# ---------------- BOTON JUGAR ----------------

	boton_jugar.visible = true
	boton_jugar.disabled = false

	boton_jugar.ignore_texture_size = true
	boton_jugar.stretch_mode = TextureButton.STRETCH_SCALE

	boton_jugar.size = Vector2(300, 100)

	# Centrar horizontalmente y ubicar abajo
	boton_jugar.anchor_left = 0.5
	boton_jugar.anchor_right = 0.5
	boton_jugar.anchor_top = 0.82
	boton_jugar.anchor_bottom = 0.82

	boton_jugar.offset_left = -150
	boton_jugar.offset_right = 150
	boton_jugar.offset_top = -50
	boton_jugar.offset_bottom = 50

	boton_jugar.pivot_offset = boton_jugar.size / 2
	boton_jugar.scale = ESCALA_NORMAL

	# Conectar interacciones
	boton_jugar.mouse_entered.connect(_al_entrar)
	boton_jugar.mouse_exited.connect(_al_salir)
	boton_jugar.pressed.connect(_jugar)


# ---------------- ANIMACION AL PASAR EL MOUSE ----------------

func _al_entrar():
	animar_boton(ESCALA_HOVER)


func _al_salir():
	animar_boton(ESCALA_NORMAL)


func animar_boton(escala_objetivo: Vector2):

	if animacion:
		animacion.kill()

	animacion = create_tween()

	animacion.tween_property(
		boton_jugar,
		"scale",
		escala_objetivo,
		0.2
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


# ---------------- AL PRESIONAR JUGAR ----------------

func _jugar():

	if animacion:
		animacion.kill()

	animacion = create_tween()

	animacion.tween_property(
		boton_jugar,
		"scale",
		ESCALA_PRESION,
		0.15
	)

	await animacion.finished

	print("¡Comenzar Donde termina el sendero!")
