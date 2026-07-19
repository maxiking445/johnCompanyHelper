extends SubViewportContainer

signal flip_finished


@export var front: CompressedTexture2D
@export var back: CompressedTexture2D
@export var flip_duration: float = 0.45
@export var flip_height: float = 0.18

var is_flipping: bool = false

@onready var card_mesh: MeshInstance3D = $SubViewport/CardMesh
@onready var front_sprite: Sprite3D = $SubViewport/CardMesh/Front
@onready var back_sprite: Sprite3D = $SubViewport/CardMesh/Back


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if front != null:
		front_sprite.texture = front
	if back != null:
		back_sprite.texture = back


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func flip() -> void:
	if is_flipping:
		return

	is_flipping = true

	var start_y := card_mesh.position.y
	var start_rotation := card_mesh.rotation_degrees.z
	var half_rotation := start_rotation + 90.0
	var target_rotation := start_rotation + 180.0
	var half_duration := flip_duration * 0.5
	var tween := create_tween()

	# Lift and turn the card halfway, similar to a physical tabletop flip.
	tween.tween_property(
		card_mesh,
		"position:y",
		start_y + flip_height,
		half_duration
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	tween.parallel().tween_property(
		card_mesh,
		"rotation_degrees:z",
		half_rotation,
		half_duration
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

	# Finish the turn and let the card settle back onto the table.
	tween.tween_property(
		card_mesh,
		"position:y",
		start_y,
		half_duration
	).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)

	tween.parallel().tween_property(
		card_mesh,
		"rotation_degrees:z",
		target_rotation,
		half_duration
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	tween.finished.connect(func() -> void:
		card_mesh.rotation_degrees.z = fposmod(card_mesh.rotation_degrees.z, 360.0)
		card_mesh.position.y = start_y
		is_flipping = false
		flip_finished.emit()
	)
