extends Node

# Declare CounterCondition and CounterActionType enums here
enum CounterCondition { HP_BELOW_25, ON_ATTACK }
enum CounterActionType { LUNATTACK, RETALIATE }

@export var party_member_scene : PackedScene
@export var enemy_scene : PackedScene
@export var status_bar_scene: PackedScene
@export var action_menu_scene: PackedScene
@export var abilities_menu_scene : PackedScene
@export var glove_indicator_scene: PackedScene
@export var target_selector_resource: Resource

signal active_status_bar_changed(active_bar)

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
var target_selector = null
var statusbar_index
var last_action

### positions ###

##Test party##
var party_data = [
	{"name": "Arlan", "agility": 15, "health": 100, "bep_max": 40, "level": 10, "strength": 20,
	 "vitality": 15, "magic": 8, "spirit": 12, "luck": 5, "cp_current":5,"abilities": ["Fireball", "Heal"]},
	{"name": "Aislin", "agility": 10, "health": 100, "bep_max": 100, "level": 8, "strength": 10,
	 "vitality": 10, "magic": 20, "spirit": 15, "luck": 7,"cp_current":3,"abilities": ["Ice Spike", "Barrier"]},
	{"name": "Connall", "agility": 12, "health": 100, "bep_max": 20, "level": 12, "strength": 25,
	 "vitality": 20, "magic": 5, "spirit": 10, "luck": 3,"cp_current":1, "abilities": ["Slash", "Power Strike"]}
]

var enemy_data = [
	 {
		"name": "Goblin",
		"agility": 8,
		"health": 50,
		"bep_max": 5,
		"counter_conditions": {
			CounterCondition.ON_ATTACK: [CounterActionType.RETALIATE],
			CounterCondition.HP_BELOW_25: [CounterActionType.LUNATTACK]
		},
		"level": 5,
		"strength": 15,
		"vitality": 10,
		"magic": 5,
		"spirit": 8,
		"luck": 2
	},
	{
		"name": "Orc",
		"agility": 7,
		"health": 70,
		"bep_max": 6,
		"counter_conditions": {
			CounterCondition.ON_ATTACK: [CounterActionType.RETALIATE]
		},
		"level": 7,
		"strength": 18,
		"vitality": 12,
		"magic": 6,
		"spirit": 10,
		"luck": 4
	}
]

# called puon entering the scene tree for the first time

func _ready():
	init_party()
	init_enemies()
	position_characters()
	init_ui()
	init_target_selector()
	start_battle()
	

func position_characters():
	var screen_width = get_viewport().size.x
	var screen_height = get_viewport().size.y
	
	var party_start_x = screen_width*0.75
	var party_spacing_y= screen_height / (party.size() +1)
	var enemy_start_x = screen_width*0.25
	var enemy_spacing_y =screen_height / (enemies.size()+1)
	
	for i in range(party.size()):
		party[i].position = Vector2(party_start_x,party_spacing_y*(i+1))
	for i in range(enemies.size()):
		enemies[i].position = Vector2(enemy_start_x, enemy_spacing_y*(i+1))
#Initilaize Party
func init_party():
	for data in party_data:
		var member = party_member_scene.instantiate()
		member.set_data(data)
		member.connect("turn_ended", Callable(self, "_on_turn_ended"))
		member.connect("stats_changed", Callable(self, "_on_stats_changed"))
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
	
	#action_menu = action_menu_scene.instantiate()
	#add_child(action_menu)
	#action_menu.hide()
	#action_menu.connect("action_selected",Callable(self,"_on_action_selected"))
	pass

func init_target_selector():
	target_selector = target_selector_resource.new()
	target_selector.init(self, glove_indicator_scene)
	target_selector.connect("target_selected", Callable(self, "_on_target_selected"))
	target_selector.connect("back_to_menu",Callable(self,"_on_back_to_menu"))
	
		
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
	if character.is_dead:
		_on_turn_ended() #  skip defeated characters turn
		return
	current_turn = character
	print("Starting turn for: ", character.name)
	if character in party:
		show_action_menu(character)
	else:
		var living_party_members = party.filter(func(c): return not c.is_dead)
		if living_party_members.size() > 0:
			character.target = living_party_members[randi() % living_party_members.size()]  # Randomly select a living party member to attack
			character.perform_action()

#Handles the end of turn
func _on_turn_ended():
	#Checks for the use of CP
	if current_turn in party and !current_turn.used_ability:
		current_turn.cp_current +=1
		if current_turn.cp_current > current_turn.cp_max:
			current_turn.cp_current = current_turn.cp_max
		current_turn.emit_signal("stats_changed")	
	current_turn.used_ability = false
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
	statusbar_index = party.find(current_turn)
	#Statusbar highlight
	for statusbar in status_bars:
		status_bars[statusbar_index].my_turn(current_turn)
		status_bars[statusbar_index]._scale_up()
	#action menu
	action_menu = action_menu_scene.instantiate()
	add_child(action_menu)
	action_menu.init(current_turn)
	action_menu.connect("action_selected",Callable(self,"_on_action_selected"))
	action_menu.connect("abilities_selected", Callable(self, "_on_abilities_selected"))
	print("showing menu for: " + str(character.name))
	
# Handles selected action

func _on_action_selected(action_type):
	
	statusbar_index = party.find(current_turn)
	status_bars[statusbar_index]._scale_down()
	current_turn.current_action = action_type
	last_action=action_type
	var living_enemies = enemies.filter(func(c): return not c.is_dead)
	action_menu.hide_menu()
	if living_enemies.size() >0:
		target_selector.start_target_selection(living_enemies)
		#current_turn.target =living_enemies[randi() % living_enemies.size()] 
		#print(current_turn.target.name +"------------")
		#await current_turn.perform_action()
		#await current_turn.perform_action()

func _on_abilities_selected():
	action_menu.hide_menu()
	var abilities_menu = abilities_menu_scene.instantiate()
	add_child(abilities_menu)
	abilities_menu.init(current_turn)
	abilities_menu.set_abilities(current_turn.abilities)
	abilities_menu.populate_abilities_menu()
	abilities_menu.connect("ability_selected",Callable(self,"_on_ability_selected"))

func _on_ability_selected(ability):
	print("Ability selected: ", ability)
	current_turn.current_action = ability
	#callfor target selector
	_on_turn_ended()

# Handles target selected
func _on_target_selected(target):
	current_turn.target = target
	action_menu.queue_free()
	status_bars[statusbar_index].my_turn(null)
	await current_turn.perform_action()

	

func _on_stats_changed():
	# This function will be called when any character's stats change
	for status_bar in status_bars:
		status_bar.update_status()  # Ensure all status bars are updated
	
func _unhandled_input(event):
	if target_selector.is_selecting_target:
		target_selector.handle_input(event)

func _on_back_to_menu():
	action_menu.show_menu()
	#show_action_menu(all_combatants[current_turn_index])
	status_bars[statusbar_index]._scale_up()
	
