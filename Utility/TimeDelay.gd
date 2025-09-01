class_name TimeDelay extends Resource

var startTime: float = 0.0

func _init():
	reset()

func reset():
	startTime = Time.get_ticks_msec()
	
func hasPassed(amount: float, resetOnPass: bool=false):
	var returnVar: bool = (Time.get_ticks_msec() - startTime) / 1000.0  >= amount
	if returnVar and resetOnPass:
		reset()
	return returnVar
