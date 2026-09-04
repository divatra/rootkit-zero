extends Node

func _ready():
	# Give the C++ library a brief moment to initialize
	yield(get_tree(), "idle_frame")
	update_presence()

func update_presence() -> void:
	# Guard clause: Check if activity_manager is null
	if Discord.activity_manager == null:
		push_error("Discord Activity Manager is Nil! Ensure Desktop Discord is open.")
		return

	var activity = Discord.Activity.new()
	activity.set_type(Discord.ActivityType.Playing)
	
	# Leave blank so Discord ONLY displays "Playing Rootkit Zero"
	activity.set_state("")
	activity.set_details("")

	var result = yield(Discord.activity_manager.update_activity(activity), "result").result
	if result != Discord.Result.Ok:
		push_error("Discord status update failed: " + str(result))
