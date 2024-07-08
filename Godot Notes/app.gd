extends Node
# Note Use window to create new checklist items
@export var note := PackedScene.new()
#@export var save := Script
@onready var save = preload("res://Save.gd")
var root_window
var noteNum = 2

var quitting = false


func _ready():
	$QuitPopup.unfocusable = true
	root_window = $Window
	Globals.add_note.connect(add_note)
	#get_tree().set_auto_accept_quit(false)
	load_notes()
	if Globals.speech:
		var voices = DisplayServer.tts_get_voices()
		DisplayServer.tts_stop()
		DisplayServer.tts_speak("Welcome to Godot Notes Accessible. Hold escape to quit. Alt + Tab to switch between notes. Ctrl + S to save a note. Ctrl + Tab to switch within a note. Alt + F4 to clean up a window, but on main window closes. Press F1 to hear this again. " + str(noteNum-1) + " notes loaded." + "This will work strangely with screenreaders as support is not native, so user beware!", voices[0].id,100)
	else:
		var voices = DisplayServer.tts_get_voices()
		DisplayServer.tts_stop()
		DisplayServer.tts_speak("F2 to enable speech.", voices[0].id,100)

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		var nodes = get_tree().get_nodes_in_group("Persist")
		for node in nodes:
			if node.get_node("VBoxContainer/ScrollContainer/VBoxContainer2/TextEdit").text == "" and node.get_node("VBoxContainer/HBoxContainer/TitleEditor").text == "":
				node.remove_from_group("Persist")
		nodes = get_tree().get_nodes_in_group("Persist")
		if nodes.size() > 0:
			save_notes()
		get_tree().quit(1)

func _input(event):
	#print(quitting)
	#if event.is_action_released("quit") and quitting:
		#quitting = false
		#print("STEP2")
	#if event.is_action_pressed("quit") and not quitting:
		#$QuitPopup.popup()
		#print("STEP1")
		#quitting = true
	if event.is_action_pressed("save"):
		print("save started!")
		save_notes()
		root_window.get_node("Popup").show()
		root_window.get_node("PopupTimer").start()
	if event.is_action_pressed("help") and Globals.speech:
		var voices = DisplayServer.tts_get_voices()
		DisplayServer.tts_speak("Reminders. Hold escape to quit. Alt + Tab to switch between notes. Ctrl + S to save a note. Ctrl + Tab to switch within a note. Alt + F4 to clean up a window, but on main window closes. Press F1 to hear this again.", voices[0].id,100)

		


func _physics_process(delta):
	#print(Input.is_action_pressed("ui_cancel"))
	if Input.is_action_pressed("ui_cancel"):
		if not quitting:
			quitting = true
			$QuitPopup.show()
			if Globals.speech:
				var voices = DisplayServer.tts_get_voices()
				DisplayServer.tts_stop()
				DisplayServer.tts_speak("Quitting. Holding escape.", voices[0].id,100)
	if quitting:
		#root_window.grab_focus()
		$QuitPopup/PanelContainer/VSplitContainer/QuitProgress.value += delta
	else:
		$QuitPopup/PanelContainer/VSplitContainer/QuitProgress.value = 0
		$QuitPopup.hide()
	if not Input.is_action_pressed("ui_cancel") and quitting:
		quitting = false
		if Globals.speech:
			var voices = DisplayServer.tts_get_voices()
			DisplayServer.tts_stop()
			DisplayServer.tts_speak("Quit cancelled.", voices[0].id,100)
			


#func is_screen_reader_active():
	#return DisplayServer.get_accessibility()

func add_note():
	var new_note = note.instantiate()
	new_note.child = true
	#new_note.transient = true
	new_note.title = "Godot Notes! Note #" + str(noteNum)
	new_note.window_name = "Godot Notes! Note #" + str(noteNum)
	new_note.get_node("VBoxContainer/HBoxContainer/TitleEditor").placeholder_text = "Note #" + str(noteNum)
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
					if item.get_node("CheckEditor").text and not item.get_node("CheckBox").button_pressed:
						checklistCheck = true
						break
			if node.get_node("VBoxContainer/ScrollContainer/VBoxContainer2/TextEdit").text == "" and node.get_node("VBoxContainer/HBoxContainer/TitleEditor").text == "" and node.child and not checklistCheck:
				node.remove_from_group("Persist")
				var children = node.get_children()
				for child in children:
					child.remove_from_group("Persist")
	nodes = get_tree().get_nodes_in_group("Persist")
	if nodes.size() > 0:
		var new_save = save.new()
		new_save.speech = Globals.speech
		for node in nodes:
			var save_note = new_save.note.duplicate(true)
			node.initial_position = Window.WINDOW_INITIAL_POSITION_ABSOLUTE
			save_note.pos = node.position
			save_note.size = node.size
			save_note.title = node.get_node("VBoxContainer/HBoxContainer/TitleEditor").text
			save_note.text = node.get_node("VBoxContainer/ScrollContainer/VBoxContainer2/TextEdit").text
			save_note.focused = node.get_node("VBoxContainer/HBoxContainer/FocusButton").button_pressed
			save_note.child = node.child
			var checklists = node.get_node("VBoxContainer/ScrollContainer/VBoxContainer2").get_children()
			for item in checklists:
				if item.is_in_group("checkListItem"):
					if item.get_node("CheckEditor").text and not item.get_node("CheckBox").button_pressed:
						save_note.checkboxes.append(item.get_node("CheckEditor").text)
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
		if versionCheck >= 4:
			Globals.speech = saveLoad.speech
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
					new_note.title = "Godot Notes! Main Note" + ": " + noteI.title
					new_note.window_name = "Godot Notes! Main Note"
					new_note.get_node("VBoxContainer/HBoxContainer/TitleEditor").text = noteI.title
					new_note.get_node("VBoxContainer/HBoxContainer/TitleEditor").placeholder_text = "First Note"
					new_note.get_node("VBoxContainer/ScrollContainer/VBoxContainer2/TextEdit").text = noteI.text
					new_note.get_node("VBoxContainer/HBoxContainer/FocusButton").button_pressed = noteI.focused
					if not compatibility == "V1":
						for item in noteI.checkboxes:
							new_note.add_check_note(item)
					if not compatibility == "V1" and versionCheck >= 3:
						new_note.size = noteI.size
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
						new_note.title = "Godot Notes! Note #" + str(noteNum) + ": " + noteI.title 
						new_note.window_name = "Godot Notes! Note #" + str(noteNum)
						new_note.get_node("VBoxContainer/HBoxContainer/TitleEditor").text = noteI.title
						new_note.get_node("VBoxContainer/HBoxContainer/TitleEditor").placeholder_text = "Note #" + str(noteNum)
						new_note.get_node("VBoxContainer/ScrollContainer/VBoxContainer2/TextEdit").text = noteI.text
						new_note.get_node("VBoxContainer/HBoxContainer/FocusButton").button_pressed = noteI.focused
						if not compatibility == "V1":
							for item in noteI.checkboxes:
								new_note.add_check_note(item)
						if not compatibility == "V1" and versionCheck >= 3:
							new_note.size = noteI.size
						new_note.child = noteI.child
						new_note.initial_position = Window.WINDOW_INITIAL_POSITION_ABSOLUTE
						new_note.position = noteI.pos
						root_window.add_child(new_note)
						noteNum += 1
			pass
	print(noteNum-1, " Notes loaded:")
	pass


func _on_progress_bar_value_changed(value):
	print(value)
	if value == $QuitPopup/PanelContainer/VSplitContainer/QuitProgress.max_value:
		save_notes()
		get_tree().quit(3)
