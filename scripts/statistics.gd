extends VBoxContainer

@onready var bananas_per_second: Label = $HBoxContainer/BananasPerSecond
@onready var bananas_spend: Label = $HBoxContainer/BananasSpend
@onready var bananas_label: Label = $BananasLabel

func _on_control_bananas_changed(amount:float) -> void:
	print("Bananas: " + str(amount))
	bananas_label.text = str(int(amount)) + " Bananas"


func _on_game_bananas_per_second_changed(amount:float) -> void:
	print("BPS: " + str(amount))
	bananas_per_second.text = str(int(amount)) + " Per Second"
