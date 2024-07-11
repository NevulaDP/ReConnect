extends Control

@export var character :Node
var active_color: Color = Color(1, 1, 1)  # White for active CP
var inactive_color: Color = Color(0, 0.129, 0.169) # Grey for inactive CP

var is_active = false
var active_scale = Vector2(1.05, 1.05)  #  active bar
var inactive_scale = Vector2(1, 1)    # non active bar

var time_multiplier:float = 5
var time:float = 0.0
var sine_offset_mult: float =0.5
var current_bar
signal active_status_bar_changed(active_bar)

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().root.get_child(0).connect("active_status_bar_changed", Callable(self, "_on_active_status_bar_changed"))

func _on_active_status_bar_changed(active_bar):
	if active_bar == self:
		_scale_up()
	else:
		_scale_down()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	update_status()
	if current_bar == character:
		time += delta
		var val: float = sin((time * time_multiplier))
		self.position.y += val * sine_offset_mult / 10
		

func set_character(char: Node):
	character = char

func update_status():
	if character == null:
		return
	print(character.be_atk)
	print(character.be_atk_max)
	$BEPBar.value = float(character.be_atk) / character.be_atk_max * 100
	$HPBar.value = float(character.health)/character.health_max * 100
	$CharacterLabel.text=character.c_name
	$HPLValue.text = str(character.health)
	$BEPLabelValue.text = str(character.be_atk)
	
	
	for i in range(6):
		var cp_dot = $CharPointBar.get_child(i) as TextureRect
		if i < character.charge:
			cp_dot.modulate = active_color
			#might change to animation
		else:
			cp_dot.modulate = inactive_color
			#might change to animation
			
func my_turn(current_turn:Node):
	if current_turn == character:
		sine_offset_mult=1
		current_bar = current_turn
	else:
		current_bar = null
		var tween = create_tween().set_ease(Tween.EASE_OUT)
		tween.tween_property(self,"position:y",0,0.5)
		
func _scale_up():
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween= tween.tween_property(self,"scale", active_scale,0.5)

func _scale_down():
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "scale", inactive_scale, 0.5)


