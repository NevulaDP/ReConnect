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
signal back_to_place

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
		print(self.name + " attacks" + target.name + "for" + str(damage) + "damage")
		await basic_attack_anim_out(original_place)
		await target.take_damage(damage, self)
		
		
		
		return
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
	
func take_damage(amount:int, attacker:Node):
	health-=amount
	emit_signal("stats_changed")
	if health <=0:
		die()

func basic_attack_anim_in():
	var tween = get_tree().create_tween()
	tween.tween_property(self,"position", target.position - Vector2(50,0),1).set_ease(Tween.EASE_OUT)
	await tween.finished

func basic_attack_anim_out(original_place: Vector2):
	var tween = get_tree().create_tween()
	tween.tween_property(self,"position", original_place,1).set_ease(Tween.EASE_OUT)
	await tween.finished
	
