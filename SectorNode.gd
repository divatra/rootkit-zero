extends TextureButton

# Exported variables show up directly in the Godot Inspector
export (String) var sector_id = "S_BIOS_BOOT"
export (String) var sector_name = "BIOS Boot Sector"
export (bool) var is_data_sector = false # Distinguishes main sectors from optional A-32 data banks
export (Array, NodePath) var connected_nodes = [] # Drag & drop neighboring sector nodes here

# Internal state tracking
var is_unlocked: bool = false
var is_cleared: bool = false

# Custom signal sent to the parent map when this node is clicked
signal sector_selected(node_ref)

func _ready():
	# Display the sector code underneath the node icon
	$NodeLabel.text = sector_id
	
	# Connect Godot's built-in "pressed" button signal to our internal function
	connect("pressed", self, "_on_pressed")

func update_visual_state():
	# Changes the node's glow color based on game state
	if is_cleared:
		modulate = Color(0.2, 1.0, 0.4) # Bright green if captured
	elif is_unlocked:
		modulate = Color(1.0, 0.9, 0.2) # Bright yellow if available to attack
	else:
		modulate = Color(0.3, 0.3, 0.3) # Dark grey if locked
		disabled = true # Prevents clicking locked sectors

func _on_pressed():
	# Emits our custom signal and passes 'self' (this node) as data
	emit_signal("sector_selected", self)
