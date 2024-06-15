extends Control

@export var character :Node
var active_color: Color = Color(1, 1, 1)  # White for active CP
var inactive_color: Color = Color(0, 0.129, 0.169) # Grey for inactive CP

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	update_status()

func set_character(char: Node):
	character = char


func update_status():
	if character == null:
		return

	$BEPBar.value=float(character.bep_current)/character.bep_max*100
	$HPBar.value = float(character.health)/character.health_max*100
	$CharacterLabel.text=character.name
	$HPLValue.text= str(character.health)
	$BEPLabelValue.text = str(character.bep_current)
	
	
	for i in range(6):
		var cp_dot = $CharPointBar.get_child(i) as TextureRect
		if i < character.cp_current:
			cp_dot.modulate=active_color
			#might change to animation
		else:
			cp_dot.modulate=inactive_color
			#might change to animation
			
