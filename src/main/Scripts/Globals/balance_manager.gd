extends Node

signal balance_changed

var balance: int = 100:
	get:
		return balance
	set (value):
		balance = value
		if balance < 0:
			balance = 0
		balance_changed.emit()

func is_enough(amount: int)-> bool: #return bool
	return amount <= balance

func try_buy(amount: int)-> bool: #return bool
	if amount < 0:
		return false
	if is_enough(amount):
		change_balance(-amount)
		return true
	return false

func change_balance (amount: int)-> void:
	var new_balance : int = balance + amount
	balance = new_balance
	
