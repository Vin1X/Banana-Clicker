extends Node

signal bananas_changed(new_amount: float)
signal amount_per_click_changed(new_amount: float)
signal bananas_per_second_changed(new_amount: float)

var _bananas: float = 0.0
var _amount_per_click: float = 1.0
var _bananas_per_second: float = 0.0

var bananas: float:
	set(value):
		if _bananas != value:
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
		"id": "click_2x",
		"name": "Gathering Training",
		"description": "Double your bananas per click",
		"cost": 10,
		"applies_to": "click",
		"effect_type": "multiply",
		"effect_value": 2.0,
		"purchased": false,
	},
	{
		"id": "click_2x_2",
		"name": "Gathering Training 2",
		"description": "Quadruple your bananas per click",
		"cost": 1000,
		"applies_to": "click",
		"effect_type": "multiply",
		"effect_value": 4.0,
		"purchased": false,
	},
	{
		"id": "click_2x_3",
		"name": "Gathering Training 3",
		"description": "Sextuple your bananas per click",
		"cost": 50000,
		"applies_to": "click",
		"effect_type": "multiply",
		"effect_value": 6.0,
		"purchased": false,
	},
	{
		"id": "click_2x_4",
		"name": "Gathering Training 4",
		"description": "Octuple your bananas per click",
		"cost": 250000,
		"applies_to": "click",
		"effect_type": "multiply",
		"effect_value": 8.0,
		"purchased": false,
	},
	{
		"id": "click_2x_5",
		"name": "Gathering Training 5",
		"description": "Decuple your bananas per click",
		"cost": 1000000,
		"applies_to": "click",
		"effect_type": "multiply",
		"effect_value": 10.0,
		"purchased": false,
	},
	{
		"id": "monkey",
		"name": "Monkey",
		"description": "Each Monkey produces 0.2 bananas",
		"cost": 50,
		"applies_to": "passive",
		"effect_type": "add",
		"effect_value": 0.2,
		"purchased_amount": 0
	},
	{
		"id": "plantage",
		"name": "Banana Plantage",
		"description": "Each plantage produces 0.3 bananas",
		"cost": 150,
		"applies_to": "passive",
		"effect_type": "add",
		"effect_value": 0.3,
		"purchased_amount": 0
	}
]
