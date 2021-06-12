extends Node2D


# Declare member variables here. Examples:
# var a = 2
puppet var puppet_motion = Vector2()
puppet var puppet_rotation = 0
var motion = Vector2()
var prev_bombing = false
var bomb_index = 0

var cooldown = 0
var charge_strength = 0
const charge_cap = 50
var boost_velocity = Vector2()

# Use sync because it will be called everywhere
sync func setup_bomb(bomb_name, pos, by_who, path):
	var bomb = preload("res://bomb.tscn").instance()
	bomb.set_name(bomb_name) # Ensure unique name for the bomb
	bomb.position = get_parent().get_parent().position
	bomb.from_player = by_who
	bomb.path = path
	# No need to set network master to bomb, will be owned by server by default
	get_node("../../../..").add_child(bomb)

#Used to bosot based on the boost times etc.
func boost():
	#creates vector from current global origin to mosue global position .normalized() and then multiply by charge strength
	var movement = Vector2(cos(rotation), sin(rotation))
	boost_velocity += movement*charge_strength
	cooldown = 200
	charge_strength = 0
	

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Change to something that is hidden
func set_user_name(new_name):
	get_node("Label").set_text(new_name)

func _physics_process(_delta):
	var motionNew = Vector2()
	if is_network_master():
		var dist = 3
		if (Input.is_action_pressed("boost") && cooldown <= 0):
			dist = dist/2
		else:
			dist = 3
		if Input.is_action_pressed("move_left"):
			motionNew += Vector2(-1, 0)
		if Input.is_action_pressed("move_right"):
			motionNew += Vector2(1, 0)
		if Input.is_action_pressed("move_up"):
			motionNew += Vector2(0, -1)
		if Input.is_action_pressed("move_down"):
			motionNew += Vector2(0, 1)
		
			
		look_at(get_global_mouse_position())
		

		var boosting = Input.is_action_pressed("boost")

		if boost_velocity.length() > 0.5:
			boost_velocity *= 0.8
		elif boost_velocity.length() > 0:
			boost_velocity = Vector2()

		if boosting and cooldown <= 0:
			if charge_strength <= charge_cap:
				charge_strength += .5
				#TODO Show it is charging
			#else:
				#TODO Show that it has maxed strength
		elif !boosting and cooldown <= 0 and charge_strength > 0:
			#TODO SHOW RELEASED
			boost()
		
		if cooldown > 0:
			cooldown -= 1
		motionNew = motionNew.normalized()*dist
		motionNew += boost_velocity
		motion = motionNew

		rset("puppet_motion", motion)
		rset("puppet_rotation", rotation)

	else:
		motion = puppet_motion
		rotation = puppet_rotation

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Area2D_area_shape_entered(area_id, area, area_shape, local_shape):
	pass # Replace with function body.
