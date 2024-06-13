extends Control

@export var character :Node
@export var active_color: Color = Color(1, 1, 1)  # White for active CP
@export var inactive_color: Color = Color(0.5, 0.5, 0.5)  # Grey for inactive CP

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	update_status()

func update_status():
	$BEPBar.value=float(character.cp_current)/character.cp_max*100
	$HPBar.value = float(character.health)/character.health_max*100
	$CharacterLabel.text=character.name
	
	for i in range(6):
		var cp_dot = $CPContainer.get_child(i) as TextureRect
		if i < character.current_cp:
			cp_dot.modulate=active_color
			#might change to animation
		else:
			cp_dot.modulate=inactive_color
			#might change to animation
			
