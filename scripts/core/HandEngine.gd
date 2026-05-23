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
		"raise":  _resolve_bet(sizing)

func _resolve_fold() -> void:
	var result = HandResult.new()
	result.action_taken = "fold"
	result.profit = -_current_spot.get("amount_to_call", 0)
	result.ev = _current_spot.get("ev_fold", -float(_current_spot.get("amount_to_call", 0)))
	emit_signal("hand_resolved", result)

func _resolve_check() -> void:
	var result = HandResult.new()
	result.action_taken = "check"
	result.profit = 0
	result.ev = _current_spot.get("ev_check", 0.0)
	emit_signal("hand_resolved", result)

func _resolve_call() -> void:
	var result = HandResult.new()
	result.action_taken = "call"
	var pot = _current_spot.get("pot", 0)
	var villain_bet = _current_spot.get("villain_bet", 0)
	var to_call = _current_spot.get("amount_to_call", villain_bet)
	var equity = _current_spot.get("equity", 0.5)
	# EV(call) = equity × (pot + villain_bet + to_call) - to_call
	result.ev = equity * (pot + villain_bet + to_call) - to_call
	result.profit = pot + villain_bet if randf() < equity else -to_call
	emit_signal("hand_resolved", result)

func _resolve_bet(sizing: float) -> void:
	var freq_data = _calc_enemy_frequencies(sizing)
	var roll = randi() % 100
	var enemy_calls = roll < freq_data.call_pct
	emit_signal("enemy_responding", freq_data.call_pct, freq_data.fold_pct, roll)

	var result = HandResult.new()
	result.action_taken = "bet"
	result.bet_sizing = sizing
	result.enemy_called = enemy_calls
	result.enemy_call_pct = freq_data.call_pct
	result.enemy_fold_pct = freq_data.fold_pct
	result.roll = roll
	result.base_call_pct = freq_data.base_call_pct
	result.base_fold_pct = freq_data.base_fold_pct
	result.modifiers = freq_data.modifiers

	var pot = _current_spot.get("pot", 0)
	var equity = _current_spot.get("equity", 0.5)
	var fold_pct = freq_data.fold_pct / 100.0
	var call_pct = freq_data.call_pct / 100.0

	# EV(bet) = fold% × pot + call% × (equity × (pot + 2×bet) - bet)
	result.ev = fold_pct * pot + call_pct * (equity * (pot + 2.0 * sizing) - sizing)

	if enemy_calls:
		result.profit = pot + sizing if randf() < equity else -sizing
	else:
		result.profit = pot

	emit_signal("hand_resolved", result)

func _calc_enemy_frequencies(_sizing: float) -> Dictionary:
	var base_call = _current_spot.get("base_call_pct", 50.0)
	var base_fold = 100.0 - base_call
	var modifiers: Array = []

	var gs = get_node("/root/GameState")

	var fear = gs.table_image["fear"]
	if fear != 0:
		var delta = fear * 3.0
		base_fold += delta
		modifiers.append("Fear %+d: Fold %+.0f%%" % [fear, delta])

	var suspicion = gs.table_image["suspicion"]
	if suspicion != 0:
		var delta = suspicion * 3.0
		base_call += delta
		modifiers.append("Suspicion %+d: Call %+.0f%%" % [suspicion, delta])

	var enemy_trait = _current_spot.get("enemy_trait", {})
	var call_mod = enemy_trait.get("call_mod", 0.0)
	var fold_mod = enemy_trait.get("fold_mod", 0.0)
	if call_mod != 0.0:
		base_call += call_mod
		modifiers.append("%s: Call %+.0f%%" % [enemy_trait.get("name", "Enemy"), call_mod])
	if fold_mod != 0.0:
		base_fold += fold_mod
		modifiers.append("%s: Fold %+.0f%%" % [enemy_trait.get("name", "Enemy"), fold_mod])

	if gs.has_relic("fear_aura"):
		base_fold += 10.0
		modifiers.append("Fear Aura: Fold +10%")
	if gs.has_relic("sticky_table"):
		base_call += 15.0
		modifiers.append("Sticky Table: Call +15%")

	var total = base_call + base_fold
	return {
		"call_pct": clamp(base_call / total * 100.0, 0.0, 100.0),
		"fold_pct": clamp(base_fold / total * 100.0, 0.0, 100.0),
		"base_call_pct": _current_spot.get("base_call_pct", 50.0),
		"base_fold_pct": 100.0 - _current_spot.get("base_call_pct", 50.0),
		"modifiers": modifiers,
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
	var base_call_pct: float = 0.0
	var base_fold_pct: float = 0.0
	var modifiers: Array = []
	var roll: int = 0

	func variance() -> float:
		return profit - ev
