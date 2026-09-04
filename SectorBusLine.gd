extends Line2D
class_name SectorBusLine

export(NodePath) var from_sector_path
export(NodePath) var to_sector_path

onready var tween = Tween.new()

func _ready():
	add_child(tween)
	default_color = Color("#404040") # Default inactive grey line color

func check_and_update_connection():
	var from_node = get_node_or_null(from_sector_path) as SectorNode
	var to_node = get_node_or_null(to_sector_path) as SectorNode

	if not from_node or not to_node:
		return

	# Connection activates if both connected sectors are UNLOCKED or CAPTURED
	var is_from_valid = from_node.current_state in [SectorNode.State.UNLOCKED, SectorNode.State.CAPTURED]
	var is_to_valid = to_node.current_state in [SectorNode.State.UNLOCKED, SectorNode.State.CAPTURED]

	if is_from_valid and is_to_valid:
		animate_flow_fill(Color("#00ff66")) # Smooth fill to glowing green

func animate_flow_fill(target_color: Color):
	tween.stop_all()
	
	# Smoothly fills default_color from grey to target_color over 1.2 seconds
	tween.interpolate_property(
		self, "default_color",
		default_color, target_color,
		1.2, Tween.TRANS_QUAD, Tween.EASE_IN_OUT
	)
	tween.start()
