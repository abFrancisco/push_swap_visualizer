extends Node2D

@export var grid : GridContainer
var input_queue : String = ""
var operation : String = ""

var stack_a : Array = []
var stack_b : Array = []
var labels_a : Array[Label]
var labels_b : Array[Label]
var elements_pushed : int = 0
var max_elements_list : PackedInt32Array = []
var max_elements : int = 500
var ratio_list : PackedInt32Array = []
var ratio : int = 10

var operation_log : Array[String] = []


func _ready():
	for i in range(50, 500, 5):
		max_elements_list.push_back(i)
	for i in range(2, 20):
		ratio_list.push_back(i)
	
	for n1 in max_elements_list:
		for i in range(10):
			var run_results : Array[PackedInt32Array] = []
			for n2 in ratio_list:
					run_results.push_back(run(n1, n2))
			analyze_results(run_results)

func run(_max_elements : int, _ratio : int) -> PackedInt32Array:
	randomize()
	stack_a.clear()
	stack_b.clear()
	operation_log.clear()
	max_elements = _max_elements
	ratio = _ratio
	elements_pushed = max_elements / ratio
	fill_stack_a()
	split_stacks()#pushes a fraction (defined by ratio) of elements to stack b
	sort_a()#sorts the remaining elemnts in stack a with allowed operations
	while not stack_b.is_empty():
		sort_b_into_a()#sorts the remaining from b to a with rotations and pushes
	return PackedInt32Array([_max_elements, _ratio, operation_log.size()])

func analyze_results(run_results : Array[PackedInt32Array]):
	var best_move_count : int =  2147483647
	var best_result : PackedInt32Array = []
	for run in run_results:
		if run[2] < best_move_count:
			best_move_count = run[2]
			best_result = run
	print("max elements = %6d | " % best_result[0] + "ratio = %3d | " % best_result[1] + "movements = %6d " % best_result[2] + "real ratio = %6f" % (float(best_result[0]) / float(best_result[1])))
	#print("max elements = %6d | " % _max_elements + "ratio = %3d | " % _ratio + "movements = %6d " % operation_log.size())

#region Display Table, DISABLED TEMPORARILY
func fill_grid():
	return
	for i in range(max_elements):
		var label_a = Label.new()
		var label_b = Label.new()
		var label_sep = Label.new()
		label_a.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		label_sep.text = " | "
		grid.add_child(label_a)
		grid.add_child(label_sep)
		grid.add_child(label_b)
		labels_a.push_back(label_a)
		labels_b.push_back(label_b)

func update_display():
	return
	for i in range(max_elements):
		if i < stack_a.size():
			labels_a[i].set_text(str(stack_a[i]))
		else:
			labels_a[i].set_text(" --- ")
		if i < stack_b.size():
			labels_b[i].set_text(str(stack_b[i]))
		else:
			labels_b[i].set_text(" --- ")
#endregion
#region Stack Operations
func push(stack : String):
	if (stack == "a"):
		if stack_a.size() >= max_elements:
			return
		stack_a.push_front(stack_b.pop_front())
	else:
		if stack_b.size() >= max_elements:
			return
		stack_b.push_front(stack_a.pop_front())
	update_display()

func pa(repeat : int):
	for i in range(repeat):
		push("a")
		operation_log.push_back("pa")

func pb(repeat : int):
	for i in range(repeat):
		push("b")
		operation_log.push_back("pa")

func swap(stack : String):
	if stack == "a":
		if stack_a.size() > 1:
			stack_a.insert(1, stack_a.pop_front())
	if stack == "b":
		if stack_b.size() > 1:
			stack_b.insert(1, stack_b.pop_front())
	update_display()

func sa(repeat : int):
	for i in range(repeat):
		swap("a")
		operation_log.push_back("sa")

func sb(repeat : int):
	for i in range(repeat):
		swap("b")
		operation_log.push_back("sb")

func ss(repeat : int):
	for i in range(repeat):
		swap("a")
		swap("b")
		operation_log.push_back("ss")

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

func ra(repeat : int):
	for i in range(repeat):
		rotate_stack("a", 1)
		operation_log.push_back("ra")

