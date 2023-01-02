extends Node3D

var pos = Vector3()
var generated = false
var type = "grass"
var flatY
var x
var y
var dist
var tile
var gameType = "ground"

var objects = []
var objectsPlaced = false

func placeObjects(world):
	if !objectsPlaced:
		objectsPlaced = true
		for o in objects:
			world.call_deferred("add_child",o)
	#		world.add_child(o)
			for node in o.get_children():
				if node is MeshInstance3D: 
					node.editRay(true)
	#				node.addMeshToWorld()
					node.call_deferred("addToWorld")

func removeObjects(world):
	if objectsPlaced:
		objectsPlaced = false
	for o in objects:
		for node in o.get_children():
			if node is MeshInstance3D: 
				node.editRay(false)
				node.removeMeshFromWorld()
		world.call_deferred("remove_child",o)
#		world.remove_child(o)