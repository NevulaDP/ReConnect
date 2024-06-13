extends Node

@export var party_member_scene : PackedScene
@export var enemy_scene : PackedScene
@export var status_bar_scene: PackedScene
@export var action_menu_scene: PackedScene

# Load the CustomSorter script
#const CustomSorter = preload("res://Scripts/Combat/CustomSorter.gd")

var party= []
var enemies = []
var all_combatants = []
var active_battle= false
var current_turn_index =0
var current_turn = null
var action_menu =null
var status_bars =[]


##Test party##
var party_data =[
	{"name": "Arlan", "agility": 15, "health": 100, "bep_max": 100},
	{"name": "Aislin", "agility": 10, "health": 80, "bep_max": 100},
	#{"name": "Connall", "agility": 12, "health": 120, "bep_max": 100}
]
var enemy_data = [
	{"name": "Soldier", "agility": 8, "health": 50, "bep_max": 100},
	{"name": "Scientist", "agility": 7, "health": 70, "bep_max": 100}		
]

# called puon entering the scene tree for the first time

func _ready():
	init_party()
	init_enemies()
	init_ui()
	start_battle()
	
#Initilaize Party
func init_party():
	for data in party_data:
		var member = party_member_scene.instantiate()
		member.set_data(data)
		member.connect("turn_ended", Callable(self, "_on_turn_ended"))
		add_child(member)
		party.append(member)
		
 		# Assign character node to the corresponding status bar
		var status_bar = status_bar_scene.instantiate()
		status_bar.set_character(member)  # Use a method to set the character
		$StatusBarContainer.add_child(status_bar)
		status_bars.append(status_bar)
		
func init_enemies():
	for data in enemy_data:
		var enemy = enemy_scene.instantiate()
		enemy.set_data(data)
		enemy.connect("turn_ended", Callable(self, "_on_turn_ended"))
		add_child(enemy)
		enemies.append(enemy)

func init_ui():
	#for member in party:
		#var status_bar = status_bar_scene.instantiate()
		#add_child(status_bar)
		#status_bar.character = member
		#status_bars.append(status_bar)
	
	action_menu = action_menu_scene.instantiate()
	add_child(action_menu)
	action_menu.hide()
	action_menu.connect("action_select",Callable(self,"_on_action_selected"))
	
# Battle Starts
func start_battle():
	active_battle=true
	determine_turn()

#Battle Ends
func end_battle():
	active_battle= false

#Determine initial order
func determine_turn():
	all_combatants= party+enemies
	all_combatants.sort_custom(func(a, b): return a.agility > b.agility)
	current_turn_index=0
	start_turn(all_combatants[current_turn_index])
	
# Starts Turn

func start_turn(character):
	current_turn = character
	if character in party:
		show_action_menu(character)
	else:
		character.perform_action()

#Handles the end of turn
func _on_turn_ended():
	#Checks for the use of CP
	if current_turn in party and !current_turn.used_ability:
		current_turn.cp_current +=1
		if current_turn.cp_current > current_turn.cp_max:
			current_turn.cp_current = current_turn.cp_max
			
	# Store current combatant
	var current_combatant = current_turn
		
	# remove defeated combatants
	all_combatants = all_combatants.filter(func(c):
		return !c.is_defeated()	)
	
	#Recalculate turn order
	all_combatants.sort_custom(func(a, b): return a.agility > b.agility)
	
	#find the index of the current combatant in the new turn order
	current_turn_index=all_combatants.find(current_combatant)
	
	#Determine next combatant
	current_turn_index = (current_turn_index +1) % all_combatants.size()
	
	start_turn(all_combatants[current_turn_index])
	
func show_action_menu(character):
	action_menu.show
	
# Handles selected action

func _on_aciton_selected(action_type):
	current_turn.current_action = action_type
	current_turn.perform_action()
	action_menu.hide()
			
	
	
	
