extends Area2D
class_name EnemyShield

func _on_area_entered(area: Area2D) -> void:
	if area is Projectile:
		if area.is_player:
			print("meow")
			area.queue_free()
			queue_free()
