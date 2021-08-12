extends KinematicBody2D

const MAX_SPEED = 400
const ACCELERATION = 30
const JUMP_HEIGHT = 600
const UP = Vector2(0, -1)
const WALL_SLIDE_ACCELERATION = 10
const MAX_WALL_SLIDE_SPEED = 120
const CHAIN_PULL = 85
const DASH = 800
const DASH_SPEED = 1.5

onready var anim_player = get_node("AnimationPlayer")
onready var sprite = get_node("Sprite")
onready var animSprite = get_node("AnimatedSprite")
onready var ghostTime = get_node("GhostTimer")
onready var chain = get_node("Chain")
onready var jumpSnd = get_node("Jump")
onready var flySnd = get_node("Fly")
onready var dashTimer = get_node("DashCooldown")

var GRAVITY = 30
var jump_was_pressed = false
var can_jump = false
var motion = Vector2()
var isGravity = true
var dub_jumps = 0
var max_num_dub_jumps = 1
var facing_right = false
var chain_velocity := Vector2(0,0)
var can_fly = false
var can_grapple = false
var direction : int
var dash_timer = 0.1
var dash_time = 0.3
var dash_direction : int
var canWalk = true
var canDash = true
var inDash = false
var dashCooldown = false
var timeToDash = 3.0

func _input(event: InputEvent) -> void:
#	if can_grapple == true:
		if event is InputEventMouseButton:
			if event.pressed:
				# We clicked the mouse -> shoot()
				chain.shoot(event.position - get_viewport().size * 0.5)
			else:
				# We released the mouse -> release()
				chain.release()

func _physics_process(delta):
	
	dash_timer += delta
	run()
	jump()
	hook()
	dash()

func hook():
	if chain.hooked:
		chain_velocity = to_local(chain.tip).normalized() * CHAIN_PULL
		if chain_velocity.y > 0:
			chain_velocity.y *= 0.88
		else:
			chain_velocity.y *= 1.2
	else:
		# Not hooked -> no chain velocity
		chain_velocity = Vector2(0,0)
	motion += chain_velocity

func run():
	if not inDash:
		if Input.is_action_pressed("move_right"):
			if canWalk:
				direction = -1
				dash_direction = 1
				motion.x = min(motion.x + ACCELERATION, MAX_SPEED)
				if is_on_floor():
					play_anim("walk")
					animSprite.play("Run")
				sprite.flip_h = true
				animSprite.flip_h = true
		elif Input.is_action_pressed("move_left"):
			if canWalk:
				direction = 1
				dash_direction = -1
				motion.x = max(motion.x - ACCELERATION, -MAX_SPEED)
				if is_on_floor():
					play_anim("walk")
					animSprite.play("Run")
				sprite.flip_h = false
				animSprite.flip_h = false
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
			jumpSnd.play()
			motion.y = -JUMP_HEIGHT
			if is_on_wall() && Input.is_action_pressed("move_right"):
				motion.x = -MAX_SPEED
			elif is_on_wall() && Input.is_action_pressed("move_left"):
				motion.x = MAX_SPEED
		elif dub_jumps > 0:
			jumpSnd.play()
			motion.y = -JUMP_HEIGHT
			dub_jumps = dub_jumps - 1
#	if Global.fly_time > 0 :
#		if ladder_on == false:
##			if can_fly == true:
#				if Input.is_action_pressed("move_up"):
#					if not flySnd.is_playing():
#						flySnd.play()
#					motion.y -= JUMP_HEIGHT - 560
#					Global.fly_time -= 1.2
#					Global.emit_signal("fly_time")
	if is_on_floor() and not inDash:
		canDash = true
		can_jump = true
		dub_jumps = max_num_dub_jumps
		if motion.y >= 5:
			motion.y = 5
		if jump_was_pressed == true:
			motion.y = -JUMP_HEIGHT
	elif !is_on_floor():
		canDash = false
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
	
	if inDash == true:
		motion.y = 0
		
	motion = move_and_slide(motion, UP)
	
	if !is_on_floor() && !is_on_wall():
		coyote_time()
		pass
	
	if Global.ladder_on == true:
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

func dash():
	
	if dash_timer > dash_time:
		inDash = false
		ghostTime.stop()
	if dash_timer < 0.5:
		inDash = true
	
	if dashCooldown == false:
		if Input.is_action_just_pressed("dash"):
			motion.x = DASH * dash_direction * DASH_SPEED
			dash_timer = 0
			canDash = false
			inDash = true
			ghostTime.start()
			dashCooldown = true
			dashTimer.set_wait_time(Global.dashTime)
			dashTimer.start()
			Global.emit_signal("fly_time_reduce", Global.dashTime)

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

#func _on_Timer_timeout():
#	if Global.fly_time < 100:
#		Global.fly_time += 1.2
#		Global.emit_signal("fly_time")

func _on_GhostTimer_timeout():
	var this_ghost = preload("res://Scene/Ghost.tscn").instance()
	get_parent().add_child(this_ghost)
	this_ghost.position = position
	this_ghost.texture = animSprite.frames.get_frame(animSprite.animation, animSprite.frame)
	this_ghost.flip_h = animSprite.flip_h

func _on_DashCooldown_timeout():
	dashCooldown = false
	Global.emit_signal("fly_time_tambah", Global.dashTime)
