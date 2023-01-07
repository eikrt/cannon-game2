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
				chunk_instance.init(x,y,z)
				zArray.append(chunk_instance)
				add_child(chunk_instance)
func _process(delta):
	if Input.is_action_pressed("SHOOT"):
		delete_things(Globaldata.player_position)
func delete_things(destruction_pos):
	var blockChunks = chunk_size
	var p_b_x = destruction_pos.x / blockSize
	var p_c_x = floor(p_b_x / chunk_size)
	var r_p_b_x = floor(p_b_x - p_c_x * chunk_size)
	var p_b_z = destruction_pos.z / blockSize
	var p_c_z = floor(p_b_z / chunk_size)
	var r_p_b_z = floor(p_b_z - p_c_z * chunk_size)
	var p_b_y = floor(destruction_pos.y / blockSize)
	var explosionRadius = 6
	var chunk = chunksArray[p_c_x][0][p_c_z]
	var chunks = []
	for i in range(-explosionRadius,explosionRadius):
		for j in range(-explosionRadius,explosionRadius):
			for k in range(-explosionRadius,explosionRadius):
				if Vector3(i,j,k).distance_to(Vector3(0,0,0)) > explosionRadius:
					continue
				var real_x = r_p_b_x + i
				var real_y = p_b_y + j
				var real_z = r_p_b_z + k
				if real_x < 0 && real_z < 0:
					real_x = Constants.chunkSize - abs(real_x) + 1
					real_z = Constants.chunkSize - abs(real_z) + 1
					chunk = chunksArray[p_c_x - 1][0][p_c_z - 1]
				elif real_x < 0 && real_z > Constants.chunkSize:
					real_x = Constants.chunkSize - abs(real_x) + 1
					real_z = real_z - Constants.chunkSize - 1
					chunk = chunksArray[p_c_x - 1][0][p_c_z + 1]
				elif real_x > Constants.chunkSize && real_z < 0:
					real_z = Constants.chunkSize - abs(real_z) + 1
					real_x = real_x - Constants.chunkSize - 1
					chunk = chunksArray[p_c_x + 1][0][p_c_z - 1]
				elif real_x > Constants.chunkSize && real_z > Constants.chunkSize:
					real_z = real_z - Constants.chunkSize - 1
					real_x = real_x - Constants.chunkSize - 1
					chunk = chunksArray[p_c_x + 1][0][p_c_z + 1]
				elif real_x > Constants.chunkSize:
					real_x = real_x - Constants.chunkSize - 1
					chunk = chunksArray[p_c_x + 1][0][p_c_z]

				elif real_x < 0:

					real_x = Constants.chunkSize - abs(real_x) + 1
					chunk = chunksArray[p_c_x - 1][0][p_c_z]

				elif real_y > Constants.height:
					real_y = real_y - Constants.height - 1
					chunk = chunksArray[p_c_x][0][p_c_z]
				elif real_y < 0:
					real_y = Constants.chunkSize - abs(real_y) + 1
					chunk = chunksArray[p_c_x + 1][0][p_c_z]
				elif real_z > Constants.chunkSize:
					real_z = real_z - Constants.chunkSize - 1
					chunk = chunksArray[p_c_x][0][p_c_z + 1]
				elif real_z < 0:
					real_z = Constants.chunkSize - abs(real_z) + 1
					chunk = chunksArray[p_c_x][0][p_c_z - 1]
				else:
					chunk = chunksArray[p_c_x][0][p_c_z]
				if chunk not in chunks:
					chunks.append(chunk)
				chunk.delete_things(real_x, real_y, real_z)
	for c in chunks:
		c.commit_changes()
