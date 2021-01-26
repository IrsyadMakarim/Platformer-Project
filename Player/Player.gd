extends KinematicBody2D

const MAX_SPEED = 400
const ACCELERATION = 30
const JUMP_HEIGHT = 600
const UP = Vector2(0, -1)
const WALL_SLIDE_ACCELERATION = 10
const MAX_WALL_SLIDE_SPEED = 120
const CHAIN_PULL = 85

onready var anim_player = $AnimationPlayer
onready var sprite = $Sprite

var GRAVITY = 30
var jump_was_pressed = false
var can_jump = false
var motion = Vector2()
var isGravity = true
var dub_jumps = 0
var max_num_dub_jumps = 1
var facing_right = false
var ladder_on = false
var chain_velocity := Vector2(0,0)
var can_fly = false
var can_grapple = false


func _ready():
	pass # Replace with function body.

func _input(event: InputEvent) -> void:
#	if can_grapple == true:
		if event is InputEventMouseButton:
			if event.pressed:
				# We clicked the mouse -> shoot()
				$Chain.shoot(event.position - get_viewport().size * 0.5)
			else:
				# We released the mouse -> release()
				$Chain.release()
	

func _physics_process(delta):
	run()
	jump()
	hook()

func hook():
	if $Chain.hooked:
		chain_velocity = to_local($Chain.tip).normalized() * CHAIN_PULL
		if chain_velocity.y > 0:
			chain_velocity.y *= 0.55
		else:
			chain_velocity.y *= 1.2
	else:
		# Not hooked -> no chain velocity
		chain_velocity = Vector2(0,0)
	motion += chain_velocity

func run():
	if Input.is_action_pressed("move_right"):
		motion.x = min(motion.x + ACCELERATION, MAX_SPEED)
		if is_on_floor():
			play_anim("walk")
		sprite.flip_h = true
	elif Input.is_action_pressed("move_left"):
		motion.x = max(motion.x - ACCELERATION, -MAX_SPEED)
		if is_on_floor():
			play_anim("walk")
		sprite.flip_h = false
	else:
		if is_on_floor():
			play_anim("idle")
		motion.x = lerp(motion.x, 0, .2)

func jump():
	if Input.is_action_just_released("jump") && motion.y <-200:
		motion.y = -150

	if Input.is_action_just_pressed("jump"):
		jump_was_pressed = true
		remember_jump_time()
		if can_jump == true:
			$Jump.play()
			motion.y = -JUMP_HEIGHT
			if is_on_wall() && Input.is_action_pressed("move_right"):
				motion.x = -MAX_SPEED
			elif is_on_wall() && Input.is_action_pressed("move_left"):
				motion.x = MAX_SPEED
		elif dub_jumps > 0:
			$Jump.play()
			motion.y = -JUMP_HEIGHT
			dub_jumps = dub_jumps - 1
	if Global.fly_time > 0 :
		if ladder_on == false:
#			if can_fly == true:
				if Input.is_action_pressed("move_up"):
					if not $Fly.is_playing():
						$Fly.play()
					motion.y -= JUMP_HEIGHT - 560
					Global.fly_time -= 1.2
					Global.emit_signal("fly_time")
	if is_on_floor():
		can_jump = true
		dub_jumps = max_num_dub_jumps
		if motion.y >= 5:
			motion.y = 5
		if jump_was_pressed == true:
			motion.y = -JUMP_HEIGHT
	elif !is_on_floor():
		if Global.fly_time > 0:
			if dub_jumps > 0:
				play_anim("jump")
			elif !is_on_wall():
				play_anim("jump")
	
	if is_on_wall() && (Input.is_action_pressed("move_right") || Input.is_action_pressed("move_left")):
		can_jump = true
		dub_jumps = max_num_dub_jumps 
		if motion.y >= 0:
			motion.y = min(motion.y + WALL_SLIDE_ACCELERATION, MAX_WALL_SLIDE_SPEED)
		else:
			motion.y += GRAVITY
	else:
		motion.y += GRAVITY
		
	motion = move_and_slide(motion, UP)
	
	if !is_on_floor() && !is_on_wall():
		coyote_time()
		pass
	
	if ladder_on == true:
		GRAVITY = 0
		can_jump = true
		dub_jumps = max_num_dub_jumps 
		if Input.is_action_pressed("move_up"):
			motion.y = -MAX_SPEED + 100
		elif Input.is_action_pressed("move_down"):
			motion.y = MAX_SPEED - 100
		else:
			motion.y = 0
	else:
		GRAVITY = 30

func coyote_time():
	yield(get_tree().create_timer(.06), "timeout")
	can_jump = false
	pass

func remember_jump_time():
	yield(get_tree().create_timer(.06), "timeout")
	jump_was_pressed = false
	pass

func play_anim(anim_name):
	if anim_player.is_playing() and anim_player.current_animation == anim_name:
		return
	anim_player.play(anim_name)

func _on_Timer_timeout():
	if Global.fly_time < 100:
		Global.fly_time += 1.2
		Global.emit_signal("fly_time")
