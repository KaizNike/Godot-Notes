extends HSplitContainer

var timer = false

func _input(event: InputEvent) -> void:
	#print(event)
	if event.is_action_pressed("ui_text_submit"):
		print("testing time")
		
		$TimeBox/Timer.wait_time = $TimeBox.value
		$TimeBox/Timer.start()
		if Globals.speech:
			var voices = DisplayServer.tts_get_voices()
			DisplayServer.tts_stop()
			DisplayServer.tts_speak("Start! " + str($TimeBox.value) + " seconds! ",voices[0].id)
		timer = true
	pass # Replace with function body.

#func _on_time_box_gui_input(event: InputEvent) -> void:
	##print(event)
	#if event.is_action_pressed("ui_text_submit"):
		#print("testing time")
		#$TimeBox/Timer.wait_time = $TimeBox.value
		#$TimeBox/Timer.start()
		#if Globals.speech:
			#var voices = DisplayServer.tts_get_voices()
			#DisplayServer.tts_stop()
			#DisplayServer.tts_speak("Start! " + str($TimeBox.value) + " seconds! ",voices[0].id)
		#timer = true
 ## Replace with function body.
	
func _process(delta: float) -> void:
	if timer:
		$TimeBox.set_value_no_signal($TimeBox/Timer.time_left)
	#if $TimeBox.value <= 0.0:
		#$CheckBox.toggle_mode = true
		#timer = false
		#if Globals.speech:
			#var voices = DisplayServer.tts_get_voices()
			#DisplayServer.tts_stop()
			#DisplayServer.tts_speak($CheckEditor.text + " Finished!",voices[0].id)


func _on_timer_timeout() -> void:
	if timer:
		$CheckBox.button_pressed = true
		timer = false
		if Globals.speech:
			var voices = DisplayServer.tts_get_voices()
			DisplayServer.tts_stop()
			DisplayServer.tts_speak($CheckEditor.text + " Finished!",voices[0].id)
		
		#$TimeBox.value -= 1.0
		#print($TimeBox.value, " left.")
	pass # Replace with function body.
