extends Resource

var enemies = []
var current_target_index = 0
var is_selecting_target = false
var glove_indicator = null
var parent_node = null
var glove_indicator_scene = null

signal target_selected(target)
signal back_to_menu()

func init(parent_node, glove_indicator_scene):
	self.parent_node = parent_node
	self.glove_indicator_scene = glove_indicator_scene
	glove_indicator = glove_indicator_scene.instantiate()
	parent_node.add_child(glove_indicator)
	glove_indicator.hide()

func start_target_selection(enemies):
	self.enemies = enemies
	is_selecting_target = true
	current_target_index = 0
	update_glove_indicator()

func update_glove_indicator():
	if enemies.size() > 0:
		glove_indicator.position = enemies[current_target_index].position +Vector2(30,0)
		glove_indicator.show()
		glove_indicator.get_node("AnimationPlayer").play("loop")  # Play the looping animation

func handle_input(event):
	if is_selecting_target:
		if event.is_action_pressed("ui_up"):
			current_target_index = (current_target_index - 1) % enemies.size()
			update_glove_indicator()
		elif event.is_action_pressed("ui_down"):
			current_target_index = (current_target_index + 1 + enemies.size()) % enemies.size()
			update_glove_indicator()
		elif event.is_action_pressed("ui_accept"):
			is_selecting_target = false
			glove_indicator.hide()
			emit_signal("target_selected", enemies[current_target_index])
		elif event.is_action_pressed("ui_abort"):
			is_selecting_target = false
			glove_indicator.hide()
			emit_signal("back_to_menu")
