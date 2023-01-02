extends CharacterBody3D

var direction = Vector3()
var gravity = -20
var speed = 800
var pmouse = Vector2()
var moveMouse = true

@onready var down_ray = get_node("DownRay")

func _ready():
	pmouse = get_viewport().get_mouse_position()
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pass

	pass
func _input(event):
	var mouse = get_viewport().get_mouse_position()
	var viewport = get_viewport()

func _physics_process(delta):
	Globaldata.player_position = position
	direction = Vector3(0,0,0)
	var forwardSpeed = 0
	var sideSpeed = 0
	if Input.is_key_pressed(KEY_W):
		forwardSpeed -= 1
	if Input.is_key_pressed(KEY_S):
		forwardSpeed += 1
	if Input.is_key_pressed(KEY_A):
		sideSpeed -= 1
	if Input.is_key_pressed(KEY_D):
		sideSpeed += 1
	if Input.is_action_pressed("ARROW_UP"):
		pass
	if Input.is_action_pressed("ARROW_DOWN"):
		pass
	if Input.is_action_pressed("ARROW_LEFT"):
		rotation.y += 0.05
	if Input.is_action_pressed("ARROW_RIGHT"):
		rotation.y -= 0.05
#	direction = direction.normalized()
	direction.z = forwardSpeed*cos(rotation.y) - sideSpeed*sin(rotation.y)
	direction.x = forwardSpeed*sin(rotation.y) + sideSpeed*cos(rotation.y)
	direction *= speed * delta
	
	velocity.y += gravity * delta
	velocity.x = direction.x
	velocity.z = direction.z
	move_and_slide()
	if down_ray.is_colliding() and Input.is_key_pressed(KEY_SPACE):
		print(down_ray.get_collider().get_name())
		velocity.y = 20

func map(x, in_min, in_max, out_min, out_max):
	return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min
