extends Node

signal hand_started(spot: Dictionary)
signal enemy_responding(call_pct: float, fold_pct: float, roll: int)
signal hand_resolved(result: Object)

var _current_spot: Dictionary

func start_hand(spot: Dictionary) -> void:
	_current_spot = spot
	emit_signal("hand_started", spot)

func player_action(action: String, sizing: float = 0.0) -> void:
	match action:
		"fold":   _resolve_fold()
		"check":  _resolve_check()
		"call":   _resolve_call()
		"bet":    _resolve_bet(sizing)
		"raise":  _resolve_bet(sizing)  # raise uses same bet resolution

func _resolve_fold() -> void:
	var result = HandResult.new()
	result.action_taken = "fold"
	result.profit = -_current_spot.get("amount_to_call", 0)
	result.ev = _current_spot.get("ev_fold", -5)
	emit_signal("hand_resolved", result)

func _resolve_check() -> void:
	var result = HandResult.new()
	result.action_taken = "check"
	result.profit = 0
	result.ev = _current_spot.get("ev_check", -8)
	emit_signal("hand_resolved", result)

func _resolve_call() -> void:
	var result = HandResult.new()
	result.action_taken = "call"
	result.profit = _current_spot.get("call_profit", 0)
	result.ev = _current_spot.get("ev_call", 0)
	emit_signal("hand_resolved", result)

func _resolve_bet(sizing: float) -> void:
	var enemy_freqs = _calc_enemy_frequencies(sizing)
	var roll = randi() % 100
	var enemy_calls = roll < enemy_freqs.call_pct
	emit_signal("enemy_responding", enemy_freqs.call_pct, enemy_freqs.fold_pct, roll)

	var result = HandResult.new()
	result.action_taken = "bet"
	result.bet_sizing = sizing
	result.enemy_called = enemy_calls
	result.enemy_call_pct = enemy_freqs.call_pct
	result.enemy_fold_pct = enemy_freqs.fold_pct
	result.roll = roll

	if enemy_calls:
		result.profit = _current_spot.get("bet_called_profit", _current_spot.get("raise_called_profit", -int(sizing)))
		result.ev = _current_spot.get("ev_bet_called", _current_spot.get("ev_raise_called", 0))
	else:
		result.profit = _current_spot.get("pot", 0)
		result.ev = _current_spot.get("ev_bet_fold", _current_spot.get("ev_raise_fold", sizing))

	emit_signal("hand_resolved", result)

func _calc_enemy_frequencies(sizing: float) -> Dictionary:
	var base_call = _current_spot.get("base_call_pct", 50.0)
	var base_fold = 100.0 - base_call

	var gs = get_node("/root/GameState")
	base_fold += gs.table_image["fear"] * 3.0
	base_call += gs.table_image["suspicion"] * 3.0

	var enemy_trait = _current_spot.get("enemy_trait", {})
	base_call += enemy_trait.get("call_mod", 0.0)
	base_fold += enemy_trait.get("fold_mod", 0.0)

	if gs.has_relic("fear_aura"):
		base_fold += 10.0
	if gs.has_relic("sticky_table"):
		base_call += 15.0

	var total = base_call + base_fold
	return {
		"call_pct": clamp(base_call / total * 100.0, 0.0, 100.0),
		"fold_pct": clamp(base_fold / total * 100.0, 0.0, 100.0),
	}


class HandResult:
	var profit: int = 0
	var ev: float = 0.0
	var exploit_ev: float = 0.0
	var action_taken: String = ""
	var bet_sizing: float = 0.0
	var enemy_called: bool = false
	var enemy_call_pct: float = 0.0
	var enemy_fold_pct: float = 0.0
	var roll: int = 0

	func variance() -> float:
		return profit - ev
