extends HBoxContainer

var started := false


func _on_start_reset_pressed() -> void:
	started = !started
	if started:
		var time = ""
		time = str($Time.text)
		if !time:
			time = $Time.placeholder_text
		var split = time.split(" ",false)
		if !split or split.size() != 2:
			if Globals.speech:
				var voices = DisplayServer.tts_get_voices()
				DisplayServer.tts_speak("Enter time like 5 minutes, a number and then English text for time.", voices[0].id,100)
			return
		time = int(split[0])
		var timeMod = split[1]
		var extras := ""
		match timeMod:
			"second":
				pass
			"minute":
				time *= 60
			"hour":
				time *= 60 * 60
			"day":
				time *= 60 * 60 * 24
			"week":
				time *= 60 * 60 * 24 * 7
			"month":
				extras += " Month defaults to 30 days. "
				time *= 60 * 60 * 24 * 30
			"year":
				extras += " Year defaults to 365 days. "
				time *= 60 * 60 * 24 * 365
			"decade":
				extras += " Decade defaults to 10 times 365 day years, though that is inaccurate. "
				time *= 60 * 60 * 24 * 365 * 10
			"century":
				extras += " Century defaults to 100 times 365 day years, though that is inaccurate. "
				time *= 60 * 60 * 24 * 365 * 100
			"millenia":
				extras += " Millenia defaults to 1000 times 365 day years, though that is inaccurate. "
				time *= 60 * 60 * 24 * 365 * 1000
		$ProgressBar.max_value = int(time)
		$ProgressBar.value = int(time)
		if Globals.speech:
			var voices = DisplayServer.tts_get_voices()
			DisplayServer.tts_speak("Timer started for " + str($Time.text) + " , will alert you when done." + extras, voices[0].id,100)
		print("Timer started for: ", str($Time.text), " and ", str(time))
	pass # Replace with function body.


func _process(delta: float) -> void:
	if $ProgressBar.value == $ProgressBar.min_value:
		started = false
		var voices = DisplayServer.tts_get_voices()
		DisplayServer.tts_speak("Timer finished!", voices[0].id, 95)
	if started:
		$ProgressBar.value -= delta
		print($ProgressBar.value)


func time_since():
	
	pass
