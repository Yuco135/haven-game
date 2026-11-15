class_name Player extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D

const SPEED = 400.0
const DASH_SPEED = 1000.0
var dashing = false
var can_dash = true 

var bounce = false
var can_bounce = true
var bounce_time = 10

var JUMP_VELOCITY = -500.0
var jump_count = 0


const wall_jump_pushback = 400
const wall_slide_gravity = 50

var print_stop = true

var attack_type: String
var current_attack: bool 


func _ready() -> void:
	GameManager.set_player(self)
	current_attack = false
	dead = false
	can_take_damage = true
	Global.playerBody = self


func _physics_process(delta: float) -> void:
	weapon_equip = Global.playerWeaponEquip
	Global.playerDamageZone = deal_damage_zone
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		jump_count = 0
		
	# Handle jump.
	if Input.is_action_just_pressed("Jump") and jump_count < 2:
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
		velocity.x = move_toward(velocity.x, 0, SPEED)
		animated_sprite.play("idle")
		
		
	if weapon_equip and !current_attack:
		if Input.is_action_just_pressed("attack"):
			current_attack = true
		set_damage(attack_type)
		handle_attack_animation(attack_type)
	handle_movement_animation(direction)
	check_hitbox()
	move_and_slide()
	
func check_hitbox():
	var hitbox_areas = $player_hitbox.get_overlapping_areas()
	var damage: int
	if hitbox_areas:
		var hitbox = hitbox_areas.front()
		if hitbox.get_parent() is Enemy:
			damage = Global.enemyDamageAmount
			
	if can_take_damage:
		take_damage(damage)
		
func take_damage(damage):
	if damage != 0:
		if health > 0:
			health -= damage
			print("player health: ", health)
			if health <= 0:
				health = 0
				dead = true
				handle_death_animation()
			take_damage_cooldown(1.0)
			
func handle_death_animation():
	$CollisionShape2D.position.y = 5
	animated_sprite

func handle_movement_animation(dir):
	var weapon_equip = Global.playerWeaponEquip
	if !weapon_equip:
		if is_on_floor():
			if !velocity:
				animated_sprite.play("idle")
			if velocity:
				animated_sprite.play("run")
				toggle_flip_sprite(dir)
		elif !is_on_floor():
			animated_sprite.play()

func toggle_flip_sprite(dir):
	if dir == 1:
		animated_sprite.flip_h = false
		deal_damage_zone.scale.x = 1
	if dir == -1:
		animated_sprite.flip_h = true
		deal_damage_zone.scale.x = -1
		
func handle_attack_animation(attack_type):
	if weapon
