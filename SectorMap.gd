extends Control

onready var loading_overlay = $UI/LoadingOverlay
onready var info_panel = $UI/InfoPanel
onready var lines_folder = $MapContainer/Lines

func _ready():
	loading_overlay.hide()
	info_panel.hide()
	refresh_bus_lines()

func refresh_bus_lines():
	if lines_folder:
		for line in lines_folder.get_children():
			if line is SectorBusLine:
				line.check_and_update_connection()

func select_sector(node: SectorNode):
	# Displays InfoPanel without instantly changing scenes
	info_panel.display_sector_info(node)

func launch_sector(target_sector_id: String):
	# Triggered when Corrupt button is clicked inside InfoPanel
	info_panel.hide()
	loading_overlay.show()
	
	GameManager.current_sector_id = target_sector_id
	
	yield(get_tree().create_timer(0.5), "timeout")
	get_tree().change_scene("res://MainLevel.tscn")


func _on_BackButton_pressed():
	get_tree().change_scene("res://HomeScreen.tscn")
