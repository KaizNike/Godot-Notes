extends Window

var child = false

@export var checkList = PackedScene.new()
var checkItems = 0

var window_name = ""

func _ready():
	#$Popup.popup()
	#$PopupTimer.start()
	if not child:
		#$VBoxContainer/HBoxContainer/TitleEditor.theme_override_colors.font_color = Color("#ffe100")
		#$VBoxContainer/HBoxContainer/TitleEditor.theme_override_colors.font_placeholder_color = Color("#ffe100")
		$VBoxContainer/HBoxContainer/TitleEditor.add_theme_color_override("font_color", Color("#ffe100"))
		$VBoxContainer/HBoxContainer/TitleEditor.add_theme_color_override("font_placeholder_color", Color("#ffe100"))
	#if get_parent().name == "App" and has_focus():
		#if self == get_parent().root_window:
			#_on_focus_entered()
	$VBoxContainer/HBoxContainer/TitleEditor.grab_focus()

func _on_focus_button_toggled(toggled_on):
	if toggled_on:
		transient = false
		always_on_top = true
	else:
		#if child:
			#transient = true
		always_on_top = false


func _on_add_button_pressed():
	Globals.emit_signal("add_note")


func _on_close_requested():
	if child:
		remove_from_group("Persist")
		queue_free()
	else:
		get_parent().save_notes()
		pass
		get_tree().quit(2)


func _on_check_button_pressed():
	var nodes = $VBoxContainer/ScrollContainer/VBoxContainer2.get_children()
	for node in nodes:
		if node.is_in_group("checkListItem"):
			if node.get_node("CheckBox").button_pressed:
				node.queue_free()
	var new = checkList.instantiate()
	checkItems += 1
	new.get_node("CheckEditor").tooltip_text = "Checkitem #" + str(checkItems)
	var voices = DisplayServer.tts_get_voices()
	DisplayServer.tts_stop()
	DisplayServer.tts_speak("Check item #" + str(checkItems) + " added.", voices[0].id,100)
	new.get_node("CheckEditor").placeholder_text = str(checkItems) + ":"
	$VBoxContainer/ScrollContainer/VBoxContainer2.add_child(new)
	
func _input(event):
	if event.is_action_pressed("save"):
		print("Inner save.")
		var parent = get_parent()
		if parent is Window:
			parent = parent.get_parent()
		parent.save_notes()
		$Popup.popup()
		$PopupTimer.start()
		print("Saved!")
	if event.is_action_pressed("help"):
		var voices = DisplayServer.tts_get_voices()
		DisplayServer.tts_speak("Reminders. Hold escape to quit. Alt + Tab to switch between notes. Ctrl + S to save a note. Ctrl + Tab to switch within a note. Alt + F4 to clean up a window, but on main window closes. Press F1 to hear this again.", voices[0].id,100)



func add_check_note(text):
	var new = checkList.instantiate()
	checkItems += 1
	new.get_node("CheckEditor").tooltip_text = "Checkitem #" + str(checkItems)
	new.get_node("CheckEditor").placeholder_text = str(checkItems) + ":"
	new.get_node("CheckEditor").text = text
	$VBoxContainer/ScrollContainer/VBoxContainer2.add_child(new)


func _on_popup_timer_timeout():
	$Popup.hide()
	pass # Replace with function body.


func _on_gui_focus_changed(node):
	#var text = $VBoxContainer/HBoxContainer/TitleEditor.text
	#if not text:
		#text = $VBoxContainer/HBoxContainer/TitleEditor.placeholder_text
	var text = ""
	if node is TextEdit or node is LineEdit:
		text = node.text
		if not text:
			text = node.placeholder_text
	var voices = DisplayServer.tts_get_voices()
	text = str(node.name) + " focused. " + text
	DisplayServer.tts_stop()
	DisplayServer.tts_speak(text,voices[0].id,100)
	pass # Replace with function body.


func _on_focus_entered():
	var text = $VBoxContainer/HBoxContainer/TitleEditor.text
	if not text:
		text = "Empty titled note " + $VBoxContainer/HBoxContainer/TitleEditor.placeholder_text
	var voices = DisplayServer.tts_get_voices()
	DisplayServer.tts_speak(text,voices[0].id,100)
	$VBoxContainer/HBoxContainer/TitleEditor.grab_focus()
	text = "Title bar focused."
	DisplayServer.tts_speak(text,voices[0].id,100)
	pass # Replace with function body.


func _on_title_editor_text_changed(new_text):
	self.title = window_name + ": " + new_text
	pass # Replace with function body.
