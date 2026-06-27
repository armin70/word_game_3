extends Node2D

func play_break_animation():
	$animation.play("break")
	await get_tree().create_timer(2).timeout
	get_parent().items.erase(self)
	queue_free()

func play_bomb_idle():
	$animation.play("bomb_idle")


func play_bomb_explosion():
	$animation.play("bomb_explosion")
