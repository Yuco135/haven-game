extends Node

@export var pause_on_rewind: bool = true


# Reference to the player node
var player: Player = null
# Reference to the level node
var level: Level = null

# Maximum number of frames to store for rewind history
const MAX_REWIND_FRAMES = 300
# Array storing recorded player states (position, velocity, animation, etc.)
var player_frames: Array[Dictionary]



var bounce = false
var can_bounce = true


func set_player(_player: Player) -> void:
	player = _player
	
func set_level(_level: Level) -> void:
	level = _level

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("bounce") and can_bounce:
		$"bounce timer".start()
		can_bounce=false
		player.JUMP_VELOCITY = -750.0

func simple_rewind() -> void:
	if player:
		if Input.is_action_pressed("Rewind"):
			if player_frames.size() > 0:
				# Disable player physics while rewinding
				player.process_mode = Node.PROCESS_MODE_DISABLED
				player.camera.process_mode = Node.PROCESS_MODE_ALWAYS
				if pause_on_rewind:
					get_tree().paused = true
				# Pop last frame and restore player state
				var frame: Dictionary = player_frames.pop_back()
				player.global_position = frame["position"]
				player.velocity = frame["velocity"]
				player.animated_sprite.animation = frame["animation"]
				player.animated_sprite.frame = frame["animation_frame"]
				player.animated_sprite.flip_h = frame["flip"]
		else:
			# Record current frame state
			var frame: Dictionary = {
				"position": player.global_position,
				"velocity": player.velocity,
				"animation": player.animated_sprite.animation,
				"animation_frame": player.animated_sprite.frame,
				"flip": player.animated_sprite.flip_h
			}
			player_frames.append(frame)
			# Remove oldest frames when buffer is full
			if player_frames.size() > MAX_REWIND_FRAMES:
				player_frames.pop_front()
			# Resume normal gameplay
			if pause_on_rewind:
				get_tree().paused = false
			player.process_mode = Node.PROCESS_MODE_INHERIT
	pass


func _on_bounce_timer_timeout() -> void:
	can_bounce = false
	player.JUMP_VELOCITY = -500.0
	$"bounce again".start()
	

func _on_bounce_again_timeout() -> void:
	can_bounce = true
	if Input.is_action_just_pressed("Rewind"):
		$"Bounce timer".start()
		can_bounce=false
		player.JUMP_VELOCITY = -750.0
		simple_rewind()
