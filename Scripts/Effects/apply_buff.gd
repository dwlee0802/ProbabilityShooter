extends Effect
class_name ApplyBuffEffect

@export
var buff: BuffData = null

func activate(_game_ref: Game, event: Event):
	if event.subject is PlayerUnit:
		var player: PlayerUnit = event.subject
		var new_buff: Buff = Buff.new(player, buff)
		player.add_buff(new_buff)
