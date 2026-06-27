extends Node2D

func play_break_animation():
	$animation.play("break")
	await get_tree().create_timer(2).timeout
	get_parent().items.erase(self)
	queue_free()

func play_bomb_idle():
	var group = get_groups()
	print("GROUPS: ", group[0])
	$animation.play("bomb_idle")
	if group[0] == "Rock":
		remove_from_group(group[0])
		add_to_group("Scissors")
	elif group[0] == "Scissors":
		remove_from_group(group[0])
		add_to_group("Paper")
	elif group[0] == "Paper":
		remove_from_group(group[0])
		add_to_group("Rock")
	
func play_bomb_explosion():
	$animation.play("bomb_explosion")
