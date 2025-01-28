extends Camera3D

@export var lerp_speed = 3.0
@export var offset = Vector3(0,2,5)
var targetVec = Vector3(5,0,5)
var target = null
var moveSpeed = 10
var mouseDelta = null
var minLookAngle : float = -1.0
var maxLookAngle : float = 0.2
var vel = Vector3()
const lookSensitivity = 1.0
func _ready():
	target = get_node("../Player")
	position = Vector3(-5,10,-5)
	look_at(targetVec)
func _physics_process(delta):
	#if !target:
	#	return

	#var target_xform = target.global_transform.translated_local(offset)
	#global_transform = global_transform.interpolate_with(target_xform, lerp_speed * delta)

	#look_at(target.global_transform.origin, target.transform.basis.y)
	var input = Vector2()
  
  # movement inputs
	if Input.is_action_pressed("ARROW_UP"):
		input.y -= 1
	if Input.is_action_pressed("ARROW_DOWN"):
		input.y += 1
	if Input.is_action_pressed("ARROW_LEFT"):
		input.x -= 1
	if Input.is_action_pressed("ARROW_RIGHT"):
		input.x += 1
	input = input.normalized()
	var forward = global_transform.basis.z
	var right = global_transform.basis.x

	var relativeDir = (forward * input.y + right * input.x)

	# set the velocity
	vel.x = relativeDir.x * moveSpeed
	vel.z = relativeDir.z * moveSpeed
	position.x += vel.x * delta
	position.z += vel.z * delta
	if Input.is_action_pressed("MOUSE_LEFT"):
		rotation.x -= mouseDelta.y * lookSensitivity * delta
		rotation.x = clamp(rotation.x, minLookAngle, maxLookAngle)
		rotation.y -= mouseDelta.x * lookSensitivity * delta


func _input(event):
	if event is InputEventMouseMotion:
		mouseDelta = event.relative
