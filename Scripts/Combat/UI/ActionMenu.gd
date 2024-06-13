extends Control

enum ActionType {ATTACK, DEFEND, ABILITY}

signal action_selected(action_type:int)

# Called when the node enters the scene tree for the first time.
func _ready():
	$AttackButton.connect("pressed", Callable(self, "_on_AttackButton_pressed"))
	$DefendButton.connect("pressed",Callable(self,"_on_DefendButton_pressed"))
	$AbilityButton.connect("pressed",Callable(self,"_on_AbilityButton_pressed"))

func _on_AttackButton_pressed():
	emit_signal("action_selected", ActionType.ATTACK)

func _on_DefendButton_pressed():
	emit_signal("action_selected", ActionType.DEFEND)

func _on_AbilityButton_pressed():
	emit_signal("action_selected", ActionType.ABILITY)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
