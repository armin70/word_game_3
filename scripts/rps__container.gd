extends Node2D
@onready var placeholders =[
	$place1,
	$place2,
	$place3,
	$place4
]
@onready var potions = ["fire",'water','thunder']
const ROCK = preload("uid://dx1kcjudo0gxe")
const PAPER = preload("uid://cocrlxvcogpqs")
const SCISSORS = preload("uid://c43c7km5wekoc")

@export var spacing := 150.0
const SPACING := 150.0
var current_deck = []
var new_deck = []
var full_deck = []
var rps = ['Paper','Scissors']
var free_space = 0 
var items: Array = []
var is_bomb = false
var bomb_timer = 3
var is_bombing = false
var bomb_trigger = false
var current_bomb

func _ready() -> void:
	add_to_placeholder(4)

func add_item(item: Node2D):
	add_child(item)
	items.append(item)
	update_layout()
	print("items: ", items)
	

func remove_item(item: Node2D):
	item.queue_free()
	await get_tree().process_frame
	update_layout()


func update_layout():
	var index := 0

	for child in get_children():
		if child is Node2D:
			child.position = Vector2(index * SPACING, 0)
			index += 1

func add_to_placeholder(choices):
	var selected_scene
	var index = get_child_count() - 1
	for choice in range(0,choices):
		index += 1
		var reapet = 0
		var chosen = rps.pick_random()
		print("current_deck:", current_deck)
		while current_deck.count(chosen) > 1 :
			chosen = rps.pick_random()
			reapet += 1
			print("repeat",reapet)
			print("count",current_deck)
		current_deck.append(chosen)
		if chosen == 'Rock':
			selected_scene =  ROCK.instantiate()
		elif chosen == 'Paper':
			selected_scene = PAPER.instantiate()
		elif chosen == 'Scissors':
			selected_scene = SCISSORS.instantiate()
		selected_scene.add_to_group(chosen)
		add_item(selected_scene)
		#placeholders[index].add_child(selected_scene)
	#for placeholder in placeholders:
		#if placeholder.get_children().size() > 0:
			#index += 1
		#else:
			


func should_heal(type):
	if not is_bombing:
		var similar_items = []
		similar_items = get_tree().get_nodes_in_group(type)
		if similar_items.size() >= 2:
			while current_deck.has(type):
				current_deck.erase(type)
			for rps_item in similar_items :
				rps_item.play_heal_animation()
			return true
		else:
			return false
	


func remove_type(type_name: String):
	var targets
	var buff =[]
	var potion
	current_bomb  = get_tree().get_nodes_in_group("bomb")
	if current_bomb:
		print("boooomb:", current_bomb[0].type)
	if type_name == "Rock":
		targets = get_tree().get_nodes_in_group("Scissors")
		while current_deck.has("Scissors"):
			current_deck.erase("Scissors")
		if current_bomb:
			if current_bomb[0].type == "Scissors":
				print("bomb triggered ",bomb_timer)
				if bomb_timer == 2 or bomb_timer == 0:
					current_deck.erase("bomb")
					current_bomb[0].queue_free()
					is_bomb = false
				elif bomb_timer == 1:
					current_deck.erase("bomb")
					bomb_trigger = true
					current_bomb[0].play_bomb_explode()
					is_bomb = false
	elif type_name == "Paper":
		targets = get_tree().get_nodes_in_group("Rock")
		while current_deck.has("Rock"):
			current_deck.erase("Rock")
		if current_bomb:
			if current_bomb[0].type == "Rock":
				print("bomb triggered ",bomb_timer)
				if bomb_timer == 2 or bomb_timer == 0:
					current_deck.erase("bomb")
					current_bomb[0].queue_free()
					is_bomb = false
				elif bomb_timer == 1:
					current_deck.erase("bomb")
					bomb_trigger = true
					current_bomb[0].play_bomb_explode()
					is_bomb = false
	elif type_name == "Scissors":
		targets = get_tree().get_nodes_in_group("Paper")
		while current_deck.has("Paper"):
			current_deck.erase("Paper")
		if current_bomb:
			if current_bomb[0].type == "Paper":
				print("bomb triggered ",bomb_timer)
				if bomb_timer == 0 or bomb_timer == 2:
					current_deck.erase("bomb")
					current_bomb[0].queue_free()
					is_bomb = false
				elif bomb_timer == 1:
					current_deck.erase("bomb")
					bomb_trigger = true
					current_bomb[0].play_bomb_explode()
					is_bomb = false
					
	else:
		print('cant catch')
	if targets:
		buff = targets.size()
	else:
		buff = 0
				
	get_parent().multiplier = buff
	await wait_to_finish_animation(targets)
	free_space = targets.size()
	await get_tree().create_timer(4).timeout
	fill_free_space()


func get_debuff(type_name):
	var targets
	var debuff = 0
	if type_name == "Rock":
		targets = get_tree().get_nodes_in_group("Paper")
	elif type_name == "Paper":
		targets = get_tree().get_nodes_in_group("Scissors")
	elif type_name == "Scissors":
		targets = get_tree().get_nodes_in_group("Rock")
	if targets:
		print(targets ,"trget size:", targets.size())
		debuff = targets.size()
	else:
		debuff = 0
	return debuff

func check_bombing(type_name):
	
	var targets
	var similar
	var debuff = 0
	if not is_bomb:
		is_bombing = true
		if type_name == "Rock":
			targets = get_tree().get_nodes_in_group("Paper")
			similar = get_tree().get_nodes_in_group("Rock")
		elif type_name == "Paper":
			targets = get_tree().get_nodes_in_group("Scissors")
			similar = get_tree().get_nodes_in_group("Paper")
		elif type_name == "Scissors":
			targets = get_tree().get_nodes_in_group("Rock")
			similar = get_tree().get_nodes_in_group("Scissors")
			
		if targets:
			print("bomb target:", targets)
			debuff = targets.size()
		else:
			debuff = 0
		if debuff > 1 and similar.size()>0:
			bomb_planted(type_name)
			return true
		else:
			is_bombing = false
			return false
	else:
		is_bombing = false
		return false


func bomb_planted(type_name: String):
	if not is_bomb:
		var targets
		targets = get_tree().get_nodes_in_group(type_name)
		if targets:
			targets[0].play_bomb_idle()
			is_bomb = true
			bomb_timer = 3
			current_deck.erase(type_name)
			current_deck.append("bomb")

func bomb_explode():
	var bomb = get_tree().get_nodes_in_group("bomb")
	bomb[0].play_bomb_explode()


func wait_to_finish_animation(targets):
	for node in targets:
		node.play_break_animation()

func fill_free_space():
	var deck = get_child_count()
	print("deck count: ", deck)
	if deck < 4:
		var number = 4 - deck
		add_to_placeholder(number)
