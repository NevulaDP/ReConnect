extends Node
enum ActionType {ATTACK,DEFEND,ABILITY}

@export var c_name:String = ""
#Base Stats
@export var agility:int =10
@export var health_max = 100
@export var health:int = 100
@export var bep_max:int  = 100
@export var bep_current:int = 20
@export var cp_max:int = 6 # Constant
@export var strength:int=10
@export var vitality:int = 10
@export var bioenergy:int = 10
@export var spirit:int = 10
@export var luck:int = 10

var cp_current:int =0
var used_ability: bool = false
var target = null # target of current action
var current_action = ActionType.ATTACK  # Default action
var is_dead:bool = false


signal turn_ready
signal turn_ended
signal stats_changed

func start_turn():
	used_ability = false

func perform_action():
	print(current_action)
	match current_action:
		ActionType.ATTACK:
			attack(null)
		ActionType.DEFEND:
			defend()
		ActionType.ABILITY:
			if cp_current >=1 and bep_current >=1:
				cp_current -=1
				bep_current -=6
				used_ability=true
				use_ability()
	end_turn()

func attack(target):
	if target:
		var damage = strength #simplified formula
		target.take_damage(damage)
		print(c_name + "attacks" + target.c_name + "for" + str(damage) + "damage")
	else:
		print (name  + " attacked the air")

func defend():
	#implement defend logic
	print( name + "defends")

func use_ability():
	#implement ability logic
	print (name + "used an ability")

func is_defeated():
	return health<=0
	
func end_turn():
	emit_signal("stats_changed")
	emit_signal("turn_ended")
	
func die():
	is_dead = true
	print (name +" has been defeated")
	emit_signal("stats_changed")
	
func set_data(data):
	for key in data.keys():
		self.set(key,data[key])
	#name = data["name"]
	#agility = data["agility"]
	#bep_max = data["bep_max"]
	#bep_current = bep_max
	#health = data["health"]
	#health_max = data["max_health"]
	#cp_current=2
	#used_ability=false
	
func take_damage(amount:int):
	health-=amount
	emit_signal("stats_changed")
	if health <=0:
		die()

	
	
