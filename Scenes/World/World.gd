extends Node3D

var worldArray = []
var generateArray = []
var generatedArray = []
var width = 50
var height = 50
var tileSize = 10

var generatedTiles = 0
var generateAmount = 0

var SEED = 0
var noise = OpenSimplexNoise.new()

var worldPreset
var generateThread
var currentState = false
var loadThread
var waterLevel = 0
var firstTilesGenerated = false

var token
var worldName

var viewDistance = 150

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
	get_node("Player/RigidBody3D").position = Vector3(width*tileSize/2,10,height*tileSize/2)
	
	$Water.position.y = worldPreset.waterLevel
	waterLevel = worldPreset.waterLevel
	$Player/RigidBody3D.waterLevel = waterLevel
	worldPreset.loadPreset()
	
	var goat = load("res://Assets/Space/Planets/5/animals/1.tscn")
	for i in range(10):
		var goatInstance = goat.instantiate()
		goatInstance.get_node("CharacterBody3D").position = Vector3(width*tileSize/2,200,height*tileSize/2)+Vector3(randf_range(-25,25),randf_range(0,20),randf_range(-25,25))
		goatInstance.get_node("CharacterBody3D").waterLevel = waterLevel
#		goatInstance.get_node("CharacterBody3D").rotation = Vector3(0,randf_range(-2,2),0)
		call_deferred("add_child",goatInstance)
	
	$Sun.originalFog = worldPreset.fogColor
	$Sun.darkFog = worldPreset.darkFog
	$LoadingScreen.setText("Preparing tiles...")
	prepareWorldArray()
	
	if SEED == 0:
		randomize()
		SEED = randf_range(0,100000)
#		SEED = 9
	
	noise.seed = SEED
	noise.octaves = 40
	noise.period = 2
	noise.persistence = 1
	seed(round(SEED))
	
	$LoadingScreen.setText("Placing objects...")
	worldPreset.generateWorld(self)
	generateFirstTiles()
	
	$Water.mesh.size.x = width*tileSize
	$Water.mesh.size.y = height*tileSize
	$Water.mesh.subdivide_depth = round(height*tileSize/2.5)
	$Water.mesh.subdivide_width = round(width*tileSize/2.5)
	$Water.position.x = width*tileSize/2
	$Water.position.z = height*tileSize/2
	$Water.material_override = load("res://Assets/Ground/Water/WaterShader.tres")
	
	get_node("LoadingScreen").setLoadingBar(101)
	while($LoadingScreen.loading):
		pass
	
	$Player/RigidBody3D.movePlayerToGround()
	get_node("Player/RigidBody3D").respawnLocation = get_node("Player/RigidBody3D").position
	print("FIX WATER")
	get_node("Sun").sunActive = true
	
	$Player/Sprite2D/AnimationPlayer.play("Remove")
	toggleThread(true)

func loadWorld(type):
	return load("res://Assets/Space/Planets/"+str(type)+"/worldPreset.gd").new()

func prepareWorldArray():
	$LoadingScreen.setLoadingBar(5)
	$LoadingScreen.setText("Preparing tiles...")
	var tileAsset = load("res://Assets/Ground/World3D/tile.tscn")
	var generated = 0.0
	var i = 0
	for x in range(width):
		worldArray.append([])
		for y in range(height):
			worldArray[x].append(tileAsset.instantiate())
			worldArray[x][y].pos = Vector3(x*tileSize,0,y*tileSize)
			worldArray[x][y].x = x
			worldArray[x][y].y = y
			call_deferred("add_child",worldArray[x][y])
			
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
				worldArray[x][y].dist = get_node("Player/RigidBody3D").position.distance_to(worldArray[x][y].pos)
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
			addMeshToWorld(tile.x,tile.y)
			generatedArray.append(tile)
			generateArray.erase(tile)
		
#		REMOVE TILES
		if generatedArray.size() > 0:
			for i in generatedArray:
				if i.dist >= viewDistance:
					i.removeObjects(self)
					i.call_deferred("remove_child",i.tile)
					generatedArray.erase(i)
					generateArray.append(i)
		
#		CALCULATE DISTANCE FROM PLAYER
		for i in generateArray:
			i.dist = Vector3(get_node("Player/RigidBody3D").position.x,0,get_node("Player/RigidBody3D").position.z).distance_to(Vector3(i.pos.x,0,i.pos.z))
		
		for i in generatedArray:
			i.dist = Vector3(get_node("Player/RigidBody3D").position.x,0,get_node("Player/RigidBody3D").position.z).distance_to(Vector3(i.pos.x,0,i.pos.z))
		generateArray.sort_custom(Callable(self,"sortBySize"))
		generatedArray.sort_custom(Callable(self,"sortBySize"))

func generateFirstTiles():
	var tilesToGenerate = []
	for i in range(generateArray.size()):
		if generateArray[i].dist < viewDistance*0.5:
			tilesToGenerate.append(generateArray[i])

	get_node("LoadingScreen").setText("Preparing starting area...")
	var placed = 0.0
	var i = 0
	for tile in tilesToGenerate:
		addMeshToWorld(tile.x,tile.y)
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

func addMeshToWorld(x,y):
	var tile = worldArray[x][y]
	if !tile.generated:
		setTileMesh(tile,x,y)
	else:
		tile.call_deferred("add_child", tile.tile)
	tile.placeObjects(self)

func setTileMesh(tile,x,y):
	var meshInstance = MeshInstance3D.new()
	meshInstance.mesh = createMesh(worldArray[x][y].pos,worldArray[x+1][y].pos,worldArray[x+1][y+1].pos,worldArray[x][y+1].pos)
	meshInstance.material_override = worldPreset.getMaterial(tile.type)
	tile.call_deferred("add_child",meshInstance)
	tile.tile = meshInstance
	meshInstance.create_convex_collision()
	
	tile.generated = true

func createMesh(pos1,pos2,pos3,pos4):
	var surfTool = SurfaceTool.new()
	var mesh = Mesh.new()
	var color = Color(1,1,1)

	surfTool.begin(Mesh.PRIMITIVE_TRIANGLES)

	var uv1 = Vector2(0,0)
	var v1 = pos1
	var uv2 = Vector2(1,0)
	var v2 = pos2
	var uv3 = Vector2(1,1)
	var v3 = pos3
	var uv4 = Vector2(0,1)
	var v4 = pos4

	var uvarray = [ uv1, uv2, uv3, uv4]
	var varray = [ v1, v2, v3, v4]
	var carray = [color,color,color]
	surfTool.add_triangle_fan(varray,uvarray, carray)

	surfTool.generate_normals()
	surfTool.index()

	surfTool.commit(mesh)
	return mesh

func getAverageHeight(tile):
	return (tile.pos.y+worldArray[tile.x+1][tile.y].pos.y+worldArray[tile.x+1][tile.y+1].pos.y+worldArray[tile.x][tile.y+1].pos.y)/4

func _notification(what):
	if what == MainLoop.NOTIFICATION_APPLICATION_FOCUS_OUT && OS.get_name().nocasecmp_to("windows") != 0:
		toggleThread(false)
	
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		get_tree().quit()

func toggleThread(state):
	if state and !currentState:
		currentState = state
		generateThread = Thread.new()
		generateThread.start(Callable(Callable(self,"generateWorld").bind("generate"),2))
	
	currentState = state