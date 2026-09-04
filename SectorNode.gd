extends Button
class_name SectorNode

enum State { LOCKED, UNCAPTURED, UNLOCKED, ACTIVE, CAPTURED }
enum ThreatLevel { AGGRESSIVE, PERMISSIVE, BALANCED, ZERO_TRUST, UNSTABLE }

export(String) var sector_id = "USB_INPUT" # Unique ID & Display Code
export(String) var sector_title = "USB PORT" # Display Title
export(ThreatLevel) var threat_level = ThreatLevel.AGGRESSIVE
export(State) var current_state = State.LOCKED setget set_state

const COLOR_MAP = {
	State.LOCKED: Color("#707070"),     # Grey
	State.UNCAPTURED: Color("#ffffff"), # White
	State.UNLOCKED: Color("#00aaff"),   # Blue
	State.ACTIVE: Color("#ff3333"),     # Red
	State.CAPTURED: Color("#00ff66")    # Green
}

const THREAT_BBCODE = {
	ThreatLevel.AGGRESSIVE: "[color=red][center][b]Aggressive[/b][/center][/color]",
	ThreatLevel.PERMISSIVE: "[color=green][center][b]Permissive[/b][/center][/color]",
	ThreatLevel.BALANCED: "[color=yellow][center][b]Balanced[/b][/center][/color]",
	ThreatLevel.ZERO_TRUST: "[color=purple][center][b]Zero Trust[/b][/center][/color]",
	ThreatLevel.UNSTABLE: "[color=#00e5ff][center][b]0110010101110010011100100110111101110010[/b][/center][/color]"
}

func _ready():
	connect("pressed", self, "_on_sector_pressed")
	update_visuals()

func set_state(new_state: int):
	current_state = new_state
	update_visuals()

func update_visuals():
	var outline_color = COLOR_MAP.get(current_state, Color.white)
	self.modulate = outline_color

func get_threat_bbcode() -> String:
	return THREAT_BBCODE.get(threat_level, "[center]UNKNOWN[/center]")

func _on_sector_pressed():
	var sector_map = get_tree().current_scene
	if sector_map.has_method("select_sector"):
		sector_map.select_sector(self)
