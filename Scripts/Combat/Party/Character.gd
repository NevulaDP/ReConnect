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
var party_data_save_path = "user://save_data/party_data.json"

signal turn_ready
signal turn_ended
signal stats_changed
signal back_to_place
		
func save_character():
	var character_data = {
		"c_name": c_name, 
		"agility": agility, 
		"health": health, 
		"be_atk_max": be_atk_max, 
		"level": level, 
		"xp": xp,
		"strength": strength,
	 	"vitality": vitality, 
		"luck": luck, 
		"charge": charge,
		"abilities": abilities
		}
	var party_data = load_party_data()
	if party_data:
		for i in range(party_data.size()):
			if party_data[i].get("c_name") == c_name:
				party_data[i] = character_data
				save_party_data(party_data)
				return
	
func load_party_data():
	if not FileAccess.file_exists(party_data_save_path):
		print("LOAD PARTY EXCEPTION: NO SUCH FILE")
		return
	var file_access := FileAccess.open(party_data_save_path, FileAccess.READ)
	var json_string := file_access.get_as_text()
	file_access.close()
	var json := JSON.new()
	print("Party Data: ")
	print(json_string)
	var error := json.parse(json_string)
	if error:
		print("LOAD PARTY EXCEPTION: ERROR PARSING PARTY DATA")
		return
	return json.data
	
func save_party_data(party_data):
	print(party_data)
	var json_string := JSON.stringify(party_data)
	var file_access := FileAccess.open(party_data_save_path, FileAccess.WRITE)
	if not file_access:
		print("SAVE PARTY EXCEPTION")
		return
	file_access.store_string(json_string)	
	file_access.close()
	
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
				charge -= 1
				be_atk -= 6
				used_ability=true
				use_ability()
	end_turn()

func attack():
	if target:
		var original_place = self.position
		await basic_attack_anim_in()
		print("ATTACK: char={0}, target={1}, damage={2}".format({"0": c_name, "1": target, "2": strength}))
		await basic_attack_anim_out(original_place)
		await target.take_damage(strength, self)
		if target.health <= 0:
			increase_xp(target.reward_xp)	
		return
	else:
		print("ATTACK: char={0}, target=None, damage=None".format({"0": c_name}))
		
func increase_xp(reward_xp:int):
	if level < 50:
		xp += reward_xp
		print("XP_GAIN: char={0}, xp_gain={1}, new_total_xp={2}".format({"0": c_name, "1": reward_xp, "2": xp}))
		save_character()

func defend():
	#implement defend logic
	print("DEFEND: char={0}".format({"0": c_name}))

func use_ability():
	#implement ability logic
	print("ABILITY: char={0}".format({"0": c_name}))

func is_defeated():
	return health <= 0
	
func end_turn():
	emit_signal("stats_changed")
	emit_signal("turn_ended")
	
func die():
	is_dead = true
	print("DEFEATED: char={0}".format({"0": c_name}))
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
	
