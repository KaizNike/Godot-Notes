extends Window

var child = false


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
