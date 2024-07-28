extends Area2D
class_name EffectArea

var bodies = []
var areas = []

@export
var duration: float = 0

func _ready():
	$Timer.start(duration)
	$Timer.timeout.connect(queue_free)
	set_size(256)
	
## does something to units inside this every frame
func _physics_process(_delta) -> void:
	bodies = get_overlapping_bodies()
	areas = get_overlapping_areas()

## sets size of collider and sprite
func set_size(radius: float) -> void:
	var shape: CircleShape2D = $CollisionShape2D.shape
	shape.set_radius(radius)
	var sprite: Sprite2D = $Sprite2D
	sprite.scale = Vector2(radius/256.0, radius/256.0)
