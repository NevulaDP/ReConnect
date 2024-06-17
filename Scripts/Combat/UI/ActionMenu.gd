extends Control

enum ActionType {ATTACK, DEFEND, ABILITY}

signal action_selected(action_type:int)

var last_focused_button_path: NodePath = NodePath("")

# Called when the node enters the scene tree for the first time.
func _ready():
	$MenuContainer/AttackButton.grab_focus()
	$MenuContainer/AttackButton.connect("pressed", Callable(self, "_on_AttackButton_pressed"))
	$MenuContainer/DefendButton.connect("pressed",Callable(self,"_on_DefendButton_pressed"))
	$MenuContainer/AbilityButton.connect("pressed",Callable(self,"_on_AbilityButton_pressed"))
	
	# Connect focus events
	$MenuContainer/AttackButton.connect("focus_entered", Callable(self, "_on_focus_entered"))
	$MenuContainer/DefendButton.connect("focus_entered", Callable(self, "_on_focus_entered"))
	$MenuContainer/AbilityButton.connect("focus_entered", Callable(self, "_on_focus_entered"))

func init(combatant):
	self.position = combatant.position -Vector2(200,20)	

func _on_AttackButton_pressed():
	emit_signal("action_selected", ActionType.ATTACK)

func _on_DefendButton_pressed():
	emit_signal("action_selected", ActionType.DEFEND)

func _on_AbilityButton_pressed():
	emit_signal("action_selected", ActionType.ABILITY)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_focus_entered():
	# Store the reference to the last focused button
	var focused = get_viewport().gui_get_focus_owner()
	if focused:
		last_focused_button_path = focused.get_path()

func show_menu():
	visible = true
	if last_focused_button_path != NodePath("") and has_node(last_focused_button_path):
		get_node(last_focused_button_path).grab_focus()
	else:
		$MenuContainer/AttackButton.grab_focus()

func hide_menu():
	visible = false
