extends Control

onready var title_label = $TitleLabel
onready var code_label = $CodeLabel
onready var threat_label = $ThreatLabel # RichTextLabel
onready var corrupt_button = $Corrupt

var selected_sector_node: SectorNode = null

func _ready():
	if corrupt_button:
		corrupt_button.connect("pressed", self, "_on_corrupt_pressed")

func display_sector_info(node: SectorNode):
	selected_sector_node = node
	show()
	
	# Set Labels (ID/Code are identical)
	title_label.text = node.sector_title
	code_label.text = node.sector_id
	
	# Set Threat Label via BBCode
	if threat_label:
		threat_label.bbcode_enabled = true
		threat_label.bbcode_text = node.get_threat_bbcode()
	
	# Update Corrupt Button state & styling
	match node.current_state:
		SectorNode.State.LOCKED:
			corrupt_button.text = "ACCESS DENIED"
			corrupt_button.modulate = Color("#707070") # Grey
			corrupt_button.disabled = true
			
		SectorNode.State.UNLOCKED:
			corrupt_button.text = "CORRUPT"
			corrupt_button.modulate = Color("#ffffff") # White
			corrupt_button.disabled = false
			
		SectorNode.State.CAPTURED:
			corrupt_button.text = "ENTER"
			corrupt_button.modulate = Color("#00ff66") # Green
			corrupt_button.disabled = false
			
		SectorNode.State.ACTIVE:
			corrupt_button.text = "CONTINUE"
			corrupt_button.modulate = Color("#ff3333") # Red
			corrupt_button.disabled = false

func _on_corrupt_pressed():
	if selected_sector_node:
		var sector_map = get_tree().current_scene
		if sector_map.has_method("launch_sector"):
			sector_map.launch_sector(selected_sector_node.sector_id)
