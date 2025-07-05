extends Control

signal banana_clicked(amount: float) # Only this signal might still be relevant here

@onready var upgrades_manager: UpgradesManager = $RightPanel/Panel/VScrollBar/UpgradeList
@onready var banana_per_second_timer: Timer = $BananaPerSecondTimer
@onready var bananas_per_second: Label = $LeftPanel/MarginContainer/Statistics/HBoxContainer/BananasPerSecond
@onready var bananas_label: Label = $LeftPanel/MarginContainer/Statistics/BananasLabel


func _ready()->void:
	Persistence.load_data()
	
	# Init label
	on_global_bananas_changed(Globals.bananas)
	on_global_bananas_per_second_changed(Globals.bananas_per_second)
	
	# Global signals
	Globals.bananas_changed.connect(on_global_bananas_changed)
	Globals.bananas_per_second_changed.connect(on_global_bananas_per_second_changed)
	Globals.amount_per_click_changed.connect(on_global_amount_per_click_changed) # If you have a label for this
	# When upgrade bought, save
	upgrades_manager.upgrade_purchased_successful.connect(on_upgrade_purchased_successful)
	
	# TODO this is weird
	if Globals.upgrades.is_empty():
		upgrades_manager.set_upgrades_data(upgrades_manager.upgrades) 
	else:
		# Load upgrades
		upgrades_manager.load_upgrade_buttons()

	# TODO this is on autoload but maybe good to handle that
	if banana_per_second_timer:
		banana_per_second_timer.start()
	else:
		push_error("BananaPerSecondTimer node not found or referenced incorrectly!")

# --- Signal Handlers for UI Updates ---
func on_global_bananas_changed(new_amount: float):
	bananas_label.text = "Bananas: " + str(int(new_amount))

func on_global_bananas_per_second_changed(new_amount: float):
	bananas_per_second.text = "B/s: " + str(new_amount)

func on_global_amount_per_click_changed(new_amount: float):
	print("Click amount updated: " + str(new_amount))

func on_upgrade_purchased_successful():
	Persistence.save_data()

# --- Input and Timer Functions ---
func _on_banana_button_down() -> void:
	Globals.bananas += Globals.amount_per_click
	emit_signal("banana_clicked", Globals.amount_per_click)

func _on_banana_per_second_timer_timeout() -> void:
	Globals.bananas += Globals.bananas_per_second
	Persistence.save_data()
	
# TODO add saving with timeout and on upgrade bought, maybe every 30s or 60s?
