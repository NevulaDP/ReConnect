extends Control

var abilities =[]
signal ability_selected(ability)



func _ready():
	# Populate the menu if abilities are set before _ready is called
	if abilities.size()>0:
		populate_abilities_menu()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func set_abilities(abilities_list):
	abilities = abilities_list
	
func populate_abilities_menu():
	var abilities_list = $ScrollContainer/VBoxContainer
	abilities_list.clear() # if was already populated from previous call
	for ability in abilities:
		var button = Button.new()
		button.text = ability
		button.focus_mode=Control.FOCUS_ALL
		button.connect("pressed",Callable(self,"_on_ability_selected").bind(ability))
		abilities_list.add_child(button)
	
	#sets focus on first ability on the list
	if abilities_list.get_child_count()>0:
		abilities_list.get_child(0).grab_focus()
	
func _on_ability_selected(ability):
	emit_signal("ability_selected",ability)
	queue_free() # change to be reversable with the menu
	
func _input(event):
	if event.is_action_pressed("ui_down"):
		_navigate_menu("down")
	elif event.is_action_pressed("ui_up"):
		_navigate_menu("up")

func _navigate_menu(direction):
	var abilities_list = $ScrollContainer/VBoxContainer
	var current_focus = get_viewport().gui_get_focus_owner()
	if current_focus and current_focus.is_inside_tree() and current_focus.get_parent() == abilities_list:
		var current_index = abilities_list.get_child_index(current_focus)
		var next_index = current_index + (1 if direction== "down" else -1)
		if next_index >= 0 and next_index <abilities_list.get_child_count():
			abilities_list.get_child(next_index).grab_focus()
			_scroll_to_button(abilities_list.get_child(next_index))
			
func _scroll_to_button(button):
	var scroll = $ScrollContainer
	var button_pos = button.rect_global_position.y
	var scroll_pos = scroll.rect_global_position.y
	var scroll_height = scroll.rect_size.y
	var button_height = button.rect_size.y
	
	if button_pos <scroll_pos:
		scroll.scroll_vertical = button_pos - scroll_pos
	elif button_pos + button_height > scroll_pos +scroll_height:
		scroll.scroll_vertical = button_pos + button_height - scroll_pos - scroll_height
