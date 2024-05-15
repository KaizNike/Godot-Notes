extends Node
# Note Use window to create new checklist items
@export var note := PackedScene.new()
#@export var save := Script
@onready var save = preload("res://Save.gd")
var root_window
var noteNum = 2


func _ready():
	root_window = $Window
	Globals.add_note.connect(add_note)
	#get_tree().set_auto_accept_quit(false)
	load_notes()


func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		var nodes = get_tree().get_nodes_in_group("Persist")
		for node in nodes:
			if node.get_node("VBoxContainer/ScrollContainer/VBoxContainer2/TextEdit").text == "" and node.get_node("VBoxContainer/HBoxContainer/LineEdit").text == "":
				node.remove_from_group("Persist")
		nodes = get_tree().get_nodes_in_group("Persist")
		if nodes.size() > 0:
			save_notes()
		get_tree().quit(1)

func add_note():
	var new_note = note.instantiate()
	new_note.child = true
	#new_note.transient = true
	new_note.title = "Godot Notes! Note #" + str(noteNum)
	new_note.get_node("VBoxContainer/HBoxContainer/LineEdit").placeholder_text = "Note #" + str(noteNum)
	root_window.add_child(new_note)
	noteNum += 1
	pass


func save_notes():
	#var save = FileAccess.open("user://notes.save",FileAccess.WRITE)
	#var new_save = save.instantiate()
	
	var nodes = get_tree().get_nodes_in_group("Persist")
	for node in nodes:
		if node is Window:
			var checklists = node.get_node("VBoxContainer/ScrollContainer/VBoxContainer2").get_children()
			var checklistCheck = false
			for item in checklists:
				if item.is_in_group("checkListItem"):
					if item.get_node("LineEdit").text and not item.get_node("CheckBox").button_pressed:
						checklistCheck = true
						break
			if node.get_node("VBoxContainer/ScrollContainer/VBoxContainer2/TextEdit").text == "" and node.get_node("VBoxContainer/HBoxContainer/LineEdit").text == "" and node.child and not checklistCheck:
				node.remove_from_group("Persist")
				var children = node.get_children()
				for child in children:
					child.remove_from_group("Persist")
	nodes = get_tree().get_nodes_in_group("Persist")
	if nodes.size() > 0:
		var new_save = save.new()
		for node in nodes:
			var save_note = new_save.note.duplicate(true)
			node.initial_position = Window.WINDOW_INITIAL_POSITION_ABSOLUTE
			save_note.pos = node.position
			save_note.title = node.get_node("VBoxContainer/HBoxContainer/LineEdit").text
			save_note.text = node.get_node("VBoxContainer/ScrollContainer/VBoxContainer2/TextEdit").text
			save_note.focused = node.get_node("VBoxContainer/HBoxContainer/FocusButton").button_pressed
			save_note.child = node.child
			var checklists = node.get_node("VBoxContainer/ScrollContainer/VBoxContainer2").get_children()
			for item in checklists:
				if item.is_in_group("checkListItem"):
					if item.get_node("LineEdit").text and not item.get_node("CheckBox").button_pressed:
						save_note.checkboxes.append(item.get_node("LineEdit").text)
			new_save.save_notes.append(save_note)
		ResourceSaver.save(new_save,"user://notes.tres")
	#var save_nodes = get_tree().get_nodes_in_group("Persist")
	#for node in save_nodes:
	#notes_save()
	
	pass


func load_notes():
	var compatibility = ""
	var saveLoad = ResourceLoader.load("user://notes.tres")
	#var root_window = $Window
	if not saveLoad:
		print("Load error!")
	else:
		var versionCheck = saveLoad.version_iteration
		#VERSION CHECK
		if not versionCheck:
			compatibility = "V1"
		var notes = saveLoad.save_notes.duplicate(true)
		if not notes:
			print("No notes!")
		else:
#Iterate over notes, check first if child then move to screen
			for noteI in notes:
				if noteI.child == false:
					root_window.queue_free()
					noteNum = 1
					var new_note = note.instantiate()
					#new_note.child = true
					#new_note.transient = true
					new_note.title = "Godot Notes! Main Note"
					new_note.get_node("VBoxContainer/HBoxContainer/LineEdit").text = noteI.title
					new_note.get_node("VBoxContainer/HBoxContainer/LineEdit").placeholder_text = "First Note"
					new_note.get_node("VBoxContainer/ScrollContainer/VBoxContainer2/TextEdit").text = noteI.text
					new_note.get_node("VBoxContainer/HBoxContainer/FocusButton").button_pressed = noteI.focused
					if not compatibility == "V1":
						for item in noteI.checkboxes:
							new_note.add_check_note(item)
					new_note.initial_position = Window.WINDOW_INITIAL_POSITION_ABSOLUTE
					new_note.position = noteI.pos
					add_child(new_note)
					root_window = new_note
					noteNum += 1
			for noteI in notes:
				if noteI.child == true:
						#root_window.queue_free()
						#noteNum = 1
						var new_note = note.instantiate()
						#new_note.child = true
						#new_note.transient = true
						new_note.title = "Godot Notes! Note #" + str(noteNum) 
						new_note.get_node("VBoxContainer/HBoxContainer/LineEdit").text = noteI.title
						new_note.get_node("VBoxContainer/HBoxContainer/LineEdit").placeholder_text = "Note #" + str(noteNum)
						new_note.get_node("VBoxContainer/ScrollContainer/VBoxContainer2/TextEdit").text = noteI.text
						new_note.get_node("VBoxContainer/HBoxContainer/FocusButton").button_pressed = noteI.focused
						if not compatibility == "V1":
							for item in noteI.checkboxes:
								new_note.add_check_note(item)
						new_note.child = noteI.child
						new_note.initial_position = Window.WINDOW_INITIAL_POSITION_ABSOLUTE
						new_note.position = noteI.pos
						root_window.add_child(new_note)
						noteNum += 1
			pass
	print(noteNum-1, " Notes loaded:")
	pass
