extends Node2D

# 1. References to your stacked TileMap nodes in the scene hierarchy
onready var terrain_tilemap = $GridMaps/TerrainTileMap
onready var resource_tilemap = $GridMaps/ResourceTileMap
onready var structure_tilemap = $GridMaps/StructureTileMap
onready var overlay_tilemap = $GridMaps/OverlayTileMap

# 2. Configurable properties visible in Godot's Inspector panel
export (String) var active_sector_id = "S_BIOS_BOOT" # Name used when generating/loading the JSON file
export (bool) var is_editor_mode = true              # True = Paint mode active | False = Play mode active
export (float) var camera_speed = 400.0              # WASD camera pan speed in pixels/sec

# 3. Editor runtime variables
var current_selected_tile_id = 0
var active_layer = "terrain" # Active painting layer: "terrain", "resource", "structure", "overlay"
var camera: Camera2D = null
var is_middle_mouse_dragging = false

func _ready():
	
	
	if is_editor_mode:
		load_sector_from_json(active_sector_id)
	else:
		load_sector_from_json(GameManager.current_sector_id)

func _process(delta):
	# CAMERA MOVEMENT (WASD / Arrows) in Editor Mode
	if is_editor_mode and camera:
		var move_dir = Vector2.ZERO
		if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):    move_dir.y -= 1
		if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):  move_dir.y += 1
		if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):  move_dir.x -= 1
		if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT): move_dir.x += 1
		
		camera.position += move_dir.normalized() * camera_speed * delta

func _unhandled_input(event):
	# SAVE KEY: Press F1 to export map to JSON
	if event is InputEventKey and event.pressed and event.scancode == KEY_F1:
		export_sector_to_json(active_sector_id)

	# LAYER SELECTION HOTKEYS (F2 = Terrain, F3 = Resource, F4 = Structure, F5 = Overlay)
	if event is InputEventKey and event.pressed:
		if event.scancode == KEY_F2:
			active_layer = "terrain"
			print("Active Layer Set To: TERRAIN")
		elif event.scancode == KEY_F3:
			active_layer = "resource"
			print("Active Layer Set To: RESOURCE")
		elif event.scancode == KEY_F4:
			active_layer = "structure"
			print("Active Layer Set To: STRUCTURE")
		elif event.scancode == KEY_F5:
			active_layer = "overlay"
			print("Active Layer Set To: OVERLAY")

	# TILE SELECTION VIA NUMPAD / NUMBER KEYS (0 to 9)
	if event is InputEventKey and event.pressed:
		if event.scancode >= KEY_0 and event.scancode <= KEY_9:
			current_selected_tile_id = event.scancode - KEY_0
			print("Selected Tile ID: ", current_selected_tile_id)
		elif event.scancode >= KEY_KP_0 and event.scancode <= KEY_KP_9:
			current_selected_tile_id = event.scancode - KEY_KP_0
			print("Selected Tile ID: ", current_selected_tile_id)

	# EDITOR CONTROLS & CAMERA PANNING
	if is_editor_mode:
		# Middle Mouse Click-and-Drag Panning
		if event is InputEventMouseButton and event.button_index == BUTTON_MIDDLE:
			is_middle_mouse_dragging = event.pressed
		elif event is InputEventMouseMotion and is_middle_mouse_dragging and camera:
			camera.position -= event.relative

		# PAINT / ERASE CONTROLS
		var target_map = _get_active_tilemap()
		if target_map:
			if Input.is_mouse_button_pressed(BUTTON_LEFT):
				var mouse_pos = get_global_mouse_position()
				var cell_pos = target_map.world_to_map(mouse_pos)
				
				target_map.set_cell(cell_pos.x, cell_pos.y, current_selected_tile_id)
				if target_map.has_method("update_bitmask_region"):
					target_map.update_bitmask_region()

			elif Input.is_mouse_button_pressed(BUTTON_RIGHT):
				var mouse_pos = get_global_mouse_position()
				var cell_pos = target_map.world_to_map(mouse_pos)
				
				target_map.set_cell(cell_pos.x, cell_pos.y, -1)

# Helper function to target the right TileMap based on active mode
func _get_active_tilemap() -> TileMap:
	match active_layer:
		"terrain": return terrain_tilemap
		"resource": return resource_tilemap
		"structure": return structure_tilemap
		"overlay": return overlay_tilemap
		_: return terrain_tilemap



# SAVE SYSTEM (Exports all TileMap layers to structured JSON)
func export_sector_to_json(sector_id: String):
	var sector_dict = {
		"sector_id": sector_id,
		"terrain_tiles": _extract_map_data(terrain_tilemap),
		"resource_tiles": _extract_map_data(resource_tilemap),
		"structure_tiles": _extract_map_data(structure_tilemap),
		"overlay_tiles": _extract_map_data(overlay_tilemap)
	}

	var dir = Directory.new()
	if not dir.dir_exists("res://data"):
		dir.make_dir("res://data")

	var file_path = "res://data/" + sector_id + ".json"
	var file = File.new()
	
	if file.open(file_path, File.WRITE) == OK:
		file.store_string(JSON.print(sector_dict, "  "))
		file.close()
		print("SUCCESS: Sector saved with all layers -> ", file_path)

# Helper function to serialize cells into dictionaries
func _extract_map_data(tilemap: TileMap) -> Array:
	var tile_list = []
	if not tilemap:
		return tile_list
		
	var used_cells = tilemap.get_used_cells()
	for cell in used_cells:
		var tile_id = tilemap.get_cell(cell.x, cell.y)
		tile_list.append({
			"x": int(cell.x),
			"y": int(cell.y),
			"tile_id": tile_id
		})
	return tile_list

# LOAD SYSTEM (Loads data back into each corresponding TileMap)
func load_sector_from_json(sector_id: String):
	var file_path = "res://data/" + sector_id + ".json"
	var file = File.new()
	
	if not file.file_exists(file_path):
		print("No JSON data file found for sector: ", sector_id)
		return

	if file.open(file_path, File.READ) == OK:
		var json_result = JSON.parse(file.get_as_text())
		file.close()
		
		if json_result.error == OK:
			var data = json_result.result
			
			_populate_tilemap(terrain_tilemap, data.get("terrain_tiles", []))
			_populate_tilemap(resource_tilemap, data.get("resource_tiles", []))
			_populate_tilemap(structure_tilemap, data.get("structure_tiles", []))
			_populate_tilemap(overlay_tilemap, data.get("overlay_tiles", []))
			
			print("SUCCESS: Loaded multi-layer sector ", sector_id, " from JSON!")

# Helper function to populate and update bitmask for a TileMap layer
func _populate_tilemap(tilemap: TileMap, tile_data_array: Array):
	if not tilemap:
		return
		
	tilemap.clear()
	for tile_data in tile_data_array:
		tilemap.set_cell(tile_data["x"], tile_data["y"], tile_data["tile_id"])
		
	if tilemap.has_method("update_bitmask_region"):
		tilemap.update_bitmask_region()
