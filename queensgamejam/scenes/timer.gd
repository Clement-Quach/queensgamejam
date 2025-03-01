extends Control

var totalTimeInSecs : int = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Timer.start()




# Called every frame. 'delta' is 
func _on_timer_timeout() -> void:
	totalTimeInSecs += 1
	var m = int(totalTimeInSecs / 60.0)
	var s  = totalTimeInSecs - m *60
	$Label.text = '%02d:%02d' % [m, s]
