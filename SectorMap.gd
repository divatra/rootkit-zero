extends Control

# Onready variable references to scene UI elements
onready var lines_container = $LinesContainer
onready var nodes_container = $NodesContainer
onready var info_panel = $UI/InfoPanel
onready var title_label = $UI/InfoPanel/TitleLabel
onready var type_label = $UI/InfoPanel/ThreatLabel
onready var launch_button = $UI/InfoPanel/Corrupt
onready var back_button = $UI/Header/BackButton

# Stores the currently clicked sector node object
var selected_node = null

func _ready():
	# Hide the information sidebar on startup
	info_panel.hide()
	
	# Wire up UI button click events
	back_button.connect("pressed", self, "_on_back_pressed")
	launch_button.connect("pressed", self, "_on_launch_pressed")
	
	# Loop through every SectorNode on the web and listen for clicks
	for child in nodes_container.get_children():
		if child.has_signal("sector_selected"):
			child.connect("sector_selected", self, "_on_sector_selected")
			child.update_visual_state()
			
	# Request Godot to trigger the _draw() function for network lines
	update()

func _on_sector_selected(node_ref):
	# Store the clicked node reference
	selected_node = node_ref
	
	# Populate panel labels with the node's properties
	title_label.text = node_ref.sector_name + " [" + node_ref.sector_id + "]"
	
	if node_ref.is_data_sector:
		type_label.text = "TYPE: OPTIONAL DATA BANK"
	else:
		type_label.text = "TYPE: MAIN CAMPAIGN NODE"
		
	# Reveal the selection sidebar
	info_panel.show()

func _on_launch_pressed():
	# Ensure a node is actively selected before changing scenes
	if selected_node:
		# Pass selected sector ID to global manager and transition to the level
		GameManager.current_sector_id = selected_node.sector_id
		GameManager.change_scene("res://MainLevel.tscn")

func _on_back_pressed():
	# Return back to the main menu
	GameManager.change_scene("res://HomeScreen.tscn")

func _draw():
	# Iterate through every node container to render connection lines
	for child in nodes_container.get_children():
		if "connected_nodes" in child:
			for target_path in child.connected_nodes:
				var target_node = get_node_or_null(target_path)
				if target_node:
					# Calculate center point coordinates of source and target buttons
					var start_pos = child.rect_global_position + (child.rect_size / 2)
					var end_pos = target_node.rect_global_position + (target_node.rect_size / 2)
					
					# Draw glowing red connection line on the canvas
					var line_color = Color(0.9, 0.1, 0.2, 0.6)
					draw_line(start_pos, end_pos, line_color, 2.0, true)
					draw_line(start_pos, end_pos, line_color, 2.0, true)
					draw_line(start_pos, end_pos, line_color, 2.0, true)
