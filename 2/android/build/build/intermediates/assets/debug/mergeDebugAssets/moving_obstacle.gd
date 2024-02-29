extends AnimatableBody3D

@export var destination: Vector3
@export var duration: float = 1.0

func useUpDownAnim():
	var tween = create_tween()
	tween.set_loops()
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "global_position", global_position + destination, duration)
	tween.tween_property(self, "global_position", global_position, duration)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	useUpDownAnim()