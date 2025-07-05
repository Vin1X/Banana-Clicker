class_name UpgradesManager
extends VBoxContainer

signal upgrade_purchased_successful
signal passive_effect_changed(new_value: float)
signal click_effect_changed(new_value: float)

@onready var upgrade_list: VBoxContainer = $"."
@onready var template_upgrade: Button = $TemplateUpgrade

@onready var one_time_upgrade_list: HFlowContainer = $"../../HScrollBar/OneTimeUpgradeList"
@onready var template_one_time_upgrade: Button = $"../../HScrollBar/OneTimeUpgradeList/TemplateOneTimeUpgrade"


func _ready():
	template_upgrade.visible = false
	call_deferred("load_upgrade_buttons") # called when ready

func load_upgrade_buttons():
	# Clear old upgrades
	for child in upgrade_list.get_children():
		if child != template_upgrade:
			child.queue_free()
	for child in one_time_upgrade_list.get_children():
		if child != template_one_time_upgrade:
			child.queue_free()

	for i in range(Globals.upgrades.size()):
		var upgrade = Globals.upgrades[i]
		var upgrade_item = template_upgrade.duplicate()

		# Clear onetime upgrades
		if upgrade.has("purchased") and upgrade["purchased"]: # TODO maybe add param in upgrade: one_time_purchase and check for that
			upgrade_item = template_one_time_upgrade.duplicate()
			one_time_upgrade_list.add_child(upgrade_item)
			#upgrade_item.queue_free()
			pass#TODO	
		else:
			upgrade_list.add_child(upgrade_item)
		upgrade_item.visible = true

		# Update button text and state based on loaded data
		update_button_display(upgrade_item, upgrade)
		

		var index := i # Capture the index for the closure
		upgrade_item.pressed.connect(func():
			var selected_upgrade = Globals.upgrades[index]
			if selected_upgrade.has("purchased") and selected_upgrade["purchased"]:
				print("Already bought: " + selected_upgrade["name"] + " (ID: " + selected_upgrade["id"] + ")")
				return
			if Globals.bananas >= selected_upgrade["cost"]:
				buy_upgrade(selected_upgrade, upgrade_item) # Pass the button_ref
			else:
				print("Not enough bananas for: " + selected_upgrade["name"] + " (ID: " + selected_upgrade["id"] + "); Has: " + str(Globals.bananas) + " Needs: " + str(selected_upgrade["cost"]))
		)

func buy_upgrade(upgrade: Dictionary, button_ref: Button):
	Globals.bananas -= upgrade["cost"] # Deduct cost from global bananas
	
	print("Bought: " + upgrade["name"] + "(ID: " + upgrade["id"] + ") for " + str(upgrade["cost"]) + " bananas")
	
	if upgrade["applies_to"] == "passive":
		if upgrade["effect_type"] == "add":
			Globals.bananas_per_second += upgrade["effect_value"]
			upgrade["purchased_amount"] += 1
			# Increase cost for next purchase
			upgrade["cost"] = int(upgrade["cost"] * 1.15) 
			emit_signal("passive_effect_changed", Globals.bananas_per_second)
		else:
			push_error("Unsupported effect type for passive upgrade: " + upgrade["effect_type"])
	elif upgrade["applies_to"] == "click":
		if upgrade["effect_type"] == "add":
			Globals.amount_per_click += upgrade["effect_value"]
			upgrade["purchased"] = true
			button_ref.disabled = true
			emit_signal("click_effect_changed", Globals.amount_per_click)
		elif upgrade["effect_type"] == "multiply":
			Globals.amount_per_click *= upgrade["effect_value"]
			upgrade["purchased"] = true
			button_ref.disabled = true
			emit_signal("click_effect_changed", Globals.amount_per_click)
		else:
			push_error("Unsupported effect type for click upgrade: " + upgrade["effect_type"])
	else:
		push_error("Unknown upgrade 'applies_to': " + upgrade["applies_to"])
	
	update_button_display(button_ref, upgrade)
	
	emit_signal("upgrade_purchased_successful")

func update_button_display(button_node: Button, upgrade_data: Dictionary):
	if upgrade_data["applies_to"] == "passive" and upgrade_data.has("purchased_amount"):
		button_node.text = "%s (Cost: %s) x%d" % [upgrade_data["name"], upgrade_data["cost"], upgrade_data["purchased_amount"]]
	else:
		button_node.text = "%s (Cost: %s)" % [upgrade_data["name"], upgrade_data["cost"]]

# This function will be called by your Game script to set initial data or loaded data
func set_upgrades_data(data: Array):
	Globals.upgrades = data
	load_upgrade_buttons() # Reload buttons with the new data

# This function will be called by your Game script to get data for saving
func get_upgrades_data() -> Array:
	return Globals.upgrades
