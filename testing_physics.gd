extends RigidBody2D

var movement_component: WASDMovementComponent = WASDMovementComponent.new()

func _physics_process(delta: float) -> void:
	movement_component.physics_update(self, delta)
