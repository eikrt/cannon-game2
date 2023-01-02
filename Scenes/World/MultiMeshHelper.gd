extends Node3D

var transforms = []
var mesh

var count = 0
var burf = 0

var changed = false
var updateTimer = 0

func _process(delta):
	if changed:
		updateTimer += delta
		if updateTimer > 2:
			reconstructMultiMesh()
			changed = false
			updateTimer = 0

func addToMesh(transform):
	changed = true
	transforms.append(transform)
	count += 1

func removeFromMesh(transform):
	changed = true
	transforms.erase(transform)
	count -= 1

func reconstructMultiMesh():
	$MultiMeshInstance3D.multimesh = MultiMesh.new()
	$MultiMeshInstance3D.multimesh.transform_format = MultiMesh.TRANSFORM_3D
	$MultiMeshInstance3D.multimesh.mesh = mesh
	
	$MultiMeshInstance3D.multimesh.instance_count = transforms.size()
	for i in range($MultiMeshInstance3D.multimesh.instance_count):
		$MultiMeshInstance3D.multimesh.set_instance_transform(i, transforms[i])