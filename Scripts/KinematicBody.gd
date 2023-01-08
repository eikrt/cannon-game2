extends CharacterBody3D

var direction = Vector3()
var gravity = -20
var speed = 800
var launchSpeed = 10
var pmouse = Vector2()
var moveMouse = true
var directionRot = Vector3(0,0,0)
var Projectile = load("res://Scenes/Projectile.tscn")
var Water = load("res://Scripts/Water.tscn")
var rayOrigin = Vector3()
var rayEnd = Vector3()
var moveTarget = Vector3()
var movingToTarget = false
var moveRotation = Vector3()
var spawning = true
const directionLimitYU = 3.14
const directionLimitYD = 0.0
const directionPlus = 3.14/2.0
const launchSpeedLimit = 20
@onready var down_ray = get_node("DownRay")
@onready var camera = get_tree().get_root().get_node("./World/Camera3d")
func _ready():
	pmouse = get_viewport().get_mouse_position()
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pass

	pass
func spawn():
	position = Vector3(randi_range(0, Constants.blockSize * Constants.worldSize * Constants.chunkSize),10,randi_range(0, Constants.blockSize * Constants.worldSize * Constants.chunkSize))
func _input(event):
	var mouse = get_viewport().get_mouse_position()
	var viewport = get_viewport()
func _physics_process(delta):


	Globaldata.player_position = position
	if spawning:
		if $RayCast3d.is_colliding():
			if $RayCast3d.get_collider().get_class() == "Water":
				spawn()
			else:
				spawning = false
	if Input.is_action_just_pressed("PLUS"):
		if launchSpeed < launchSpeedLimit:
			launchSpeed += 1
	if Input.is_action_just_pressed("MINUS"):
		if launchSpeed > 0:
			launchSpeed -= 1	
	direction = Vector3(0,0,0)
	var forwardSpeed = 0
	var sideSpeed = 0
	var space_state = get_world_3d().get_direct_space_state()
	var mouse = get_viewport().get_mouse_position()
	rayOrigin = camera.project_ray_origin(mouse)
	rayEnd = rayOrigin + camera.project_ray_normal(mouse) * 2000
	var intersection = space_state.intersect_ray(PhysicsRayQueryParameters3D.create(rayOrigin,rayEnd))
	if intersection:
		if Input.is_action_pressed("MOUSE_LEFT"):
			moveTarget = intersection.position
			movingToTarget = true
			moveRotation.y = atan2(moveTarget.x - global_position.x, moveTarget.z - global_position.z)

	if global_position.distance_to(moveTarget) < 1.5:
			movingToTarget = false
	if movingToTarget:
		forwardSpeed = 1
	else:
		forwardSpeed = 0
	if Input.is_key_pressed(KEY_W):
		if directionRot.z > 0:
			directionRot.z -= 0.1
		#$DirectionMeter.position.y += 5 * delta
	if Input.is_key_pressed(KEY_S):
		if directionRot.z < 3.14:
			directionRot.z += 0.1
		#$DirectionMeter.position.y -= 5 * delta
		pass
	if Input.is_key_pressed(KEY_A):
		directionRot.y += 0.1
		pass
	if Input.is_key_pressed(KEY_D):
		directionRot.y -= 0.1
		pass
	$DirectionMeter.mesh.surface_get_material(0).set_shader_parameter("direction", directionRot)
	if Input.is_action_pressed("ARROW_UP"):
		pass
	if Input.is_action_pressed("ARROW_DOWN"):
		pass
	if Input.is_action_pressed("ARROW_LEFT"):
		pass
		#rotation.y += 0.05
	if Input.is_action_pressed("ARROW_RIGHT"):
		pass
		#rotation.y -= 0.05
	
	if Input.is_action_just_pressed("SHOOT"):
		var projInstance = Projectile.instantiate()
		projInstance.init(Vector3(cos(directionRot.y) * launchSpeed,(1.0 + cos(directionRot.z)) * launchSpeed,sin(directionRot.y) * launchSpeed))
		projInstance.position = Vector3(0,2,0)
		add_child(projInstance)
#	direction = direction.normalized()
	direction.z = forwardSpeed*cos(moveRotation.y) - sideSpeed*sin(moveRotation.y)
	direction.x = forwardSpeed*sin(moveRotation.y) + sideSpeed*cos(moveRotation.y)
	direction *= speed * delta
	
	velocity.y += gravity * delta
	velocity.x = direction.x
	velocity.z = direction.z
	move_and_slide()
	if down_ray.is_colliding() and Input.is_key_pressed(KEY_SPACE):
		#velocity.y = 20
		pass

func map(x, in_min, in_max, out_min, out_max):
	return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min


func _on_area_3d_body_entered(body):
	if body.get_class() == "Water":
		queue_free()
