
extends CharacterBody2D

@export var velocidad: float = 180.0
@export var limite_izquierdo: float = -850.0
@export var limite_derecho: float = 850.0
@export var altura_piso: float = 400.0
@export var margen_pantalla: float = 80.0

@onready var animacion: AnimatedSprite2D = $AnimatedSprite2D2

var destino: Vector2
var caminando: bool = false
var puede_moverse: bool = false

# Evita caminar cuando el mouse está sobre la alacena.
var mouse_sobre_alacena: bool = false


func _ready() -> void:
	destino = global_position
	animacion.play("Parada")


func obtener_limites_pantalla() -> Vector2:
	var camara := get_viewport().get_camera_2d()

	if camara == null:
		return Vector2(limite_izquierdo, limite_derecho)

	var tamano_visible := get_viewport_rect().size / camara.zoom
	var centro := camara.get_screen_center_position()

	var izquierda: float = maxf(
		centro.x - tamano_visible.x / 2.0 + margen_pantalla,
		limite_izquierdo
	)

	var derecha: float = minf(
		centro.x + tamano_visible.x / 2.0 - margen_pantalla,
		limite_derecho
	)

	if izquierda > derecha:
		return Vector2(global_position.x, global_position.x)

	return Vector2(izquierda, derecha)


func _unhandled_input(event: InputEvent) -> void:
	# Bloquear el movimiento si está deshabilitado
	# o si el mouse está sobre la alacena.
	if not puede_moverse or mouse_sobre_alacena:
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:

			var posicion_click := get_global_mouse_position()
			var limites := obtener_limites_pantalla()

			destino = Vector2(
				clampf(posicion_click.x, limites.x, limites.y),
				altura_piso
			)

			if destino.x < global_position.x:
				animacion.flip_h = true
			elif destino.x > global_position.x:
				animacion.flip_h = false

			if global_position.distance_to(destino) < 5.0:
				detener_sol()
				return

			caminando = true
			animacion.play("Caminata")


func _physics_process(_delta: float) -> void:
	if not puede_moverse or not caminando:
		velocity = Vector2.ZERO
		return

	var limites := obtener_limites_pantalla()
	destino.x = clampf(destino.x, limites.x, limites.y)

	var direccion := destino - global_position

	if direccion.length() < 5.0:
		detener_sol()
		return

	velocity = direccion.normalized() * minf(
		velocidad,
		direccion.length() * 10.0
	)

	# Movimiento con colisiones.
	move_and_slide()

	# Si Sol choca con un muro, se detiene.
	if get_slide_collision_count() > 0:
		detener_sol()


func detener_sol() -> void:
	caminando = false
	velocity = Vector2.ZERO
	animacion.play("Parada")
