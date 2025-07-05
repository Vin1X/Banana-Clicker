extends MarginContainer

@onready var banana: TextureButton = $CenterContainer/Banana
@onready var indicators: Control = $"../../Indicators"
@onready var template: Label = $"../../Indicators/Template"

func _ready() -> void:
	banana.pivot_offset = banana.size / 2


func _on_banana_button_down() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(banana, "scale", Vector2(.9,.9),.1)


func _on_banana_button_up() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(banana, "scale", Vector2(1,1),.1)


func _on_game_banana_clicked(amount:int) -> void:
	var indicator = template.duplicate()
	indicator.text = "+" + str(amount)
	indicator.position = get_global_mouse_position()
	indicator.visible = true
	indicators.add_child(indicator)
	indicator.get_child(0).start()
