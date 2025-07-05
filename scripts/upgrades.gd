# File: UpgradesManager.gd
class_name UpgradesManager # Add this line
extends VBoxContainer # This script doesn't need to be a VBoxContainer itself

signal upgrade_purchased_successful
# You might want to emit a signal when upgrades affect global stats
# These signals could be connected to by a GameManager (Autoload) or the main Game script
signal passive_effect_changed(new_value: float)
signal click_effect_changed(new_value: float)

@onready var upgrade_list: VBoxContainer = $"."
@onready var template_upgrade: Button = $TemplateUpgrade


func _ready():
	# Ensure template is hidden from start
	template_upgrade.visible = false
	# Load UI components after the node is ready in the tree
	call_deferred("load_upgrade_buttons")

# This function is now responsible for creating the buttons in the UI
func load_upgrade_buttons():
	# Clear existing buttons if any, for reloading purposes (e.g., after loading save)
	for child in upgrade_list.get_children():
		if child != template_upgrade: # Don't remove the template itself
			child.queue_free()

	for i in range(Globals.upgrades.size()):
		var upgrade = Globals.upgrades[i]
		var upgrade_item = template_upgrade.duplicate()
		
		# Add the duplicated item to the VBoxContainer
		upgrade_list.add_child(upgrade_item)
		upgrade_item.visible = true # Make it visible

		# Update button text and state based on loaded data
		update_button_display(upgrade_item, upgrade)
		
		# If it's a one-time purchase (like "click" upgrades) and already purchased, disable it
		if upgrade.has("purchased") and upgrade["purchased"] and upgrade["applies_to"] == "click":
			upgrade_item.disabled = true

		var index := i # Capture the index for the closure
		upgrade_item.pressed.connect(func():
			var selected_upgrade = Globals.upgrades[index]
			
			# If it's a one-time purchase and already bought, do nothing
			if selected_upgrade.has("purchased") and selected_upgrade["purchased"]:
				print("Already bought: " + selected_upgrade["name"] + " (ID: " + selected_upgrade["id"] + ")")
				return

			# Check against global bananas via a GameManager/Globals Autoload
			if Globals.bananas >= selected_upgrade["cost"]:
				buy_upgrade(selected_upgrade, upgrade_item) # Pass the button_ref
			else:
				print("Not enough bananas for: " + selected_upgrade["name"] + " (ID: " + selected_upgrade["id"] + "); Has: " + str(Globals.bananas) + " Needs: " + str(selected_upgrade["cost"]))
		)

func buy_upgrade(upgrade: Dictionary, button_ref: Button):
	Globals.bananas -= upgrade["cost"] # Deduct cost from global bananas
	
	print("Bought: " + upgrade["name"] + "(ID: " + upgrade["id"] + ") for " + str(upgrade["cost"]) + " bananas")
	
	if upgrade["applies_to"] == "passive":
		if upgrade["effect_type"] == "additive":
			Globals.bananas_per_second += upgrade["effect_value"]
			upgrade["purchased_amount"] += 1
			# Example: increase cost for next purchase
			upgrade["cost"] = int(upgrade["cost"] * 1.15) 
			emit_signal("passive_effect_changed", Globals.bananas_per_second)
		else:
			push_error("Unsupported effect type for passive upgrade: " + upgrade["effect_type"])
	elif upgrade["applies_to"] == "click":
		if upgrade["effect_type"] == "additive":
			Globals.amount_per_click += upgrade["effect_value"]
			upgrade["purchased"] = true # Mark as purchased for one-time
			button_ref.disabled = true # Disable the specific button
			emit_signal("click_effect_changed", Globals.amount_per_click)
		else:
			push_error("Unsupported effect type for click upgrade: " + upgrade["effect_type"])
	else:
		push_error("Unknown upgrade 'applies_to': " + upgrade["applies_to"])
	
	# Update button display after purchase (especially for cost changes/amounts)
	update_button_display(button_ref, upgrade)
	
	# Emit a generic signal for the main game script to update UI/save
	emit_signal("upgrade_purchased_successful")

func update_button_display(button_node: Button, upgrade_data: Dictionary):
	if upgrade_data["applies_to"] == "passive" and upgrade_data.has("purchased_amount"):
		button_node.text = "%s (Cost: %s) x%d" % [upgrade_data["name"], upgrade_data["cost"], upgrade_data["purchased_amount"]]
	else: # For click upgrades or others
		button_node.text = "%s (Cost: %s)" % [upgrade_data["name"], upgrade_data["cost"]]

# This function will be called by your Game script to set initial data or loaded data
func set_upgrades_data(data: Array):
	Globals.upgrades = data
	load_upgrade_buttons() # Reload buttons with the new data

# This function will be called by your Game script to get data for saving
func get_upgrades_data() -> Array:
	return Globals.upgrades
