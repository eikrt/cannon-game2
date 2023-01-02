extends Node3D

var day = true
var originalFog
var darkFog
var sunActive = false

var timePassed = 0
var timeSinceChange = 100

func _process(delta):
	if sunActive:
		var playerPos = get_parent().get_node("Player/RigidBody3D/FirstPersonCamera").get_global_transform().origin
		position = playerPos
#		self.rotation_degrees.x += 0.6*delta
		
		if !day:
			self.rotation_degrees.x += 0.6*delta
		
		timePassed += delta
		timeSinceChange += delta
		if timePassed > 0.2:
			timePassed = 0
			get_parent().get_node("sunlight").rotation_degrees = rotation_degrees
			
			var sunPos = $MeshInstance3D.get_global_transform().origin-get_parent().get_node("Player/RigidBody3D").get_global_transform().origin
			day = (sunPos.y >= -15)
			if sunPos.y < 50 and sunPos.y > 20 and timeSinceChange > 60:
	#			day = false
				timeSinceChange = 0
				
				var darkFog = get_parent().worldPreset.darkFog
				var fogColor = get_parent().worldPreset.fogColor
				var trackId = $AnimationPlayer.get_animation("turnNight").find_track("../WorldEnvironment:environment:fog_color")
				$AnimationPlayer.get_animation("turnNight").track_set_key_value(trackId,1, darkFog)
				$AnimationPlayer.get_animation("turnNight").track_set_key_value(trackId,0, fogColor)
				
#				$AnimationPlayer.play("turnNight")
#				get_parent().get_node("Player/RigidBody3D/FirstPersonCamera/SpotLight3D").turnOn()
#				print("NIGHT")
			
			if sunPos.y > -15 and sunPos.y < 0 and timeSinceChange > 60:
	#			day = true
				timeSinceChange = 0
				
				var darkFog = get_parent().worldPreset.darkFog
				var fogColor = get_parent().worldPreset.fogColor
				var trackId = $AnimationPlayer.get_animation("turnNight").find_track("../WorldEnvironment:environment:fog_color")
				$AnimationPlayer.get_animation("turnDay").track_set_key_value(trackId,0, darkFog)
				$AnimationPlayer.get_animation("turnDay").track_set_key_value(trackId,1, fogColor)
				
#				$AnimationPlayer.play("turnDay")
#				get_parent().get_node("Player/RigidBody3D/FirstPersonCamera/SpotLight3D").turnOff()
#				print("DAY")
