extends Node2D
var type = "" 
func play_break_animation():
	$animation.play("break")
	await get_tree().create_timer(2).timeout
	get_parent().items.erase(self)
	queue_free()

func play_bomb_idle():
	var group = get_groups()
	print("GROUPS: ", group[0])
	$animation.play("bomb_idle")
	remove_from_group(group[0])
	add_to_group("bomb")
	if group[0] == "Rock":
		remove_from_group(group[0])
		type = "Scissors"
	elif group[0] == "Scissors":
		remove_from_group(group[0])
		type = "Paper"
	elif group[0] == "Paper":
		remove_from_group(group[0])
		type = "Rock"



func play_heal_animation():
	$animation.play("heal")
	await get_tree().create_timer(2).timeout
	queue_free()

func play_bomb_explode():
	$animation.play("bomb_explosion")
	await get_tree().create_timer(2.5).timeout
	get_parent().items.erase(self)
	queue_free()
	
