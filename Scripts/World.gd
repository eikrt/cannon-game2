extends Node3D

@onready var Chunk = preload("res://Scenes/Chunk.tscn")
var chunk_size = 12
var height = 12
var blockSize = 2.0
var surfaceLevel = 0
var world_size = 4
var chunksArray = []
# Called when the node enters the scene tree for the first time.
func _ready():
	for x in range(0,world_size):
		var yArray = []
		chunksArray.append(yArray)
		for y in range(0,1):
			var zArray = []
			yArray.append(zArray)
			for z in range(0,world_size):
				var chunk_instance = Chunk.instantiate()
				chunk_instance.set_name("chunk")
				chunk_instance.init(x,y,z, chunk_size,height,blockSize, surfaceLevel)
				zArray.append(chunk_instance)
				add_child(chunk_instance)
func _process(delta):
	if Input.is_action_pressed("SHOOT"):
		delete_things()
func delete_things():
	var blockChunks = chunk_size
	var p_b_x = Globaldata.player_position.x / blockSize
	var p_c_x = floor(p_b_x / chunk_size)
	var r_p_b_x = p_b_x - p_c_x * chunk_size
	var p_b_z = Globaldata.player_position.z / blockSize
	var p_c_z = floor(p_b_z / chunk_size)
	var r_p_b_z = p_b_z - p_c_z * chunk_size
	var p_b_y = floor(Globaldata.player_position.y / blockSize)
	var chunk = chunksArray[p_c_x][0][p_c_z]
	chunk.delete_things(r_p_b_x, p_b_y, r_p_b_z)
