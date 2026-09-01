extends KinematicBody2D

export (int) var move_speed = 250
# Rotation offset in degrees (Adjust this in Inspector if your artwork faces Up/Down instead of Right)
# Standard values: 0 = Sprite faces Right | 90 = Sprite faces Down | -90 = Sprite faces Up | 180 = Sprite faces Left
export (float) var sprite_rotation_offset_degrees =90

# Smooth rotation speed (higher = faster snapping turn)
export (float) var rotation_speed = 12.0 

onready var sprite_stack = $SpriteStack
onready var base_sprite = $SpriteStack/zero_base
onready var highlights_sprite = $SpriteStack/highlights
onready var indicators_sprite = $SpriteStack/indicators

var velocity = Vector2.ZERO

func _ready():
	# Start playing the "default" animation loop across all 3 layers on launch
	play_all_animations("default")

func _physics_process(delta):
	# 8-way directional input
	velocity = Vector2.ZERO
	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		velocity.x += 1
	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		velocity.x -= 1
	if Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_S):
		velocity.y += 1
	if Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_W):
		velocity.y -= 1

	velocity = velocity.normalized() * move_speed
	velocity = move_and_slide(velocity)

	# --- ROTATION TO MOVEMENT DIRECTION ---
	if velocity.length() > 0:
		# Calculate target rotation angle in radians, applying your degree offset
		var target_angle = velocity.angle() + deg2rad(sprite_rotation_offset_degrees)
		
		# Smoothly interpolate current sprite stack rotation toward the target angle
		sprite_stack.rotation = lerp_angle(sprite_stack.rotation, target_angle, rotation_speed * delta)

# Synchronize playback across all layers simultaneously
func play_all_animations(anim_name: String):
	highlights_sprite.play(anim_name)
	indicators_sprite.play("critical")

# Dynamically sync frame changes manually if not using auto-play
func set_animation_frame(frame_index: int):
	highlights_sprite.frame = frame_index
	indicators_sprite.frame = frame_index
