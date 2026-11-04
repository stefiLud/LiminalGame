
extends Node2D

# ==========================================
# NODOS
# ==========================================

@onready var sol = $Sol
@onready var sharon: Sprite2D = $Sharon
@onready var sonido_sharon: AudioStreamPlayer = $SonidoSharon
@onready var efecto_rosa: CanvasModulate = $EfectoRosa


# ==========================================
# CONFIGURACIÓN
# ==========================================

@export var espera_aparicion: float = 1.5
@export var duracion_aparicion: float = 2.0

var aparicion_terminada: bool = false


# ==========================================
# INICIO
# ==========================================

func _ready() -> void:

	# Sol comienza quieta.
	sol.show()
	sol.puede_moverse = false

	# Sharon empieza invisible.
	sharon.show()
	sharon.modulate.a = 0.0

	# Escena con sus colores normales.
	efecto_rosa.color = Color.WHITE

	# Esperar un momento antes de la aparición.
	await get_tree().create_timer(
		espera_aparicion
	).timeout

	aparecer_sharon()


# ==========================================
# APARICIÓN DE SHARON
# ==========================================

func aparecer_sharon() -> void:

	if aparicion_terminada:
		return

	# Reproducir sonido sobrenatural.
	if sonido_sharon.stream != null:
		sonido_sharon.play()

	# Guardar escala original.
	var escala_original: Vector2 = sharon.scale

	# Sharon aparece un poco más grande.
	sharon.scale = escala_original * 1.12

	# Preparar un leve tinte rosado.
	efecto_rosa.color = Color.WHITE

	# Animación principal.
	var tween := create_tween()
	tween.set_parallel(true)

	# Sharon aparece gradualmente.
	tween.tween_property(
		sharon,
		"modulate:a",
		1.0,
		duracion_aparicion
	).set_trans(Tween.TRANS_SINE)

	# Sharon vuelve a su escala normal.
	tween.tween_property(
		sharon,
		"scale",
		escala_original,
		duracion_aparicion
	).set_trans(Tween.TRANS_SINE)

	# Teñir ligeramente la escena.
	tween.tween_property(
		efecto_rosa,
		"color",
		Color(1.0, 0.84, 0.92),
		0.5
	)

	await tween.finished

	# Recuperar los colores normales.
	var restaurar := create_tween()

	restaurar.tween_property(
		efecto_rosa,
		"color",
		Color.WHITE,
		1.5
	)

	await restaurar.finished

	aparicion_terminada = true

	print("Sharon apareció en el patio.")
	print("Sol sigue quieta esperando el diálogo.")
