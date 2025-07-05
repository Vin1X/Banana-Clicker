extends Control

# Signals are no longer emitted directly from here for stats,
# but from Globals. You might keep banana_clicked for visual effects.
signal banana_clicked(amount: float) # Only this signal might still be relevant here

# @onready vars for UI elements
@onready var upgrades_manager: UpgradesManager = $RightPanel/Panel/UpgradeList # Reference to the UpgradesManager script
@onready var banana_per_second_timer: Timer = $BananaPerSecondTimer # Assuming it's a direct child of Game
@onready var bananas_per_second: Label = $LeftPanel/MarginContainer/Statistics/HBoxContainer/BananasPerSecond
@onready var bananas_label: Label = $LeftPanel/MarginContainer/Statistics/BananasLabel


func _ready()->void:
	# 1. Load data from persistence
	# Persistence.load_data() will load data into Globals directly.
	Persistence.load_data()
	
	# 2. Initialize UI labels with current global values
	# We don't emit local signals here anymore for stats; UI connects to Globals.
	on_global_bananas_changed(Globals.bananas) # Manually call to set initial text
	on_global_bananas_per_second_changed(Globals.bananas_per_second) # Manually call to set initial text
	
	# 3. Connect UI update functions to Globals signals
	Globals.bananas_changed.connect(on_global_bananas_changed)
	Globals.bananas_per_second_changed.connect(on_global_bananas_per_second_changed)
	Globals.amount_per_click_changed.connect(on_global_amount_per_click_changed) # If you have a label for this
	
	# 4. Connect to signals from the UpgradesManager
	# The upgrades_manager will tell us when a purchase happens, so we can save.
	upgrades_manager.upgrade_purchased_successful.connect(on_upgrade_purchased_successful)
	
	# 5. Load/refresh upgrade buttons in the UI
	# The UpgradesManager handles its own deferred loading,
	# but ensure it loads with the *correct* data (from Persistence).
	# Assuming set_upgrades_data in UpgradesManager will call load_upgrade_buttons
	if Globals.upgrades.is_empty(): # Check if manager has no upgrades yet (e.g., initial run)
		# Pass its own default upgrades if no loaded data
		upgrades_manager.set_upgrades_data(upgrades_manager.upgrades) 
	else:
		# If Persistence loaded new upgrades data into UpgradesManager (through Globals/Persistence flow),
		# then UpgradesManager should already have it and just needs to load its buttons.
		upgrades_manager.load_upgrade_buttons() # Tell the manager to load its UI

	# 6. Start the passive banana generation timer
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
	# You might have a label for this too, or just print for debugging
	print("Click amount updated: " + str(new_amount))

func on_upgrade_purchased_successful():
	# When an upgrade is bought, refresh UI (via Globals signals) and save game
	# Globals signals will already update labels automatically via their connections
	Persistence.save_data()


# --- Input and Timer Functions ---
func _on_banana_button_down() -> void:
	Globals.bananas += Globals.amount_per_click
	emit_signal("banana_clicked", Globals.amount_per_click) # For visual effects
	# Persistence.save_data() # You might consider saving less often, e.g., only on timer or exit.
	# If you save on timer, no need to save here.

func _on_banana_per_second_timer_timeout() -> void:
	Globals.bananas += Globals.bananas_per_second
	# No need to emit_signal("bananas_changed") here, as Globals.bananas setter will do it.
	Persistence.save_data() # Save regularly due to passive income
