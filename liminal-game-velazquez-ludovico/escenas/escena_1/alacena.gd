
extends Area2D

signal abrir_puzzle

@onready var imagen_abierta: Sprite2D = $ImagenAbierta

var habilitada: bool = true


func _ready() -> void:
	imagen_abierta.hide()
	input_pickable = true

	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	input_event.connect(_on_input_event)


func _on_mouse_entered() -> void:
	if habilitada:
		imagen_abierta.show()


func _on_mouse_exited() -> void:
	imagen_abierta.hide()


func _on_input_event(
	_viewport: Node,
	event: InputEvent,
	_shape_idx: int
) -> void:
	if not habilitada:
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			get_viewport().set_input_as_handled()
			print("¡Hiciste clic en la alacena!")
			abrir_puzzle.emit()
