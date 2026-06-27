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
	var similar_items = []
	print(" type heal:", type)
	similar_items = get_tree().get_nodes_in_group(type)
	if similar_items.size() >= 2:
		print("cuurent deck before:", current_deck)
		while current_deck.has(type):
			current_deck.erase(type)
		#current_deck = current_deck.filter(func(item): return item[0] != type)
		print("cuurent deck after:", current_deck)
		
		for item in similar_items :
			item.play_break_animation()
			#remove_type(type)
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
		while current_deck.has("Scissors"):
			current_deck.erase("Scissors")
	elif type_name == "Paper":
		targets = get_tree().get_nodes_in_group("Rock")
		while current_deck.has("Rock"):
			current_deck.erase("Rock")
	elif type_name == "Scissors":
		targets = get_tree().get_nodes_in_group("Paper")
		while current_deck.has("Paper"):
			current_deck.erase("Paper")
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
	if debuff > 1:
		bomb_planted(type_name)
	return debuff

func bomb_planted(type_name):
	var targets
	targets = get_tree().get_nodes_in_group(type_name)
	print("targets: ",targets)
	targets[0].play_bomb_idle()

func wait_to_finish_animation(targets):
	for node in targets:
		node.play_break_animation()

func fill_free_space():
	var deck = get_child_count()
	print("deck count: ", deck)
	if deck < 4:
		var number = 4 - deck
		add_to_placeholder(number)
