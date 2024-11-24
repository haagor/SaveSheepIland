extends CharacterBody2D

const speed = 200
var wood_count = 0
	
var is_locked_movement = false

@onready var tilemap_bridge = $"/root/Game/player_build"
@onready var tilemap_cliff = $"/root/Game/cliffV2"
var is_building = false
var build_bridge_time: float = 3.0
var current_build_bridge_time: float = 0.0

func player_action(delta):	
	if Input.is_action_just_released("cut_tree"):
		is_locked_movement = false
	if Input.is_action_just_released("build"):
		is_locked_movement = false
		is_building = false
	if is_locked_movement:
		return
		
	if Input.is_action_pressed("ui_right"):
		$AnimatedSprite2D.flip_h = false
		$AnimatedSprite2D.play("walk")
		velocity.x = speed
		velocity.y = 0
	elif Input.is_action_pressed("ui_left"):
		$AnimatedSprite2D.flip_h = true
		$AnimatedSprite2D.play("walk")
		$TreeRayCast2D.rotation_degrees = 180
		velocity.x = -speed
		velocity.y = 0
	elif Input.is_action_pressed("ui_down"):
		$AnimatedSprite2D.play("walk")
		$TreeRayCast2D.rotation_degrees = 0
		velocity.x = 0
		velocity.y = speed
	elif Input.is_action_pressed("ui_up"):
		$AnimatedSprite2D.play("walk")
		velocity.x = 0
		velocity.y = -speed
	elif Input.is_action_pressed("cut_tree"):
		is_locked_movement = true
		$AnimatedSprite2D.play("cut_tree")
		velocity.x = 0
		velocity.y = 0
	elif Input.is_action_pressed("build"):
		if wood_count > 0 :
			is_locked_movement = true
			$AnimatedSprite2D.play("build")
			velocity.x = 0
			velocity.y = 0
			is_building = true
	else:
		$AnimatedSprite2D.play("idle")
		velocity.x = 0
		velocity.y = 0
		
	move_and_slide()
	
var current_tree: Node = null
var is_chopping: bool = false

func _physics_process(delta: float) -> void:
	player_action(delta)
	build(delta)
	if is_on_bridge(global_position):
		collision_layer = 1
		collision_mask = 2
	else:
		collision_layer = 1
		collision_mask = 1

	if $TreeRayCast2D.is_colliding():
		var body = $TreeRayCast2D.get_collider()
		if !is_instance_valid(body):
			current_tree = null
			is_chopping = false
		elif body.name.begins_with("tree"):
			current_tree = body
			if Input.is_action_pressed("cut_tree"):
				is_chopping = true
				if current_tree:
					current_tree.is_being_cut = true
			
			if current_tree.is_chopped && !current_tree.is_gathered:
				wood_count += 1
				$CanvasLayer/Control/NinePatchRect/Wood.text = str(wood_count)
				current_tree.is_gathered = true
			
	else:
		current_tree = null
	
	if Input.is_action_just_released("cut_tree"):
		is_chopping = false
		if current_tree:
			current_tree.is_being_cut = false
		
	if is_chopping and current_tree:
		current_tree.chop(delta)
		
func build(delta: float) -> void:
	if is_building :
		current_build_bridge_time += delta
		if current_build_bridge_time >= build_bridge_time:
			var cell_pos = tilemap_bridge.local_to_map(tilemap_bridge.to_local(global_position))
			var path: Array[Vector2i] = []
			path.append(cell_pos)
			path.append(Vector2i(cell_pos.x + 1, cell_pos.y))
			tilemap_bridge.set_cells_terrain_path(path, 0, 0, true)
			disable_collisions_on_layer(tilemap_cliff, path)
			current_build_bridge_time = 0
			wood_count -= 1
			$CanvasLayer/Control/NinePatchRect/Wood.text = str(wood_count)
			
func disable_collisions_on_layer(tilemap_layer: TileMapLayer, path: Array[Vector2i]):
	return
	var map_data = tilemap_layer.map  # Accès à la map associée au TileMapLayer
	
	for cell in path:
		var cell_data = map_data.get_cell_data(cell)
		if cell_data != null and cell_data.tile_id != -1:  # Si une cellule existe
			# Modifier les propriétés de collision
			cell_data.collision_layer = 0  # Supprime toutes les couches de collision
			cell_data.collision_mask = 0  # Désactive les collisions pour cette cellule
			map_data.set_cell_data(cell, cell_data)  # Applique les modifications

func is_on_bridge(player_position: Vector2) -> bool:
	var cell_pos = tilemap_bridge.local_to_map(tilemap_bridge.to_local(player_position))
	var tile_data = tilemap_bridge.get_cell_tile_data(cell_pos)
	
	if tile_data != null:
		return true
	return false
