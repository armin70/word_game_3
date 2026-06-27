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
var rps = ['Rock','Paper','Scissors']
var free_space = 0 
var items: Array = []
func _ready() -> void:
	full_deck_generator()
	pick_random_card(4)
	add_to_placeholder(new_deck)

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

func get_neighbors(item):
	var i = items.find(item)
	print("my index: ", i)
	print("items:",items)
	var left = items[i - 1] if i > 0 else null
	var right = items[i + 1] if i < items.size() - 1 else null
	
	return [left, right]

func add_to_placeholder(choices):
	var selected_scene
	var index = get_child_count() - 1
	for choice in choices:
		index += 1
		if choice[0] == 'Rock':
			selected_scene =  ROCK.instantiate()
		elif choice[0] == 'Paper':
			selected_scene = PAPER.instantiate()
		elif choice[0] == 'Scissors':
			selected_scene = SCISSORS.instantiate()
		selected_scene.add_to_group(choice[0])
		selected_scene.play_potion_animation(choice)
		add_item(selected_scene)
		#placeholders[index].add_child(selected_scene)
	#for placeholder in placeholders:
		#if placeholder.get_children().size() > 0:
			#index += 1
		#else:
			

func full_deck_generator():
	var card
	var choice
	for i in range(0,35):
		choice = rps.pick_random()
		card = [choice, ""]
		full_deck.append(card)
	for i in range(0,8):
		for potion in potions:
			choice = rps.pick_random()
			card = [choice, potion]
			full_deck.append(card)
	print("full_deck:",full_deck)

func pick_random_card(number):
	new_deck =[]
	for i in number:
		while true:
			var index = randi() % full_deck.size()
			var value = full_deck[index]
			var type = value[0]
			var count = 0
			for card in current_deck:
				if card[0] == type:
					count += 1
			
			if count < 2:
				full_deck.remove_at(index)
				current_deck.append(value)
				new_deck.append(value)
				break

func should_heal(type):
	var similar_items = []
	similar_items = get_tree().get_nodes_in_group(type)
	if similar_items.size() >= 2:
		for item in similar_items :
			item.play_break_animation(false)
			current_deck = current_deck.filter(func(item): return item[0] != type)
			remove_type(type)
			fill_free_space()
		return true
	else:
		return false
	

func remove_type(type_name: String):
	var targets
	var buff =[]
	var potion
	if type_name == "Rock":
		targets = get_tree().get_nodes_in_group("Scissors")
		current_deck = current_deck.filter(func(item): return item[0] != "Scissors")
	elif type_name == "Paper":
		targets = get_tree().get_nodes_in_group("Rock")
		current_deck = current_deck.filter(func(item): return item[0] != "Rock")
	elif type_name == "Scissors":
		targets = get_tree().get_nodes_in_group("Paper")
		current_deck = current_deck.filter(func(item): return item[0] != "Paper")
	else:
		print('cant catch')
	if targets:
		for target in targets:
			if target.effected !="":
				buff.append(1.75)
				target.get_buff(1.75)
			else:
				buff.append(1)
				target.get_buff(1)
				
	get_parent().multiplier = buff
	await wait_to_finish_animation(targets)
	free_space = targets.size()
	await get_tree().create_timer(4).timeout
	fill_free_space()

func spread_effect(node):
	var affected =[]
	var child
	if node == "place1":
		print("place1")
		child = $place2.get_child(0)
		affected.append(child)
	elif node == "place2":
		print("place2")
		
		child = $place1.get_child(0)
		affected.append(child)
		child = $place3.get_child(0)
		affected.append(child)
	elif node == "place3":
		print("place3")
		
		child = $place2.get_child(0)
		affected.append(child)
		child = $place4.get_child(0)
		affected.append(child)
	elif node == "place4":
		print("place4")
		child = $place3.get_child(0)
		affected.append(child)
	else:
		print("catch nothing")
	print("affected: ", affected)
	return affected


func wait_to_finish_animation(targets):
	for node in targets:
		node.play_break_animation(true)

func get_debuff(type_name):
	var targets
	var debuff = []
	if type_name == "Rock":
		targets = get_tree().get_nodes_in_group("Paper")
	elif type_name == "Paper":
		targets = get_tree().get_nodes_in_group("Scissors")
	elif type_name == "Scissors":
		targets = get_tree().get_nodes_in_group("Rock")
	print( "targetssss ", targets)
	if targets:
		for node in targets:
			print("gettt")
			print("effect: ", node.show_effect())
			if node.effected:
				if node.effected == "fire" or node.effected == "thunder":
					debuff.append(1.25)
					node.get_debuff("-1.25")
				elif node.effected == "water":
					debuff.append(0)
					node.get_debuff("0")
				print("debuffed:",debuff )
			else:
				debuff.append(.5)
				node.get_debuff("-1")
				print("debuffed:",debuff )
	return debuff
	#get_parent().debuff = debuff

func fill_free_space():
	var deck = get_child_count()
	print("deck count: ", deck)
	if deck < 4:
		print("filling free space")
		var current_cards = []
		new_deck = []
		var number = 4 - deck
		pick_random_card(number)
		add_to_placeholder(new_deck)
