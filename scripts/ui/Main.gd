extends Control

const HandScreen = preload("res://scenes/ui/HandScreen.tscn")
const ResultScreen = preload("res://scenes/ui/ResultScreen.tscn")

var _hand_screen: Control
var _result_screen: Control

func _ready() -> void:
	_show_hand_screen()

func _show_hand_screen() -> void:
	if _result_screen:
		_result_screen.queue_free()
	_hand_screen = HandScreen.instantiate()
	add_child(_hand_screen)
	_hand_screen.hand_complete.connect(_on_hand_complete)

func _on_hand_complete(result: Object) -> void:
	_hand_screen.queue_free()
	_result_screen = ResultScreen.instantiate()
	add_child(_result_screen)
	_result_screen.show_result(result)
	_result_screen.continue_pressed.connect(_show_hand_screen)
