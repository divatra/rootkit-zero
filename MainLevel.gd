extends Node2D

# 1. References to your stacked TileMap nodes in the scene hierarchy
onready var terrain_tilemap = $GridMaps/TerrainTileMap
onready var structure_tilemap = $GridMaps/StructureTileMap
onready var overlay_tilemap = $GridMaps/OverlayTileMap

# 2. Configurable properties visible in Godot's Inspector panel
export (String) var active_sector_id = "S_BIOS_BOOT" # Name used when generating/loading the JSON file
export (bool) var is_editor_mode = true              # True = Paint mode active | False = Play mode active
	 # WASD camera pan speed in pixels/sec

# 3. Editor runtime variables
var current_selected_tile_id = 0

var is_middle_mouse_dragging = false

func _ready():
	# Dynamically setup a Camera2D if one isn't attached to the scene

	
	if is_editor_mode:
		# Loads JSON matching the active_sector_id on editor startup
		load_sector_from_json(active_sector_id)
	else:
		# Gameplay load from GameManager state
		load_sector_from_json(GameManager.current_sector_id)



func _unhandled_input(event):
	# SAVE KEY: Press F1 anytime to export map to JSON
	if event is InputEventKey and event.pressed and event.scancode == KEY_F1:
		export_sector_to_json(active_sector_id)

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
		
		# PAINT / ERASE CONTROLS
		if Input.is_mouse_button_pressed(BUTTON_LEFT):
			var mouse_pos = get_global_mouse_position()
			var cell_pos = terrain_tilemap.world_to_map(mouse_pos)
			
			terrain_tilemap.set_cell(cell_pos.x, cell_pos.y, current_selected_tile_id)
			terrain_tilemap.update_bitmask_region()

		elif Input.is_mouse_button_pressed(BUTTON_RIGHT):
			var mouse_pos = get_global_mouse_position()
			var cell_pos = terrain_tilemap.world_to_map(mouse_pos)
			
			terrain_tilemap.set_cell(cell_pos.x, cell_pos.y, -1)


# SAVE SYSTEM
func export_sector_to_json(sector_id: String):
	var used_cells = terrain_tilemap.get_used_cells()
	if used_cells.empty():
		print("Cannot export: TerrainTileMap is empty!")
		return

	var tiles_array = []
	for cell in used_cells:
		var tile_id = terrain_tilemap.get_cell(cell.x, cell.y)
		tiles_array.append({
			"x": int(cell.x),
			"y": int(cell.y),
			"tile_id": tile_id
		})

	var sector_dict = {
		"sector_id": sector_id,
		"terrain_tiles": tiles_array
	}

	var dir = Directory.new()
	if not dir.dir_exists("res://data"):
		dir.make_dir("res://data")

	var file_path = "res://data/" + sector_id + ".json"
	var file = File.new()
	
	if file.open(file_path, File.WRITE) == OK:
		file.store_string(JSON.print(sector_dict, "  "))
		file.close()
		print("SUCCESS: Sector saved to -> ", file_path)

# LOAD SYSTEM
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
			terrain_tilemap.clear()
			
			for tile_data in data["terrain_tiles"]:
				terrain_tilemap.set_cell(tile_data["x"], tile_data["y"], tile_data["tile_id"])
				
			terrain_tilemap.update_bitmask_region()
			print("SUCCESS: Loaded ", sector_id, " from JSON!")
