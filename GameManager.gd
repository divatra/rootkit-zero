extends Node

# Persistent global variables accessible across all scenes
var current_sector_id: String = "S_BIOS_BOOT"
var player_build_version: String = "0.01"

func _ready():
	print("GameManager loaded cleanly!")

# Global helper function to change scenes cleanly from anywhere
func change_scene(scene_path: String):
	get_tree().change_scene(scene_path)

# Global helper function to quit the game cleanly
func quit_game():
	get_tree().quit()
