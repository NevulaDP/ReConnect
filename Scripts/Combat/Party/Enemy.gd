extends Node
enum ActionType {ATTACK,DEFEND,ABILITY}
enum CounterCondition { HP_BELOW_25, ON_ATTACK }
enum CounterActionType { LUNATTACK, RETALIATE }

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
@export var counter_conditions: Dictionary = {}  # Dictionary to store counter conditions and their actions

var cp_current:int =0
var used_ability: bool = false
var target = null # target of current action
var current_action = ActionType.ATTACK  # Default action
var is_dead:bool = false
var is_countering:bool =false


signal turn_ready
signal turn_ended

func start_turn():
	used_ability = false

func perform_action():
	print(current_action)
	match current_action:
		ActionType.ATTACK:
			attack()
		ActionType.DEFEND:
			defend()
		ActionType.ABILITY:
			if cp_current >=1 and bep_current >=1:
				cp_current -=1
				bep_current -=6
				used_ability=true
				use_ability()
	end_turn()

func attack():
	if target:
		var damage = strength #simplified formula
		target.take_damage(damage)
		print(c_name + "attacks" + target.name + "for" + str(damage) + "damage")
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
	
func take_damage(amount:int, attacker: Node):
	health-=amount
	if health <=0:
		die()
	else:
		if counter_conditions.has(CounterCondition.HP_BELOW_25) and health <= (health_max * 0.25):
			trigger_counter(CounterCondition.HP_BELOW_25,attacker)
		elif counter_conditions.has(CounterCondition.ON_ATTACK):
			trigger_counter(CounterCondition.ON_ATTACK,attacker)
	emit_signal("turn_ended")
	
func trigger_counter(condition: CounterCondition, attacker: Node):
	is_countering= true
	var actions = counter_conditions[condition]
	for action in actions:
		match action:
			CounterActionType.LUNATTACK:
				lunattack(attacker)
			CounterActionType.RETALIATE:
				retaliate(attacker)
	is_countering = false

func lunattack(attacker: Node):
	if attacker:
		var damage = strength * 1.75  # Simplified damage calculation for Lunattack
		attacker.take_damage(damage, self)
		print(name + " uses Lunattack on " + attacker.name + " for " + str(damage) + " damage.")

func retaliate(attacker: Node):
	if attacker:
		var damage = strength  # Simplified damage calculation for retaliation
		attacker.take_damage(damage, self)
		print(name + " retaliates against " + attacker.name + " for " + str(damage) + " damage.")

	
	
