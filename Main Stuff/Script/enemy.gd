extends Node2D

var speed = 50
var player_chase = false
var player = null

var health = 200
var player_inattack_zone = false
var can_take_damage = true

var dir: Vector2
const gravity = 900
var knockback_force =200
var is_roaming = true

func _physics_process(delta: float) -> void:
	deal_with_damage()
	if player_chase:
		position += (player.position - position)/speed

func _on_detection_body_entered(body: Node2D) -> void:
	player = body
	player_chase = true


func _on_detection_body_exited(body: Node2D) -> void:
	player = null
	player_chase = false
	
func enemy():
	pass




func _on_enemy_hitbox_body_entered(body: Node2D) -> void:
	if body.name == "player":
		player_inattack_zone = true


func _on_enemy_hitbox_body_exited(body: Node2D) -> void:
	if body.name == "player":
		player_inattack_zone = false

func deal_with_damage():
	if player_inattack_zone and Damage.player_current_attack:
		if can_take_damage == true:
			health = health - 10
			$"take damage cooldown".start()
			can_take_damage = false
			print("enemy health", health)
			if health <= 0:
				self.queue_free()


func _on_take_damage_cooldown_timeout() -> void:
	can_take_damage = true


func _on_direction_timer_timeout() -> void:
	pass # Replace with function body.
