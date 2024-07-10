extends Node

class_name Character
enum ActionType {ATTACK,DEFEND,ABILITY}

@export var c_name:String = ""
# Base Stats
@export var agility: int = 10
@export var health_max: int = 100
@export var health: int = 100
@export var be_atk_max: int = 100
@export var be_atk: int = 100
@export var be_def: int = 20
@export var charge_max: int = 6
@export var charge: int = 6
@export var strength: int = 10
@export var vitality: int = 10
@export var luck: int = 10
@export var abilities: Array = []
var xp:int = 0 
var level:int = 1
var max_xp = 60

var cp_current:int = 0
var used_ability: bool = false
var target = null # target of current action
var current_action = ActionType.ATTACK  # Default action
var is_dead:bool = false
#example for modifier dictionary, should be loaded from a resource or json
var mod = {"Arlan":[20,30,30,40,50],"Aislin":[18,28,28,38,48],"Connall":[23,33,33,43,53]}
var party_data_save_path = "user://party_data.json"

signal turn_ready
signal turn_ended
signal stats_changed
signal back_to_place
		
func save_character():
	var character_data = {}
	return character_data
	
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
			if charge >= 1 and be_atk >= 1:
				cp_current -=1
				be_atk -= 6
				used_ability=true
				use_ability()
	end_turn()

func attack():
	if target:
		var original_place = self.position
		await basic_attack_anim_in()
		var damage = strength
		print("ATTACK: char=%s, target=%s, damage=%" % [c_name, target, String(damage)])
		await basic_attack_anim_out(original_place)
		await target.take_damage(damage, self)		
		return
	else:
		print("ATTACK: char=%s, target=None, damage=None" % [c_name])

func defend():
	#implement defend logic
	print("DEFEND: char=%s" % c_name)

func use_ability():
	#implement ability logic
	print("ABILITY: char=%s" % c_name)

func is_defeated():
	return health <= 0
	
func end_turn():
	emit_signal("stats_changed")
	emit_signal("turn_ended")
	
func die():
	is_dead = true
	print("DEFEATED: char=%s" % c_name)
	emit_signal("stats_changed")
	
func set_data(data):
	for key in data.keys():
		self.set(key,data[key])
	
func take_damage(amount:int, attacker:Node):
	health -= amount
	emit_signal("stats_changed")
	if health <= 0:
		die()

func basic_attack_anim_in():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", target.position - Vector2(50, 0), 1).set_ease(Tween.EASE_OUT)
	await tween.finished

func basic_attack_anim_out(original_place: Vector2):
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", original_place, 1).set_ease(Tween.EASE_OUT)
	await tween.finished
	
