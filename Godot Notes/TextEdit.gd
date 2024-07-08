extends TextEdit

var currentWord = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _input(event):
	print(get_caret_column())
	#if event is InputEventKey:
		#currentWord = get_word_under_caret()
	if event.is_action_pressed("space"):
		var voices = DisplayServer.tts_get_voices()
		DisplayServer.tts_stop()
		var col = get_caret_column()
		set_caret_column(col-2)
		DisplayServer.tts_speak(get_word_under_caret(), voices[0].id,100)
		set_caret_column(col)
		pass
	if Input.get_vector("ui_left","ui_right","ui_down","ui_up"):
		if has_selection():
			var voices = DisplayServer.tts_get_voices()
			DisplayServer.tts_stop()
			DisplayServer.tts_speak(get_selected_text(), voices[0].id,100)
		else:
			var voices = DisplayServer.tts_get_voices()
			DisplayServer.tts_stop()
			DisplayServer.tts_speak(get_word_under_caret(), voices[0].id,100)
			currentWord = get_word_under_caret()
