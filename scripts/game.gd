extends Control

const save_path = "user://userdata.save"

var bananas = 0
var amount_per_click = 1
var bananas_per_second = 1

@onready var upgrade_list: BoxContainer = $RightPanel/Panel/UpgradeList
@onready var template_upgrade: Button = $RightPanel/Panel/UpgradeList/TemplateUpgrade

signal bananas_changed
signal bananas_per_second_changed
signal banana_clicked

var upgrades = [
	{
		"id": "click_power_up",
		"name": "Gathering Training",
		"description": "Each click gives +1 more banana",
		"cost": 10,
		"applies_to": "click",
		"effect_type": "additive",
		"effect_value": 1.0,
		"purchased": false,
	},
	{
		"id": "monkey",
		"name": "Monkey",
		"description": "Each Monkey produces 0.2 bananas",
		"cost": 50,
		"applies_to": "passive",
		"effect_type": "additive",
		"effect_value": .2,
		"purchased": false,
		"purchased_amount": 0
	},
	{
		"id": "plantage",
		"name": "Banana Plantage",
		"description": "Each plantage produces 0.3 bananas",
		"cost": 150,
		"applies_to": "passive",
		"effect_type": "additive",
		"effect_value": .3,
		"purchased": false,
		"purchased_amount": 0
	}
]

func _ready()->void:
	# Load data
	load_data()
	
	# Load labels
	emit_signal("bananas_changed", bananas)
	emit_signal("bananas_per_second_changed", bananas_per_second)
	
	# Load upgrades
	call_deferred("load_upgrades")

func save_data():
	var data = {
		"bananas": bananas,
		"amount_per_click": amount_per_click,
		"bananas_per_second": bananas_per_second,
		"upgrades": upgrades,
	}
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_var(data)
	file.close()

func load_data():
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		var data = file.get_var()
		file.close()
		if typeof(data) == TYPE_DICTIONARY:
			bananas = data.get("bananas",0)
			amount_per_click = data.get("amount_per_click",0)
			bananas_per_second = data.get("bananas_per_second",0)
			# Load the upgrades array
			var loaded_upgrades = data.get("upgrades", [])
			# Merge loaded upgrades with default upgrades to handle new upgrades
			for i in range(upgrades.size()):
				for loaded_upgrade in loaded_upgrades:
					if upgrades[i]["id"] == loaded_upgrade["id"]:
						upgrades[i]["purchased"] = loaded_upgrade["purchased"]
						break
	else:
		save_data()

func load_upgrades():
	for i in range(upgrades.size()):
		var upgrade = upgrades[i]
		var upgrade_item = template_upgrade.duplicate()
		upgrade_item.visible = true
		upgrade_item.text = upgrade["name"]
		upgrade_item.tooltip_text = upgrade["description"]
		upgrade_list.add_child(upgrade_item)

		# Capture the index explicitly
		var index := i
		var button_ref: Button = upgrade_item

		button_ref.pressed.connect(func():
			var selected_upgrade = upgrades[index]

			if selected_upgrade["purchased"]:
				print("Already bought: " + selected_upgrade["name"] + " (ID: " + selected_upgrade["id"] + ")")
				return

			if bananas >= selected_upgrade["cost"]:
				buy_upgrade(selected_upgrade)
				if selected_upgrade["purchased"] == true and selected_upgrade["applies_to"] == "click":
					selected_upgrade["purchased"] = true
					button_ref.disabled = true
			else:
				print("Not enough bananas for: " + selected_upgrade["name"] + " (ID: " + selected_upgrade["id"] + "); Has: " + str(bananas) + "Needs: " + str(selected_upgrade["cost"]))
		)

func buy_upgrade(upgrade)->void:
	bananas -= upgrade["cost"] # Deduct cost
	print("Bought: " + upgrade["name"] + "(ID: " + upgrade["id"] + ") for " + str(upgrade["cost"]) + " bananas")
	if upgrade["applies_to"] == "passive":
		if upgrade["effect_type"] == "multiply":
			bananas_per_second *= upgrade["effect_value"]
		elif upgrade["effect_type"] == "additive":
			bananas_per_second += upgrade["effect_value"]
		else:
			push_error("Upgrade type unknown: " + upgrade["effect_type"] + "...")
	elif upgrade["applies_to"] == "click":
		if upgrade["effect_type"] == "multiplier":
			amount_per_click *= upgrade["effect_value"]
		elif upgrade["effect_type"] == "additive":
			amount_per_click += upgrade["effect_value"]
		else:
			push_error("Upgrade type unknown: " + upgrade["effect_type"] + "...")
	else:
		push_error("Unkwon upgrade applies_to: " + upgrade["applies_to"] + "...")
	
	emit_signal("bananas_changed", bananas)
	emit_signal("bananas_per_second_changed", bananas_per_second)
	save_data()


func _on_banana_button_down() -> void:
	bananas += amount_per_click
	emit_signal("bananas_changed", bananas)
	emit_signal("banana_clicked", amount_per_click)
	save_data()


func _on_banana_per_second_timer_timeout() -> void:
	bananas += bananas_per_second
	emit_signal("bananas_changed", bananas)
