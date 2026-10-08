extends Control

signal pressed

@export var roll_duration: float = 1.4
@export var idle_rotation_speed: float = 0.24
@onready var cube: MeshInstance3D = $ViewportContainer/Viewport/World/Cube
@onready var roll_button: Button = $RollButton
@onready var caption: Label = $Caption
var rolled := false


func _ready() -> void:
	roll_button.pressed.connect(func(): pressed.emit())


func _process(delta: float) -> void:
	if not rolled and is_visible_in_tree():
		cube.rotate_y(delta * idle_rotation_speed)


func roll_to(face: StormDice.Face) -> void:
	if rolled:
		return
	rolled = true
	roll_button.disabled = true
	caption.text = ""
	var face_rotation := Vector3.ZERO
	match face:
		StormDice.Face.FOUR_B: face_rotation.y = PI
		StormDice.Face.SOUTH_3: face_rotation.y = -PI / 2.0
		StormDice.Face.EAST_2: face_rotation.y = PI / 2.0
		StormDice.Face.WEST_2: face_rotation.x = PI / 2.0
		StormDice.Face.STORMS_ALL: face_rotation.x = -PI / 2.0
	var target := (Basis.from_euler(Vector3(-0.12, 0.18, 0.0)) * Basis.from_euler(face_rotation)).get_rotation_quaternion()
	var tween := create_tween()
	tween.tween_property(cube, "rotation", cube.rotation + Vector3(TAU * 2.0, TAU, PI), roll_duration * 0.65).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await tween.finished
	var start := cube.quaternion
	tween = create_tween()
	tween.tween_method(func(weight: float): cube.quaternion = start.slerp(target, weight), 0.0, 1.0, roll_duration * 0.35).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	await tween.finished
	caption.text = ""