func rb(repeat : int):
	for i in range(repeat):
		rotate_stack("b", 1)
		operation_log.push_back("rb")

func rr(repeat : int):
	for i in range(repeat):
		rotate_stack("a", 1)
		rotate_stack("b", 1)
		operation_log.push_back("rr")

func rra(repeat : int):
	for i in range(repeat):
		rotate_stack("a", -1)
		operation_log.push_back("rra")

func rrb(repeat : int):
	for i in range(repeat):
		rotate_stack("b", -1)
		operation_log.push_back("rrb")

func rrr(repeat : int):
	for i in range(repeat):
		rotate_stack("a", -1)
		rotate_stack("b", -1)
		operation_log.push_back("rrr")
#endregion
#region The Brains of the operation and Helpers

func fill_stack_a():# on the real problem this doenst exist, we read values from main argv
	var numbers : Array = []
	for i in range(max_elements):
		numbers.push_back(i)
	for i in range(max_elements):
		var random : int = randi_range(0, numbers.size() - 1)
		stack_a.push_back(numbers.pop_at(random))

#first round, look for firs 10 ranks
#if it was with ratio=4, first 5 ranks, elements_pushed=5, for > 3 > 2 > 1
#	5*3 = 15, stops at 15,		5*2, next loop stops at 10
func split_stacks():
	for i in range(1, ratio):#1->3
		var indexes : Array = []
		for k in range(elements_pushed):
			indexes.push_back(stack_a.find(k + (i - 1) * elements_pushed))
		indexes = calculate_rotations(indexes)
		for index in indexes:
			rra(index)#can be optimized by checking stack_b, and using rr, or rrr instead of ra, rra
			pb(1)
	#this is very badly optimized, or not at all

func calculate_rotations(indexes : Array) -> Array:
	var result : Array = []
	indexes.sort()
	result.push_back(indexes[0])
	for i in range(indexes.size() - 1):
		result.push_back(indexes[i + 1] - indexes[i] - 1)
	return result

func sort_a():
	var indexes : Array = []
	for i in range(stack_a.size()):
		indexes.push_back(stack_a[0])
		pb(1)
	indexes.sort()
	indexes.reverse()
	
	for index in indexes:
		var i = stack_b.find(index)
		if i <= stack_b.size() / 2:
			rrb(i)
			pa(1)
		else:
			rb(stack_b.size() - i)
			pa(1)

func sort_b_into_a():
	var indexes : Array = []
	for i in range(elements_pushed):
		indexes.push_back(stack_b[i])
	indexes.sort()
	indexes.reverse()
	
	for index in indexes:
		var i = stack_b.find(index)
		if i <= stack_b.size() / 2:
			rrb(i)
			pa(1)
		else:
			rb(stack_b.size() - i)
			pa(1)

#endregion
#region Input Handling


func check_input():
	for x in ["rra", "rrb", "rrr", "pa", "pb", "sa", "sb", "ss", "ra", "rb", "rr"]:
		if input_queue.length() >= x.length():
			if input_queue.findn(x) != -1:
				input_queue = ""
				operation = x
				call(operation, 1)
				return
	if operation:
		call(operation, 1)

func _input(event):
	if event is InputEventKey:
		if event.is_pressed():
			if not event.is_echo():
				if event.keycode >= KEY_A and event.keycode <= KEY_Z:
					input_queue += OS.get_keycode_string(event.keycode)
	if event.is_action_pressed("ui_accept"):
		check_input()
	if event.is_action_pressed("run"):
		run(500, 10)
#endregion
#region Requirements/Goals

# aim for 100, 200, 300, 400 and 500 operations tests
#required: sort   3 numbers with <=     3 operations
#required: sort   5 numbers with <=    12 operations
#scored:   sort 100 numbers with <=   700 operations   max score
									 #900 operations
									#1100 operations
									#1300 operations
									#1500 operations   min score
#scored:   sort 500 numbers with <=  5500 operations   max score
									#7000 operations
									#8500 operations
								   #10000 operations
								   #11500 operations   min score

#endregion
