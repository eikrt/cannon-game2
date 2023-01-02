extends Node3D

var worldArray = []
var generateArray = []
var generatedArray = []
var width = 10.0
var height = 10.0
var tileSize = 10.0
var blockSize = 10.0

var generatedTiles = 0
var generateAmount = 0

var SEED = 0
var noise = OpenSimplexNoise.new()

var worldPreset
var generateThread
var updateThread
var currentState = false
var loadThread
var waterLevel = 0
var firstTilesGenerated = false

var token
var worldName

var viewDistance = 175

var multiMeshHelper = load("res://Assets/Ground/World3D/MultiMeshHelper.tscn")

func _ready():
	worldPreset = loadWorld(5)
	loadThread = Thread.new()
	loadThread.start(Callable(Callable(self,"preLoadWorld").bind("load"),2))
	get_tree().paused = true

func preLoadWorld(data):
	$LoadingScreen.setBackground(worldPreset.background)
	$LoadingScreen.setLoadingBar(0)
	$LoadingScreen.setText("Placing water...")
	get_node("Player/RigidBody3D").position = Vector3((width*tileSize*blockSize)/2,100,(height*tileSize*blockSize)/2)
	
	$Water.position.y = worldPreset.waterLevel
	waterLevel = worldPreset.waterLevel
	$Player/RigidBody3D.waterLevel = waterLevel
	worldPreset.loadPreset()
	
#	var goat = load("res://Assets/Space/Planets/5/animals/1.tscn")
#	for i in range(10):
#		var goatInstance = goat.instantiate()
#		goatInstance.get_node("CharacterBody3D").position = Vector3(width*tileSize/2,200,height*tileSize/2)+Vector3(randf_range(-25,25),randf_range(0,20),randf_range(-25,25))
#		goatInstance.get_node("CharacterBody3D").waterLevel = waterLevel
##		goatInstance.get_node("CharacterBody3D").rotation = Vector3(0,randf_range(-2,2),0)
#		call_deferred("add_child",goatInstance)
	
	$Sun.originalFog = worldPreset.fogColor
	$Sun.darkFog = worldPreset.darkFog
	$LoadingScreen.setText("Preparing tiles...")
	prepareWorldArray()
	
	if SEED == 0:
		randomize()
		SEED = randf_range(0,100000)
#		SEED = 9
	
	noise.seed = round(SEED)
#	noise.octaves = 40
#	noise.period = 2
#	noise.persistence = 1
	seed(round(SEED))
	
	$LoadingScreen.setText("Placing objects...")
	worldPreset.generateWorld(self)
	generateFirstTiles()
	
	waterLevel = 69
	$Water.mesh.size.x = width*tileSize*blockSize
	$Water.mesh.size.y = height*tileSize*blockSize
	$Water.mesh.subdivide_depth = round(height*tileSize*blockSize/2.5)
	$Water.mesh.subdivide_width = round(width*tileSize*blockSize/2.5)
	$Water.position.x = width*tileSize*blockSize/2
	$Water.position.z = height*tileSize*blockSize/2
	$Water.material_override = load("res://Assets/Ground/Water/WaterShader.tres")
	$Water.position.y = waterLevel
	$Player/RigidBody3D.waterLevel = waterLevel
	
	get_node("LoadingScreen").setLoadingBar(101)
	while($LoadingScreen.loading):
		pass
	
#	$Player/RigidBody3D.movePlayerToGround()
	get_node("Player/RigidBody3D").respawnLocation = get_node("Player/RigidBody3D").position
	print("FIX WATER")
	get_node("Sun").sunActive = true
	
	$Player/Sprite2D/AnimationPlayer.play("Remove")
	toggleThread(true)
	updateThread = Thread.new()
	updateThread.start(Callable(Callable(self,"updateChunkMeshes").bind("generate"),2))

func loadWorld(type):
	return load("res://Assets/Space/Planets/"+str(type)+"/NewWorldPreset.gd").new()

func prepareWorldArray():
	$LoadingScreen.setLoadingBar(5)
	$LoadingScreen.setText("Preparing tiles...")
	var tileAsset = load("res://Assets/Ground/World3D/Chunk.tscn")
	var generated = 0.0
	var i = 0
	for x in range(width):
		worldArray.append([])
		for y in range(height):
			worldArray[x].append(tileAsset.instantiate())
			worldArray[x][y].pos = Vector3(x*tileSize*blockSize,0,y*tileSize*blockSize)
			worldArray[x][y].position = Vector3(x*tileSize*blockSize,0,y*tileSize*blockSize)
			worldArray[x][y].x = x
			worldArray[x][y].y = y
			worldArray[x][y].size = tileSize
			worldArray[x][y].blockSize = blockSize
			worldArray[x][y].createGrid()
			generated += 1
			i += 1
			if i > 100:
				i = 0
				get_node("LoadingScreen").setLoadingBar(5+(generated/(width*height)*30))
	
	for x in range(width):
		for y in range(height):
			if x < width-1 and y < height-1:
				generateAmount += 1
				generateArray.append(worldArray[x][y])
				worldArray[x][y].dist = get_node("Player/RigidBody3D").position.distance_to(worldArray[x][y].pos+Vector3(tileSize*blockSize/2,0,tileSize*blockSize/2))
	
	generateArray.sort_custom(Callable(self,"sortBySize"))

