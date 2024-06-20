extends Node

@onready var path_text_edit: TextEdit = $CanvasLayer/Control/MarginContainer/VBoxContainer/PathTE
@onready var randomize_button: Button = $CanvasLayer/Control/MarginContainer/VBoxContainer/RandomizeButton
@onready var console_rich_text_label: RichTextLabel = $CanvasLayer/Control/MarginContainer/VBoxContainer/PanelContainer/ConsoleRTL
@onready var progress_bar: ProgressBar = $CanvasLayer/Control/MarginContainer/VBoxContainer/ProgressBar

var path_regex: RegEx
var line_in_console: int = 1
var can_randomize: bool = false
var file_names: Array[String] = []
var length: int = -1
var dir: DirAccess
var used_number = []
var rng = RandomNumberGenerator.new()
var regex = RegEx.new()

func _ready() -> void:
	path_regex = RegEx.new()
	path_regex.compile("^(?:[A-Za-z]:)?(?:[\\/\\\\][^\\/\\\\:*?\"<>|]*)+$")
	regex.compile("\\d+. ?")

func _process(_delta: float) -> void:
	if can_randomize:
		if not file_names.is_empty():
			_rename_files()
			var value = progress_bar.get_value() + 1
			progress_bar.set_value(value)
		else:
			can_randomize = false
	else:
		if randomize_button.is_disabled():
			randomize_button.set_disabled(false)

func _get_files() -> void:
	if path_regex.search(path_text_edit.text) == null:
		_print_in_console("Wrong path")
		return
	
	dir = DirAccess.open(path_text_edit.text)	
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			if dir.current_is_dir():
				print("Found directory: " + file_name)
			else:
				file_names.append(file_name)
			file_name = dir.get_next()
		
		length = file_names.size()
		randomize_button.set_disabled(true)
		can_randomize = true
	else:
		print("An error occurred when trying to access the path.")

func _rename_files() -> void:
	var file_name = file_names[0]
	var number = rng.randi_range(1, length)
	
	if used_number.has(number):
		var none = true
		while none:
			number = rng.randi_range(1, length)
			if used_number.has(number):
				continue
			else:
				none = false
	
	var string_number = _normalize_number(number, length)
	var regex_name = regex.sub(file_name, "")
	var new_name = string_number + ". " + regex_name
	DirAccess.rename_absolute(dir.get_current_dir()+ "/" + file_name, dir.get_current_dir()+ "/" + new_name)
	
	_print_file_change(file_name, new_name)
		
	used_number.append(number)
	file_names.remove_at(0)

func _normalize_number(number: int, length2: int) -> String:
	var digits_number_in_number: int = _digits_numbers_in_int(number)
	var digits_number_in_length: int = _digits_numbers_in_int(length2)
	var string_number: String = ""
	
	var i : int = digits_number_in_number
	while i < digits_number_in_length:
		string_number += "0"
		i += 1
	
	string_number += str(number)
	
	return string_number

func _digits_numbers_in_int(number: int) -> int:
	var digit_number: int = 0
	
	if number <= 0:
		return 1
	
	while number > 0:
		digit_number += 1
		number /= 10
		number = floor(number)
	
	return digit_number

func _on_randomize_button_pressed() -> void:
	dir = null
	used_number.clear()
	_get_files()
	progress_bar.set_value(0)
	progress_bar.set_max(length)

func _print_in_console(s: String) -> void:
	if console_rich_text_label.text.is_empty():
		console_rich_text_label.text = "(" + str(line_in_console) + ") " + s
	else:
		console_rich_text_label.text = console_rich_text_label.text + "\n" + "(" + str(line_in_console) + ") " + s
	
	
	line_in_console += 1

func _print_file_change(file_name: String, new_name: String) -> void:
	if console_rich_text_label.text.is_empty():
		console_rich_text_label.text = "(" + str(line_in_console) + ") " + file_name + " -> " + new_name 
	else:
		console_rich_text_label.text = console_rich_text_label.text + "\n" + "(" + str(line_in_console) + ") " + file_name + " -> "  + new_name 
	
	line_in_console += 1
