# File: Globals.gd (Set as Autoload in Project Settings -> Autoload tab, Node Name: Globals)
extends Node

signal bananas_changed(new_amount: float)
signal amount_per_click_changed(new_amount: float)
signal bananas_per_second_changed(new_amount: float)

var _bananas: float = 0.0
var _amount_per_click: float = 1.0
var _bananas_per_second: float = 0.0

# Use properties for controlled access and signal emission
var bananas: float:
	set(value):
		if _bananas != value: # Only emit if value actually changes
			_bananas = value
			emit_signal("bananas_changed", _bananas)
	get:
		return _bananas

var amount_per_click: float:
	set(value):
		if _amount_per_click != value:
			_amount_per_click = value
			emit_signal("amount_per_click_changed", _amount_per_click)
	get:
		return _amount_per_click

var bananas_per_second: float:
	set(value):
		if _bananas_per_second != value:
			_bananas_per_second = value
			emit_signal("bananas_per_second_changed", _bananas_per_second)
	get:
		return _bananas_per_second
		

var upgrades = [
	{
		"id": "click_power_up",
		"name": "Gathering Training",
		"description": "Each click gives +1 more banana",
		"cost": 10,
		"applies_to": "click",
		"effect_type": "additive", # This should match "additive" for click upgrades
		"effect_value": 1.0,
		"purchased": false, # For one-time purchases
	},
	{
		"id": "monkey",
		"name": "Monkey",
		"description": "Each Monkey produces 0.2 bananas",
		"cost": 50,
		"applies_to": "passive",
		"effect_type": "additive",
		"effect_value": 0.2, # Use float literal for consistency
		"purchased_amount": 0 # For multiple purchases
	},
	{
		"id": "plantage",
		"name": "Banana Plantage",
		"description": "Each plantage produces 0.3 bananas",
		"cost": 150,
		"applies_to": "passive",
		"effect_type": "additive",
		"effect_value": 0.3, # Use float literal for consistency
		"purchased_amount": 0
	}
]
