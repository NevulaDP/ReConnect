extends Control

enum ActionType {ATTACK, DEFEND, ABILITY}

signal action_selected(action_type:int)

# Called when the node enters the scene tree for the first time.
func _ready():
	$MenuContainer/AttackButton.grab_focus()
	$MenuContainer/AttackButton.connect("pressed", Callable(self, "_on_AttackButton_pressed"))
	$MenuContainer/DefendButton.connect("pressed",Callable(self,"_on_DefendButton_pressed"))
	$MenuContainer/AbilityButton.connect("pressed",Callable(self,"_on_AbilityButton_pressed"))

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
