extends KinematicBody2D

const MOTION_SPEED = 90.0

puppet var puppet_pos = Vector2()
puppet var puppet_motion = Vector2()

export var stunned = false

var current_anim = ""
var prev_bombing = false
var bomb_index = 0


func _physics_process(_delta):
	var motion = Vector2()

	# Your player
	#if is_network_master():
	for usr in get_node("Users").get_children():
		motion += usr.motion


	if stunned:
		motion = Vector2()

	if is_network_master():
		rset("puppet_motion", motion)
		rset("puppet_pos", position)
	# Someone else's player
	else:
		position = puppet_pos
		motion = puppet_motion

	var new_anim = "standing"
	if motion.y < 0:
		new_anim = "walk_up"
	elif motion.y > 0:
		new_anim = "walk_down"
	elif motion.x < 0:
		new_anim = "walk_left"
	elif motion.x > 0:
		new_anim = "walk_right"

	if stunned:
		new_anim = "stunned"

	if new_anim != current_anim:
		current_anim = new_anim
		get_node("anim").play(current_anim)

	# FIXME: Use move_and_slide
	move_and_slide(motion * MOTION_SPEED)
	if not is_network_master():
		puppet_pos = position # To avoid jitter


puppet func combine(_by_who, path):
	var killer = get_node(path)
	if (self != get_node(path)):
		for usr in get_node("Users").get_children():
			self.get_node("Users").remove_child(usr)
			killer.get_node("Users").add_child(usr)
			usr.set_owner(killer.get_node("Users"))
		queue_free()
	


master func exploded(_by_who, path):
	rpc("combine", _by_who, path) # Stun puppets
	combine(_by_who, path) # Stun master - could use sync to do both at once


func set_player_name(new_name):
	get_node("label").set_text(new_name)


func _ready():
	stunned = false
	puppet_pos = position
