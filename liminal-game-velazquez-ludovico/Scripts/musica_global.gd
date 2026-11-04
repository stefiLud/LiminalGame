
extends Node

# ==========================================
# ADMINISTRADOR GLOBAL DE MÚSICA
# ==========================================

var reproductor: AudioStreamPlayer
var tween_volumen: Tween

var volumen_normal: float = -15.0
var volumen_silencio: float = -60.0


# ==========================================
# INICIO
# ==========================================

func _ready() -> void:

	reproductor = AudioStreamPlayer.new()
	reproductor.name = "ReproductorMusica"
	reproductor.bus = "Master"

	add_child(reproductor)


# ==========================================
# REPRODUCIR UNA CANCIÓN
# ==========================================

func reproducir(
	cancion: AudioStream,
	duracion: float = 2.0
) -> void:

	if cancion == null:
		return

	# Si ya está sonando esta canción,
	# no reiniciarla.
	if reproductor.playing and reproductor.stream == cancion:
		return

	# Detener animación anterior.
	if tween_volumen and tween_volumen.is_running():
		tween_volumen.kill()

	# Cambiar de canción.
	reproductor.stop()
	reproductor.stream = cancion

	# Empezar con volumen bajo.
	reproductor.volume_db = volumen_silencio
	reproductor.play()

	# Subir volumen suavemente.
	tween_volumen = create_tween()

	tween_volumen.tween_property(
		reproductor,
		"volume_db",
		volumen_normal,
		duracion
	)


# ==========================================
# BAJAR VOLUMEN SUAVEMENTE
# ==========================================

func bajar_volumen(duracion: float = 2.0) -> void:

	if not reproductor.playing:
		return

	if tween_volumen and tween_volumen.is_running():
		tween_volumen.kill()

	tween_volumen = create_tween()

	tween_volumen.tween_property(
		reproductor,
		"volume_db",
		volumen_silencio,
		duracion
	)


# ==========================================
# SUBIR VOLUMEN SUAVEMENTE
# ==========================================

func subir_volumen(duracion: float = 2.0) -> void:

	if not reproductor.playing:
		return

	if tween_volumen and tween_volumen.is_running():
		tween_volumen.kill()

	tween_volumen = create_tween()

	tween_volumen.tween_property(
		reproductor,
		"volume_db",
		volumen_normal,
		duracion
	)


# ==========================================
# DETENER MÚSICA CON FUNDIDO
# ==========================================

func detener(duracion: float = 2.0) -> void:

	if not reproductor.playing:
		return

	bajar_volumen(duracion)

	if tween_volumen:
		await tween_volumen.finished

		if is_instance_valid(reproductor):
			reproductor.stop()


# ==========================================
# CONSULTAR SI HAY MÚSICA
# ==========================================

func esta_sonando() -> bool:

	return reproductor.playing
