class_name TimeTracker extends Resource

var startTime: float = 0.0
var endTime: float = 0.0
var resultTime: float = 0.0
var running: bool = false

func start() -> void:
	startTime = Time.get_ticks_usec()
	running = true
	
func stop() -> float:
	running = false
	endTime = Time.get_ticks_usec()
	resultTime = (endTime-startTime) / 1000000.0
	return resultTime

func getElapsedTime() -> float:
	return (Time.get_ticks_usec()-startTime) / 1000000.0
	
func reset() -> void:
	startTime = 0.0
	endTime = 0.0
	resultTime = 0.0
	running = false

func isRunning() -> bool:
	return running

func getResult() -> float:
	return resultTime
