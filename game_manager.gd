extends Node

var player: Player = null
var level: Level = null

var bounce = false
var can_bounce = true

const MAX_REWIND_FRAMES = 300
var player_frames: Array[Dictionary]


func set_player(_player: Player) -> void:
	player = _player
	
func set_level(_level: Level) -> void:
	level = _level

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("bounce") and can_bounce:
		$"Bounce timer".start()
		can_bounce=false
		player.JUMP_VELOCITY = -750.0
	
	simple_rewind()

func simple_rewind() -> void:
	if player:
		if Input.is_action_just_pressed("Rewind"):
			if player_frames.size() > 0:
				player.global_position = player_frames.pop_back()
		else:
			var frame: Dictionary = {
				"position": player.global_position,
				"velocity": player.velocity,
				"animation": player.animated_sprite.animation,
				"animation_frame": player.animated_sprite.frame,
				"flip": player.animated_sprite.flip_h
			}
			player_frames.append(player.global_position)
			if player_frames.size() > MAX_REWIND_FRAMES:
				player_frames.pop_front()
	pass

func _on_bounce_timer_timeout() -> void:
	can_bounce = false
	player.JUMP_VELOCITY = -500.0
	$"bounce again".start()
	

func _on_bounce_again_timeout() -> void:
	can_bounce = true
	if Input.is_action_just_pressed("bounce") and can_bounce:
		$"Bounce timer".start()
		can_bounce=false
		player.JUMP_VELOCITY = -750.0
