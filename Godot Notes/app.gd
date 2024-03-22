extends Node

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
			if node.get_node("VBoxContainer/TextEdit").text == "" and node.get_node("VBoxContainer/HBoxContainer/LineEdit").text == "":
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
			if node.get_node("VBoxContainer/TextEdit").text == "" and node.get_node("VBoxContainer/HBoxContainer/LineEdit").text == "" and node.child:
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
			save_note.text = node.get_node("VBoxContainer/TextEdit").text
			save_note.focused = node.get_node("VBoxContainer/HBoxContainer/FocusButton").button_pressed
			save_note.child = node.child
			new_save.save_notes.append(save_note)
		ResourceSaver.save(new_save,"user://notes.tres")
	#var save_nodes = get_tree().get_nodes_in_group("Persist")
	#for node in save_nodes:
	#notes_save()
	
	pass


func load_notes():
	var saveLoad = ResourceLoader.load("user://notes.tres")
	#var root_window = $Window
	if not saveLoad:
		print("Load error!")
	else:
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
					new_note.get_node("VBoxContainer/TextEdit").text = noteI.text
					new_note.get_node("VBoxContainer/HBoxContainer/FocusButton").button_pressed = noteI.focused
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
						new_note.get_node("VBoxContainer/TextEdit").text = noteI.text
						new_note.get_node("VBoxContainer/HBoxContainer/FocusButton").button_pressed = noteI.focused
						new_note.child = noteI.child
						new_note.initial_position = Window.WINDOW_INITIAL_POSITION_ABSOLUTE
						new_note.position = noteI.pos
						root_window.add_child(new_note)
						noteNum += 1
			pass
	print(noteNum-1, " Notes loaded:")
	pass

### https://www.reddit.com/r/godot/comments/17ky03k/behold_a_function_to_save_an_entire_scene_all_its/
### by codynosaur and triple-cerberus
## KN- Removed midrun, replaced with notes
#var notes_save_array : Dictionary 
#var NOTES_SAVE_FILE = "user://notes.save" #(CHANGED)I assume you are using this from the docs.
#func notes_save(): 
	#notes_save_array.clear() 
	#var root_level = get_node("/root/App") 
	#var map_node = get_node("/root/App/Window") 
	#var save_object_nodes = get_tree().get_nodes_in_group("Persist") 
	##var save_ui_nodes = get_tree().get_nodes_in_group("PersistUI")
	#for save_node in save_object_nodes:
		#if save_node.is_inside_tree() == false:
			#save_node.queue_free()
		#else:
			##I'm setting "map_node" as the owner of all of these nodes I want to persist, because this is the top of the tree that I'm going to be converting into my packed scene
#
			#if save_node != map_node:
				#save_node.owner = map_node
#
					##Now we're going to iterate through all the nodes I've said need to persist, and check if any of them have scripts attached. If they do, then we want to copy the variables inside of that script - not just the exported ones - into a dictionary we can save and load later
#
		#var node_script: GDScript = save_node.get_script()
		#if node_script != null:
			#var node_variables = node_script.get_script_property_list()
			#var save_name = "path_" + str(save_node.get_path())
			#notes_save_array[save_name] = {}
			#
			##I've used the node path as a way to generate unique keys for the dictionary I'm storing all this data in, and a way to know how to get it back out of the dictionary when we load it all
			#
			#for variable in node_variables:
				#var variable_name = str(variable.name)
				#
									##We're going to tell it not to save any variables that are nodes themselves - this avoids recursion within the dictionary, which breaks the var2str method we're going to use, and also allows the nodes to correctly set up their various onready var references to other nodes when they're reinstantiated upon load
									##I don't have any so this is not an issue for me, keeping it anyway
				#if save_node.get(variable_name) is Node:
					#pass
				#else:
					#notes_save_array[save_name][variable_name] = var_to_str(save_node.get(variable_name))
##Okay, now we've got our big chunky dictionary containing both the global variables and the (non-node) variables of every single node we intend to pack up that has a script attached to it, we're going to save it to a file
	#var file = FileAccess.open(NOTES_SAVE_FILE, FileAccess.WRITE)
	#file.store_var(notes_save_array)
	#file.close()
	##Next is just to pack up the node at the top of it all that will retain things for us like position, visibility, etc, of our nodes, and save that as well, creating a snapshot of our scene
	#var packed_scene = PackedScene.new()
	#packed_scene.pack(map_node)
	#ResourceSaver.save(packed_scene, "user://saved_notes.tscn") #They flipped these in Godot 4??
#
#func load_notes():
	##The first part of the loading is pretty standard, we open up our save file as long as there's one to open, and we update the global game data script's global variables with what we saved previously
	#if not FileAccess.file_exists(NOTES_SAVE_FILE):
		#return
	#var save_game = FileAccess.open(NOTES_SAVE_FILE, FileAccess.READ)
	#notes_save_array = save_game.get_var()
##removed the global data as I do not have that
#
## Now we load the PackedScene resource, creating, if you will, the skeleton of the scene we created a snapshot of, and laying it out on our scene tree first
#
	#var packed_scene = load("user://saved_notes.tscn")
	## Instance the scene
	#var loaded_scene = packed_scene.instantiate()
	#get_node("/root/App").add_child(loaded_scene)
	##And now that we've got the skeleton, we're going to flesh it all out with those many custom variables we wanted to stay the same. We're going to open up their various scripts, referencing their dictionary entries by using their node path to determine what the key is in the dictionary.
	#var save_object_nodes = get_tree().get_nodes_in_group("PersistObject")
#
	#for save_node in save_object_nodes:
#
		#var node_script: GDScript = save_node.get_script()
		#if node_script != null:
			#var node_name = "path_" + str(save_node.get_path())
			#var node_data = notes_save_array[node_name]
			#for variable in node_data.keys():
				#save_node.set(variable, str_to_var(node_data[variable]))
	#$Window.queue_free()
##And we're done loading the script! If anything loads wonky, make sure you added all the nodes you wanted to the group "Persist", or whatever label you're using, and check that none of your re-instanced nodes are doing something in their ready function that you don't want them to do if they're just being loaded from a save file
