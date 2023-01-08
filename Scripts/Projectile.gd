extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const World = preload("res://Scripts/World.gd")
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func init(initial_velocity):
	velocity = initial_velocity
func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	move_and_slide()


func _on_area_3d_area_entered(area):

	pass

func _on_area_3d_body_entered(body):
	if body == self:
		return
	get_tree().get_root().get_node("./World").delete_things(global_position, 3.0)
	queue_free()
