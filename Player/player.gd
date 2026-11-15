class_name Player extends CharacterBody2D


const SPEED = 400.0
const DASH_SPEED = 1000.0
var dashing = false
var can_dash = true 

var bounce = false
var can_bounce = true
var bounce_time = 10

var JUMP_VELOCITY = -500.0
var jump_count = 0

var enemy_inattack_range = false
var enemy_attack_cooldown = true
var health = 100
var player_alive = true
var attack_ip = false

const wall_jump_pushback = 400
const wall_slide_gravity = 50

var print_stop = true


@onready var animated_sprite = $AnimatedSprite2D
 
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		jump_count = 0
		
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and jump_count < 2:
		jump_count += 1
		velocity.y = JUMP_VELOCITY
		animated_sprite.play("jump")
	if is_on_wall() and Input.is_action_just_pressed("Right"):
		velocity.y = JUMP_VELOCITY
		velocity.x = -wall_jump_pushback
	if is_on_wall() and Input.is_action_just_pressed("Left"):
		velocity.y = JUMP_VELOCITY
		velocity.x = wall_jump_pushback
		
	
	if Input.is_action_just_pressed("Dash") and can_dash:
		dashing = true 
		can_dash = false
		$dash_timer.start()
		$dash_again_timer.start()
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("Left", "Right")
	if direction:
		if dashing:
			velocity.x = direction * DASH_SPEED
		else: 
			velocity.x = direction * SPEED
			animated_sprite.play("run")
			animated_sprite.flip_h = direction < 0
	else:
		if attack_ip == false:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			animated_sprite.play("idle")
	
	
	
	if health <= 0:
		player_alive = false
		health = 0
		if print_stop:
			print("player has been killed")
		print_stop = false
	
	enemy_attack()
	attack()
	move_and_slide()
	
func _ready() -> void:
	GameManager.set_player(self)
	enemy_attack()

func game_over():
	get_tree().reload_current_scene()


func _on_dash_timer_timeout() -> void:
	dashing = false

func _on_dash_again_timer_timeout() -> void:
	can_dash = true

func player():
	pass

#Player Attack
func _on_player_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy"):
		enemy_inattack_range = true

func _on_player_hitbox_area_exited(area: Area2D) -> void:
	if area.is_in_group("enemy"):
		enemy_inattack_range = false
		
func enemy_attack():
	if enemy_inattack_range and enemy_attack_cooldown:
		health = health - 20
		enemy_attack_cooldown = false
		$"attack cooldown".start()
		print(health)

func _on_attack_cooldown_timeout() -> void:
	enemy_attack_cooldown = true
	
func attack():
	if Input.is_action_just_pressed("attack"):
		Damage.player_current_attack = true
		attack_ip = true
		velocity.x = 0
		animated_sprite.play("attack")
		$deal_attack_timer.start()
		


func _on_deal_attack_timer_timeout() -> void:
	$deal_attack_timer.stop()
	Damage.player_current_attack = false
	attack_ip = false