func sortBySize(tile1,tile2):
	if tile1.get("dist") and tile2.get("dist"):
		var a = tile1.dist
		var b = tile2.dist
		return a < b
	else:
		return false

func generateWorld(data):
	while generateArray.size() > 0 and currentState:
		var amountOfTiles = 50
		if amountOfTiles > generateArray.size():
			amountOfTiles = generateArray.size()
		
		var tilesToGenerate = []
		for i in range(amountOfTiles):
			if generateArray[i].dist < viewDistance:
				tilesToGenerate.append(generateArray[i])
		
		for tile in tilesToGenerate:
			self.call_deferred("add_child", tile)
			tile.call_deferred("updateMesh")
			tile.placeObjects()
			generatedArray.append(tile)
			generateArray.erase(tile)
		
#		REMOVE TILES
		if generatedArray.size() > 0:
			for i in generatedArray:
				if i.dist >= viewDistance:
					i.removeObjects()
					self.call_deferred("remove_child", i)
					generatedArray.erase(i)
					generateArray.append(i)
		
#		CALCULATE DISTANCE FROM PLAYER
		for i in generateArray:
			i.dist = Vector3(get_node("Player/RigidBody3D").position.x,0,get_node("Player/RigidBody3D").position.z).distance_to(Vector3(i.pos.x+(tileSize*blockSize/2),0,i.pos.z+(tileSize*blockSize/2)))
		
		for i in generatedArray:
			i.dist = Vector3(get_node("Player/RigidBody3D").position.x,0,get_node("Player/RigidBody3D").position.z).distance_to(Vector3(i.pos.x+(tileSize*blockSize/2),0,i.pos.z+(tileSize*blockSize/2)))
		
		generateArray.sort_custom(Callable(self,"sortBySize"))
		generatedArray.sort_custom(Callable(self,"sortBySize"))
		
#		for x in range(width):
#			for y in range(height):
#				var tile = worldArray[x][y]
#				tile.surfaceLevel -= 0.2
		

func updateChunkMeshes(data):
	while true:
		for tile in generatedArray:
			print("UPDATE")
			tile.updateMesh()

func generateFirstTiles():
	var tilesToGenerate = []
	for i in range(generateArray.size()):
		if generateArray[i].dist < viewDistance:
			tilesToGenerate.append(generateArray[i])

	get_node("LoadingScreen").setText("Preparing starting area...")
	var placed = 0.0
	var i = 0
	for tile in tilesToGenerate:
		call_deferred("add_child",tile)
		tile.updateMesh()
		tile.placeObjects()
		generatedArray.append(tile)
		generateArray.erase(tile)
		placed += 1

		i += 1
		if i > 10:
			i = 0
			get_node("LoadingScreen").setLoadingBar(50+(placed/(tilesToGenerate.size())*45))

	get_node("LoadingScreen").setLoadingBar(99)
	print("DONE LOADING")
	firstTilesGenerated = true

func getAverageHeight(tile):
	return (tile.pos.y+worldArray[tile.x+1][tile.y].pos.y+worldArray[tile.x+1][tile.y+1].pos.y+worldArray[tile.x][tile.y+1].pos.y)/4

func _notification(what):
	if what == MainLoop.NOTIFICATION_APPLICATION_FOCUS_OUT && OS.get_name().nocasecmp_to("windows") != 0:
		toggleThread(false)
	
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		get_tree().quit()

func getChunkPosition(trans):
	return Vector3(floor(trans.x/width*tileSize*blockSize),0,floor(trans.z/height*tileSize*blockSize))

func getBlockPosition(trans):
	var transInChunk = trans-(getChunkPosition(trans)*tileSize*blockSize)
	return Vector3(floor(transInChunk.x/blockSize),floor(transInChunk.x/blockSize),floor(transInChunk.x/blockSize))

func toggleThread(state):
	if state and !currentState:
		currentState = state
		generateThread = Thread.new()
		generateThread.start(Callable(Callable(self,"generateWorld").bind("generate"),2))
	
	currentState = state