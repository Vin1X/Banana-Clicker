extends Label

# destroy indicator after timeout
func _on_destroy_timer_timeout() -> void:
	queue_free()
