extends Node

var path_text_edit: TextEdit
var randomize_button: Button
var console_text_edit: TextEdit
var path_regex: RegEx
var line_in_console: int = 1

func _ready() -> void:
	path_text_edit = $CanvasLayer/Control/PathTE
	randomize_button = $CanvasLayer/Control/RandomizeButton
	console_text_edit = $CanvasLayer/Control/ConsoleTE
	path_regex = RegEx.new()
	path_regex.compile("^(?:[A-Za-z]:)?(?:[\\/\\\\][^\\/\\\\:*?\"<>|]*)+$")

func _rename_files() -> void:
	if path_regex.search(path_text_edit.text) == null:
		_print_in_console("Wrong path")
		return
	
	var dir = DirAccess.open(path_text_edit.text)
	var rng = RandomNumberGenerator.new()
	var regex = RegEx.new()
	regex.compile("\\d+. ?")
	
	if dir:
		var length = dir.get_files().size()
		var used_number = []
		
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			if dir.current_is_dir():
				print("Found directory: " + file_name)
			else:
				var number = rng.randi_range(1, length)
				if used_number.has(number):
					var none = true
					while none:
						number = rng.randi_range(1, length)
						if used_number.has(number):
							continue
						else:
							none = false
							
				
				
				var regex_name = regex.sub(file_name, "")
				var new_name = str(number) + ". " + regex_name
				dir.rename_absolute(dir.get_current_dir()+ "/" + file_name, dir.get_current_dir()+ "/" + new_name)
				
				_print_file_change(file_name, new_name)
				
				used_number.append(number)
			file_name = dir.get_next()
	
	else:
		print("An error occurred when trying to access the path.")

func _on_randomize_button_pressed() -> void:
	_rename_files()

func _print_in_console(str: String) -> void:
	if console_text_edit.text.is_empty():
		console_text_edit.text = "(" + str(line_in_console) + ")" + str
	else:
		console_text_edit.text = console_text_edit.text + "\n" + "(" + str(line_in_console) + ") " + str
	
	line_in_console += 1

func _print_file_change(file_name: String, new_name: String) -> void:
	if console_text_edit.text.is_empty():
		console_text_edit.text = "(" + str(line_in_console) + ")" + file_name + " -> " + new_name 
	else:
		console_text_edit.text = console_text_edit.text + "\n" + "(" + str(line_in_console) + ") " + file_name + " -> "  + new_name 
	
	line_in_console += 1
