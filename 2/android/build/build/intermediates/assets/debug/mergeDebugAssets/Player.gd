extends RigidBody3D

## Boost multiplier
@export_range(750.0, 3000.0) var thrust: float = 1000.0
## Rotation multiplier
@export_range(100.0, 250.0) var torque_thrust: float = 150.0

@onready var explosionSound: AudioStreamPlayer = $ExplosionAudio
@onready var successSound: AudioStreamPlayer = $SuccessAudio
@onready var engineSound: AudioStreamPlayer = $EngineAudio
@onready var engineParticles: GPUParticles3D  = $BoosterParticles
@onready var rotateLeftParticles: GPUParticles3D = $RotateLeftParticles
@onready var rotateRightParticles: GPUParticles3D = $RotateRightParticles
@onready var explosionParticles: GPUParticles3D = $ExplosionParticles
@onready var successParticles: GPUParticles3D = $SuccessParticles

func _ready() -> void:
	print("Player scene ready")

var is_transitioning: bool = false

func useTween(action: Callable, duration: float) -> void:
	var tween = create_tween()
	tween.tween_interval(duration)
	tween.tween_callback(action)

func crash_sequence() -> void:
	is_transitioning = true
	print("Crashed!")
	set_process(false)
	explosionSound.play()
	explosionParticles.emitting = true
	useTween(get_tree().reload_current_scene, 2.5)

func goal_reached(next_level_file: String) -> void:
	is_transitioning = true
	print("Goal reached!")
	set_process(false)
	successSound.play()
	successParticles.emitting = true
	useTween(get_tree().change_scene_to_file.bind(next_level_file), 1.0)

func game_beaten() -> void:
	is_transitioning = true
	print("Game beaten!")
	set_process(false)
	successParticles.emitting = true
	successSound.play()

func _process(delta: float) -> void:
	if Input.is_action_pressed("boost"):
		apply_central_force(basis.y * delta * thrust)
		if !engineSound.playing:
			engineSound.play()
		if !engineParticles.emitting:
			engineParticles.emitting = true
	else:
		if engineSound.playing:
			engineSound.stop()
		if engineParticles.emitting:
			engineParticles.emitting = false

	if Input.is_action_pressed("rotate_left"):
		apply_torque(Vector3(0, 0, delta * torque_thrust))
		if !rotateLeftParticles.emitting:
			rotateLeftParticles.emitting = true
	else:
		if rotateLeftParticles.emitting:
			rotateLeftParticles.emitting = false

	if Input.is_action_pressed("rotate_right"):
		apply_torque(Vector3(0, 0, -delta * torque_thrust))
		if !rotateRightParticles.emitting:
			rotateRightParticles.emitting = true
	else:
		if rotateRightParticles.emitting:
			rotateRightParticles.emitting = false

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
