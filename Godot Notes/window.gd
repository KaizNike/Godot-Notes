extends Window

var child = false

@export var checkList = PackedScene.new()
var checkItems = 0

func _ready():
	if not child:
		#$VBoxContainer/HBoxContainer/LineEdit.theme_override_colors.font_color = Color("#ffe100")
		#$VBoxContainer/HBoxContainer/LineEdit.theme_override_colors.font_placeholder_color = Color("#ffe100")
		$VBoxContainer/HBoxContainer/LineEdit.add_theme_color_override("font_color", Color("#ffe100"))
		$VBoxContainer/HBoxContainer/LineEdit.add_theme_color_override("font_placeholder_color", Color("#ffe100"))

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
	new.get_node("LineEdit").placeholder_text = str(checkItems) + ":"
	$VBoxContainer/ScrollContainer/VBoxContainer2.add_child(new)


func add_check_note(text):
	var new = checkList.instantiate()
	checkItems += 1
	new.get_node("LineEdit").placeholder_text = str(checkItems) + ":"
	new.get_node("LineEdit").text = text
	$VBoxContainer/ScrollContainer/VBoxContainer2.add_child(new)
