extends MeshInstance3D

func _process(delta):
	var playerPos = get_parent().get_node("Player/RigidBody3D/FirstPersonCamera").get_global_transform().origin
	position = Vector3(playerPos.x,playerPos.y+100,playerPos.z)
