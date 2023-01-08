extends Camera3D

@export var lerp_speed = 3.0
@export var offset = Vector3(0,2,5)
var targetVec = Vector3(5,0,5)
var target = null
var speed = 10
func _ready():
	target = get_node("../Player")
	position = Vector3(-5,10,-5)
func _physics_process(delta):
	#if !target:
	#	return

	#var target_xform = target.global_transform.translated_local(offset)
	#global_transform = global_transform.interpolate_with(target_xform, lerp_speed * delta)

	#look_at(target.global_transform.origin, target.transform.basis.y)
	if Input.is_action_pressed("ARROW_UP"):
		targetVec.x += speed * delta;
		position.x += speed * delta;
		targetVec.z += speed * delta;
		position.z += speed * delta;
	if Input.is_action_pressed("ARROW_DOWN"):
		targetVec.x -= speed * delta;
		position.x -= speed * delta;
		targetVec.z -= speed * delta;
		position.z -= speed * delta;
	if Input.is_action_pressed("ARROW_LEFT"):
		targetVec.z -= speed * delta;
		position.z -= speed * delta;
		targetVec.x += speed * delta;
		position.x += speed * delta;
	if Input.is_action_pressed("ARROW_RIGHT"):
		targetVec.z += speed * delta;
		position.z += speed * delta;
		targetVec.x -= speed * delta;
		position.x -= speed * delta;

	look_at(targetVec)
