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
			await attack()
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
		var original_place= self.position
		await basic_attack_anim_in()
		var damage = strength #simplified formula
		target.take_damage(damage, self)
		print(self.name + " attacks" + target.name + "for" + str(damage) + "damage")
		await basic_attack_anim_out(original_place)

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
	var tween = get_tree().create_tween()
	tween.tween_property(self,"modulate", Color(1,1,1,0),1).set_ease(Tween.EASE_OUT)
	print (name +" has been defeated###################")
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
		return
	else:
		if counter_conditions.has(CounterCondition.HP_BELOW_25) and health <= (health_max * 0.25):
			await trigger_counter(CounterCondition.HP_BELOW_25,attacker)
			return
		elif counter_conditions.has(CounterCondition.ON_ATTACK):
			await trigger_counter(CounterCondition.ON_ATTACK,attacker)
			return
	emit_signal("turn_ended")
	
func trigger_counter(condition: CounterCondition, attacker: Node):
	is_countering= true
	var actions = counter_conditions[condition]
	for action in actions:
		match action:
			CounterActionType.LUNATTACK:
				await lunattack(attacker)
			CounterActionType.RETALIATE:
				await retaliate(attacker)
	is_countering = false

func lunattack(attacker: Node):
	if attacker:
		await get_tree().create_timer(2).timeout
		var damage = strength * 1.75  # Simplified damage calculation for Lunattack
		attacker.take_damage(damage, self)
		print(name + " uses Lunattack on " + attacker.name + " for " + str(damage) + " damage.")

func retaliate(attacker: Node):
	if attacker:
		var original_place = self.position
		await get_tree().create_timer(2).timeout	
		await basic_counter_anim_in(attacker)
		var damage = strength  # Simplified damage calculation for retaliation
		attacker.take_damage(damage, self)
		print(name + " retaliates against " + attacker.name + " for " + str(damage) + " damage.")
		await basic_counter_anim_out(original_place)
## animations	
func basic_attack_anim_in():
	var tween = get_tree().create_tween()
	tween.tween_property(self,"position", target.position - Vector2(50,0),1).set_ease(Tween.EASE_OUT)
	await tween.finished

func basic_attack_anim_out(original_place: Vector2):
	var tween = get_tree().create_tween()
	tween.tween_property(self,"position", original_place,1).set_ease(Tween.EASE_OUT)
	await tween.finished

## counter
func basic_counter_anim_in(attacker:Node):
	var tween = get_tree().create_tween()
	tween.tween_property(self,"position", attacker.position - Vector2(50,0),1).set_ease(Tween.EASE_OUT)
	await tween.finished

func basic_counter_anim_out(original_place: Vector2):
	var tween = get_tree().create_tween()
	tween.tween_property(self,"position", original_place,1).set_ease(Tween.EASE_OUT)
	await tween.finished
	
	
