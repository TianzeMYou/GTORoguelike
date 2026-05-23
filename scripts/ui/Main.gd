extends Control

const HandScreenScene = preload("res://scenes/ui/HandScreen.tscn")
const ResultScreenScene = preload("res://scenes/ui/ResultScreen.tscn")
const RewardScreenScene = preload("res://scenes/ui/RewardScreen.tscn")
const RunOverScreenScene = preload("res://scenes/ui/RunOverScreen.tscn")

var _current_screen: Control

func _ready() -> void:
	var gs = get_node("/root/GameState")
	gs.start_run()
	_show_hand_screen()

func _clear() -> void:
	if _current_screen:
		_current_screen.queue_free()
		_current_screen = null

func _show_hand_screen() -> void:
	_clear()
	_current_screen = HandScreenScene.instantiate()
	add_child(_current_screen)
	_current_screen.hand_complete.connect(_on_hand_complete)

func _on_hand_complete(result: Object) -> void:
	var gs = get_node("/root/GameState")

	# Apply insurance policy
	var profit = result.profit
	if profit < 0 and gs.has_relic("insurance_policy") and not gs.insurance_used_this_room:
		profit = profit / 2
		gs.insurance_used_this_room = true

	# Apply glass cannon doubling
	if result.glass_cannon_active:
		profit = profit * 2

	gs.bankroll += profit
	gs.ev_score += result.ev

	_clear()
	_current_screen = ResultScreenScene.instantiate()
	add_child(_current_screen)
	_current_screen.show_result(result)
	_current_screen.continue_pressed.connect(_on_result_continue)

func _on_result_continue() -> void:
	var gs = get_node("/root/GameState")

	if gs.is_run_over():
		_show_run_over("bankrupt")
		return

	gs.advance_hand()

	if gs.is_room_clear():
		gs.advance_room()
		if gs.is_run_won():
			_show_run_over("win")
		else:
			_show_reward_screen()
	else:
		_show_hand_screen()

func _show_reward_screen() -> void:
	_clear()
	_current_screen = RewardScreenScene.instantiate()
	add_child(_current_screen)
	_current_screen.relic_chosen.connect(_on_relic_chosen)

func _on_relic_chosen(relic_id: String) -> void:
	if relic_id != "":
		get_node("/root/GameState").add_relic(relic_id)
	_show_hand_screen()

func _show_run_over(reason: String) -> void:
	_clear()
	_current_screen = RunOverScreenScene.instantiate()
	add_child(_current_screen)
	_current_screen.show_result(reason)
	_current_screen.restart_pressed.connect(_on_restart)

func _on_restart() -> void:
	get_node("/root/GameState").start_run()
	_show_hand_screen()
