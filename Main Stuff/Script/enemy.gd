extends Node2D

var speed = 50
var player_chase = false
var player = null

var health = 100
var player_inattack_zone = false

func _physics_process(delta: float) -> void:
	if player_chase:
		position += (player.position - position)/speed
	deal_with_damage()

func _on_detection_body_entered(body: Node2D) -> void:
	player = body
	player_chase = true


func _on_detection_body_exited(body: Node2D) -> void:
	player = null
	player_chase = false
	
func enemy():
	pass


func _on_enemy_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		player_inattack_zone = true


func _on_enemy_hitbox_area_exited(area: Area2D) -> void:
	if area.is_in_group("player"):
		player_inattack_zone = false

func deal_with_damage():
	if player_inattack_zone and Damage.player_current_attack:
		health = health -20
		print("enemy health", health)
		if health <= 0:
			self.queue_free()
