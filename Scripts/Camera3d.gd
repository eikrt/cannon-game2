extends Camera3D

@export var lerp_speed = 3.0
@export var offset = Vector3(0,2,5)

var target = null

func _ready():
	target = get_node("../Player")

func _physics_process(delta):
	if !target:
		return

	var target_xform = target.global_transform.translated_local(offset)
	global_transform = global_transform.interpolate_with(target_xform, lerp_speed * delta)

	look_at(target.global_transform.origin, target.transform.basis.y)
