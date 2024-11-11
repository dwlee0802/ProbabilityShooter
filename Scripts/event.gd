extends RefCounted
class_name Event

var subject
var location
var object
var code

enum EventCode {
	ENEMY_DAMAGED, ENEMY_DIED,
	PROJECTILE_HIT, PROJECTILE_HIT_FULL_HP, PROJECTILE_CRIT, PROJECTILE_KILL,
	PLAYER_RELOAD, PLAYER_RELOAD_SUCCESS,
	UPGRADE_TAKEN, STATIC_UPGRADE_TAKEN
}

func _init(who, where, what, _code) -> void:
	subject = who
	location = where
	object = what
	code = _code
