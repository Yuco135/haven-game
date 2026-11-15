extends Node

var player: Player = null
var level: Level = null

var bounce = false
var can_bounce = true

const MAC_REWIND_FRAMES = 300
var player_positions: Array[Vector2]

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
			if player_positions.size() > 0:
				player.global_position = player_positions.pop_back()
		else:
			player_positions.append(player.global_position)
			if player_positions.size() > MAC_REWIND_FRAMES:
				player_positions.pop_front()
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
