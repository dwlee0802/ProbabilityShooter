extends RefCounted
class_name Event

var subject
var location
var object
var code

enum {
	ENEMY_DAMAGED, ENEMY_DIED,
	PROJECTILE_HIT, PROJECTILE_CRIT, PROJECTILE_KILL,
	PLAYER_RELOAD, PLAYER_RELOAD_SUCCESS
}

func _init(who, where, what, _code) -> void:
	subject = who
	location = where
	object = what
	code = _code
