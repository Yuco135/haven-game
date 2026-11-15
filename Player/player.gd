class_name Player extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D
@onready var deal_damage_zone = $DealDamageZone

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
var weapon_equip: bool

var health = 100
var health_max = 100
var health_min = 0

var can_take_damage: bool
var dead: bool


func _ready():
	GameManager.set_player(self)
	current_attack = false
	dead = false
	can_take_damage = true
	Global.playerBody = self
	Global.playerAlive = true


func _physics_process(delta: float) -> void:
	weapon_equip = Global.playerWeaponEquip
	Global.playerDamageZone = deal_damage_zone
	Global.playerHitbox = $player_hitbox
	# Add the gravity.
	
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		jump_count = 0
		
	# Handle jump.
	if !dead:
		if Input.is_action_just_pressed("jump") and jump_count < 2:
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
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			
			
		if !current_attack:
			if Input.is_action_just_pressed("single_attack") or Input.is_action_just_pressed("double_attack"):
				current_attack = true
				if Input.is_action_just_pressed("single_attack") and is_on_floor():
					attack_type = "single"
				elif Input.is_action_just_pressed("double_attack") and is_on_floor():
					attack_type = "double"
				else:
					attack_type = "air"
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
	animated_sprite.play("death")
	await get_tree().create_timer(0.5).timeout
	Global.playerAlive = false
	self.queue_free()
	
func take_damage_cooldown(wait_time):
	can_take_damage = false
	await get_tree().create_timer(0.5).timeout
	self.queue_free()

func handle_movement_animation(direction):
	var weapon_equip = Global.playerWeaponEquip
	if weapon_equip:
		if is_on_floor() and not current_attack:
			if not velocity:
				animated_sprite.play("idle")
			if velocity:
				animated_sprite.play("run")
				toggle_flip_sprite(direction)
		elif not is_on_floor() and not current_attack:
			animated_sprite.play("weapon_falling")

func toggle_flip_sprite(direction):
	if direction == 1:
		animated_sprite.flip_h = false
		deal_damage_zone.scale.x = 1
	if direction == -1:
		animated_sprite.flip_h = true
		deal_damage_zone.scale.x = -1
		
func handle_attack_animation(attack_type):
	if weapon_equip:
		if current_attack:
			var animation = str(attack_type, "_attack")
			animated_sprite.play(animation)
			print(animation)

func toggle_damage_collisions(attack_type):
	var damage_zone_collision = deal_damage_zone.get_node("CollisionShape2D")
	var wait_time: float
	if attack_type == "air":
		wait_time = 1.0
	elif attack_type == "single":
		wait_time = 0.4
	elif attack_type == "double":
		wait_time = 0.7
	damage_zone_collision.disabled = false
	await get_tree().create_timer(wait_time).timeout
	damage_zone_collision.disabled = true
	
func _on_animated_sprite_2d_animation_finished():
	current_attack = false
	
func set_damage(attack_type):
	var current_damage_to_deal: int
	if attack_type == "single":
		current_damage_to_deal = 8
	elif attack_type == "double":
		current_damage_to_deal = 16
	elif attack_type == "air":
		current_damage_to_deal = 20
	Global.playerDamageAmount = current_damage_to_deal

func _on_dash_timer_timeout() -> void:
	dashing = false

func _on_dash_again_timer_timeout() -> void:
	can_dash = true
