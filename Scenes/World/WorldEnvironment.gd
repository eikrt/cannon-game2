extends WorldEnvironment

@onready var player = get_parent().get_node("Player/RigidBody3D")
@onready var sunLight = get_parent().get_node("sunlight")

#func _process(delta):
#	environment.fog_depth_end = -player.position.y*6-320
#	if environment.fog_depth_end < 20:
#		environment.fog_depth_end = 20
#	if environment.fog_depth_end > 150:
#		environment.fog_depth_end = 150
	
#	environment.ambient_light_energy = -player.position.y
#	sunLight.light_energy = -player.position.y*0.02-1
#	print(-player.position.y*0.022-1.3)