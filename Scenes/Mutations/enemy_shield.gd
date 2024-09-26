extends Area2D
class_name EnemyShield

@onready
var shield_remove_animation: AnimationPlayer = $AnimationPlayer


func _on_area_entered(area: Area2D) -> void:
	if area is Projectile:
		if area.is_player:
			print("meow")
			area.queue_free()
			
			# disable collision while animation is playing
			monitoring = false
			shield_remove_animation.play("remove_shield")
			await shield_remove_animation.animation_finished
			print("remove shield")
			queue_free()

func increase_size(rate: float) -> void:
	$Sprite2D.scale *= rate
	$CollisionShape2D.scale *= rate
