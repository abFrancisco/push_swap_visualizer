extends Node2D

@export var grid : GridContainer
var input_queue : String = ""
var operation : String = ""

var stack_a : Array = [0, 5, 10, 15, 1, 6, 11, 16, 2, 3, 4, 19, 18, 17, 14, 13, 12, 7, 9, 8]
var stack_b : Array = []
var labels_a : Array[Label]
var labels_b : Array[Label]

var ratio = 2

func _ready():
	fill_grid()
	print("stack a = " + str(stack_a))
	print("stack b = " + str(stack_b))
	update_display()


#region Display Table
func fill_grid():
	for i in range(20):
		var label_a = Label.new()
		var label_b = Label.new()
		var label_sep = Label.new()
		label_a.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		label_sep.text = " | "
		grid.add_child(label_a)
		grid.add_child(label_sep)
		grid.add_child(label_b)
		labels_a.append(label_a)
		labels_b.append(label_b)
		

func update_display():
	for i in range(20):
		if i < stack_a.size():
			labels_a[i].text = str(stack_a[i])
		else:
			labels_a[i].text = " --- "
		if i < stack_b.size():
			labels_b[i].text = str(stack_b[i])
		else:
			labels_b[i].text = " --- "
#endregion

func run():
	split_stacks()#pushes a fraction (defined by ratio) of elements to stack b
	sort_a()#sorts the remaining elemnts in stack a with allowed operations
	sort_b_into_a()#sorts the remaining from b to a with rotations and pushes
	#by here should have a sorted stack
	

#region Stack Operations
func push(stack : String):
	if (stack == "a"):
		if stack_a.size() >=20:
			return
		stack_a.push_front(stack_b.pop_front())
	else:
		if stack_b.size() >=20:
			return
		stack_b.push_front(stack_a.pop_front())
	update_display()

func pa():
	push("a")

func pb():
	push("b")

func swap(stack : String):
	if stack == "a":
		if stack_a.size() > 1:
			stack_a.insert(1, stack_a.pop_front())
	if stack == "b":
		if stack_b.size() > 1:
			stack_b.insert(1, stack_b.pop_front())
	update_display()

func sa():
	swap("a")

func sb():
	swap("b")

func ss():
	swap("a")
	swap("b")

func rotate_stack(stack : String, dir : int):
	if stack == "a":
		if stack_a.size() > 1:
			if dir == 1:
				stack_a.push_front(stack_a.pop_back())
			if dir == -1:
				stack_a.push_back(stack_a.pop_front())
	if stack == "b":
		if stack_b.size() > 1:
			if dir == 1:
				stack_b.push_front(stack_b.pop_back())
			if dir == -1:
				stack_b.push_back(stack_b.pop_front())
	update_display()

func ra():
	rotate_stack("a", 1)

func rb():
	rotate_stack("b", 1)

func rr():
	rotate_stack("a", 1)
	rotate_stack("b", 1)

func rra():
	rotate_stack("a", -1)

func rrb():
	rotate_stack("b", -1)

func rrr():
	rotate_stack("a", -1)
	rotate_stack("b", -1)
#endregion

func split_stacks():
	return

func sort_a():
	return

func sort_b_into_a():
	return


func check_input():
	for x in ["rra", "rrb", "rrr", "pa", "pb", "sa", "sb", "ss", "ra", "rb", "rr"]:
		if input_queue.length() >= x.length():
			if input_queue.findn(x) != -1:
				input_queue = ""
				operation = x
				call(operation)
				return
	if operation:
		call(operation)

func _input(event):
	if event is InputEventKey:
		if event.is_pressed():
			if not event.is_echo():
				if event.keycode >= KEY_A and event.keycode <= KEY_Z:
					input_queue += OS.get_keycode_string(event.keycode)
	if event.is_action_pressed("ui_accept"):
		check_input()
