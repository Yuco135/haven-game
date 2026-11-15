class_name Enemy extends CharacterBody2D

const speed = 30
var is_enemy_chase: bool

var health = 200
var health_max = 200
var health_min = 0  

var dead = false
var taking_damage = false
var damage_to_deal = 20
var is_dealing_damage:bool = false

var dir: Vector2
const gravity = 900
var knockback_force = 200
var is_roaming: bool = true

var player: CharacterBody2D
var player_in_area = false

func _process(delta):
	if !is_on_floor():
		velocity.y += gravity * delta
		velocity.x = 0
		
	if Global.playerAlive:
		is_enemy_chase = true
	elif !Global.playerAlive:
		is_enemy_chase = false
		
	
	Global.enemyDamageAmount = damage_to_deal
	Global.enemyDamageZone = $BossDamageArea
	
	player = Global.playerBody
	
	move(delta)
	handle_animation()
	move_and_slide()
	
func move(delta):
	if !dead:
		if !is_enemy_chase:
			velocity += dir * speed * delta
		elif is_enemy_chase and !taking_damage:
			var dir_to_player = position.direction_to(player.position) * speed
			velocity.x = dir_to_player.x
			dir.x = abs(velocity.x) / velocity.x
			is_roaming = true
		elif taking_damage:
			var kniockback_dir = position.direction_to(player.position) * knockback_force
			velocity.x = kniockback_dir.x
	elif dead:
		velocity.x = 0

func handle_animation():
	var animated_sprite = $AnimatedSprite2D
	if !dead and !taking_damage and !is_dealing_damage:
		animated_sprite.play("walking")
		if dir.x == 1:
			animated_sprite.flip_h = true
		elif dir.x == -1:
			animated_sprite.flip_h = false
		elif !dead and taking_damage and !is_dealing_damage:
			animated_sprite.play("taking_damage")
			await get_tree().create_timer(1.0).timeout
			taking_damage = false
		elif dead and is_roaming:
			is_roaming = false
			animated_sprite.play("death")
			await get_tree().create_timer(1.0).timeout
			handle_death()
		
			
func handle_death():
	self.queue_free()

func _on_direction_timer_timeout() -> void:
	$DirectionTimer.wait_time = choose([1.5,2.0,2.5])
	if !is_enemy_chase:
		dir = choose([Vector2.RIGHT, Vector2.LEFT])
		velocity.x = 0
	
func choose(array):
	array.shuffle()
	return array.front()
	


func _on_boss_hitbox_area_entered(area) -> void:
	var damage = Global.playerDamageAmount
	if area == Global.playerDamageZone:
		take_damage(damage)
		
func take_damage(damage):
	health -= damage
	taking_damage = true
	if health <= health_min:
		health = health_min
		dead = true
		$death.start()
	print(str(self), "current health is ", health)
	
func _on_boss_damage_area_area_entered(area):
	if area == Global.playerHitbox:
		is_dealing_damage = true
		await get_tree().create_timer(1.0).timeout
		is_dealing_damage = false


func _on_death_timeout() -> void:
	get_tree().change_scene_to_file("res://Main Menu/Scenes/main_menu.tscn")
