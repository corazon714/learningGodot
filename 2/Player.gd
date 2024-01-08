extends RigidBody3D

## Boost multiplier
@export_range(750.0, 3000.0) var thrust: float = 1000.0

## Rotation multiplier
@export_range(100.0, 250.0) var torque_thrust: float = 100.0

var is_transitioning: bool = false

func useTween(action) -> void:
	var tween = create_tween()
	tween.tween_interval(1.0)
	tween.tween_callback(action)

func _ready() -> void:
	print("Player scene ready")

func crash_sequence() -> void:
	is_transitioning = true
	print("Crashed!")
	set_process(false)
	useTween(get_tree().reload_current_scene)

func goal_reached(next_level_file: String) -> void:
	is_transitioning = true
	print("Goal reached!")
	set_process(false)
	useTween(get_tree().change_scene_to_file.bind(next_level_file))

func game_beaten() -> void:
	is_transitioning = true
	print("Game beaten!")
	set_process(false)

func _process(delta: float) -> void:
	if Input.is_action_pressed("boost"):
		apply_central_force(basis.y * delta * thrust)

	if Input.is_action_pressed("rotate_left"):
		apply_torque(Vector3(0, 0, delta * torque_thrust))

	if Input.is_action_pressed("rotate_right"):
		apply_torque(Vector3(0, 0, -delta * torque_thrust))

func _on_body_entered(body: Node) -> void:
	match is_transitioning:
		true:
			pass
		false:
			if 'neutral' in body.get_groups():
				pass
			if 'goal' in body.get_groups():
				if body.file_path != "":
					goal_reached(body.file_path)
				else:
					game_beaten()
			if 'lose' in body.get_groups():
				crash_sequence()
