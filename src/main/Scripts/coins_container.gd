extends Node

class_name CoinsContainer

@onready var coins_label = %Coins_Label

func _ready():
	BalanceManager.balance_changed.connect(_on_balance_changed)
	update_balance()
	
func update_balance():
	coins_label.text = str(BalanceManager.balance)

func _on_balance_changed():
	update_balance()
