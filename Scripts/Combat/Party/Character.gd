extends Node

enum ActionType {ATTACK,DEFEND,ABILITY}

@export var c_name = ""
@export var agility:int =10
@export var health_max = 100
@export var health:int = 100
@export var bep_max:int  = 100
var cp_max:int = 6 # Constant
var cp_current:int =0
var bep_current:int = 100
var used_ability: bool = false

var current_action = ActionType.ATTACK  # Default action


signal turn_ready
signal turn_ended

func start_turn():
	used_ability = false

func perform_action():
	match ActionType:
		ActionType.ATTACK:
			attack(null)
		ActionType.DEFEND:
			defend()
		ActionType.ABILITY:
			if cp_current >=1 and bep_current >=1:
				cp_current -=1
				bep_current -=10
				used_ability=true
				use_ability(null)
	end_turn()

func attack(target):
	pass

func defend():
	pass

func use_ability(target):
	pass

func is_defeated():
	return health<=0
	
func end_turn():
	emit_signal("turn_enedd")

func set_data(data):
	name = data["name"]
	agility = data["agility"]
	bep_max = data["bep_max"]
	bep_current = bep_max
	health = data["health"]
	cp_current=2
	used_ability=false

	
	
