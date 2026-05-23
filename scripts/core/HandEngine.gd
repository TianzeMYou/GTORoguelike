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
	_stamp_cards(result)
	emit_signal("hand_resolved", result)

func _resolve_check() -> void:
	var result = HandResult.new()
	result.action_taken = "check"
	result.ev = _current_spot.get("ev_check", 0.0)
	var is_river = _current_spot.get("street", "") == "river"
	if is_river:
		var equity = _current_spot.get("equity", 0.5)
		var pot = _current_spot.get("pot", 0)
		result.player_wins = randf() < equity
		result.profit = pot if result.player_wins else 0
		result.showdown = true
		result.villain_hand = _current_spot.get("villain_hand", [])
	else:
		result.profit = 0
		result.showdown = false
	_stamp_cards(result)
	emit_signal("hand_resolved", result)

func _resolve_call() -> void:
	var result = HandResult.new()
	result.action_taken = "call"
	var pot = _current_spot.get("pot", 0)
	var villain_bet = _current_spot.get("villain_bet", 0)
	var to_call = _current_spot.get("amount_to_call", villain_bet)
	var equity = _current_spot.get("equity", 0.5)
	result.ev = equity * (pot + villain_bet + to_call) - to_call
	result.player_wins = randf() < equity
	result.profit = pot + villain_bet if result.player_wins else -to_call
	result.showdown = true
	result.villain_hand = _current_spot.get("villain_hand", [])
	_stamp_cards(result)
	emit_signal("hand_resolved", result)

func _stamp_cards(result: HandResult) -> void:
	result.player_hand = _current_spot.get("player_hand", [])
	result.board = _current_spot.get("board", [])
	result.pot = _current_spot.get("pot", 0)

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
	result.enemy_name = freq_data.get("enemy_name", "")
	result.enemy_flavor = freq_data.get("enemy_flavor", "")

	var pot = _current_spot.get("pot", 0)
	var equity = _current_spot.get("equity", 0.5)
	var fold_pct = freq_data.fold_pct / 100.0
	var call_pct = freq_data.call_pct / 100.0

	# EV(bet) = fold% x pot + call% x (equity x (pot + 2xbet) - bet)
	result.ev = fold_pct * pot + call_pct * (equity * (pot + 2.0 * sizing) - sizing)

	var gs = get_node("/root/GameState")

	# Pressure Cooker stacks update
	if gs.has_relic("pressure_cooker"):
		if sizing >= pot * 0.75:
			gs.pressure_cooker_stacks = mini(gs.pressure_cooker_stacks + 1, 4)
		else:
			gs.pressure_cooker_stacks = 0

	# Glass Cannon check
	if gs.has_relic("glass_cannon") and sizing > pot:
		result.glass_cannon_active = true

	if enemy_calls:
		result.player_wins = randf() < equity
		result.profit = pot + sizing if result.player_wins else -sizing
		result.showdown = true
		result.villain_hand = _current_spot.get("villain_hand", [])
	else:
		result.profit = pot
		result.showdown = false

	_stamp_cards(result)
	emit_signal("hand_resolved", result)

func _calc_enemy_frequencies(sizing: float) -> Dictionary:
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

	# Room enemy archetype (from EnemyData autoload)
	var enemy_data = get_node("/root/EnemyData")
	var room = gs.get_current_room_data()
	var enemy = enemy_data.get_enemy(room.get("enemy", "pro_reg"))
	var e_call = enemy.get("call_mod", 0.0)
	var e_fold = enemy.get("fold_mod", 0.0)
	if e_call != 0.0:
		base_call += e_call
		modifiers.append("%s: Call %+.0f%%" % [enemy["name"], e_call])
	if e_fold != 0.0:
		base_fold += e_fold
		modifiers.append("%s: Fold %+.0f%%" % [enemy["name"], e_fold])

	# Relics
	if gs.has_relic("fear_aura"):
		base_fold += 10.0
		modifiers.append("Fear Aura: Fold +10%")
	if gs.has_relic("sticky_table"):
		base_call += 15.0
		modifiers.append("Sticky Table: Call +15%")
	if gs.has_relic("polarizer") and sizing >= _current_spot.get("pot", 1) * 1.5:
		base_fold += 20.0
		modifiers.append("Polarizer: Fold +20%")
	if gs.has_relic("pressure_cooker") and gs.pressure_cooker_stacks > 0:
		var pc = mini(gs.pressure_cooker_stacks * 5, 20)
		base_fold += pc
		modifiers.append("Pressure Cooker x%d: Fold +%d%%" % [gs.pressure_cooker_stacks, pc])
	if gs.has_relic("short_stack_ninja") and _current_spot.get("player_stack", 100) <= 30:
		base_fold += 10.0
		modifiers.append("Short Stack Ninja: Fold +10%")
	if gs.has_relic("advertising_campaign") and gs.bluff_shown_last_hand:
		base_call += 20.0
		modifiers.append("Advertising Campaign: Call +20%")
	if gs.has_relic("clean_reputation") and gs.shown_only_value_this_room:
		base_fold += 15.0
		modifiers.append("Clean Reputation: Fold +15%")
	if gs.has_relic("blood_in_water") and gs.blood_in_water_hands_remaining > 0:
		base_call += 10.0
		modifiers.append("Blood in the Water: Call +10%")

	var total = base_call + base_fold
	return {
		"call_pct": clamp(base_call / total * 100.0, 0.0, 100.0),
		"fold_pct": clamp(base_fold / total * 100.0, 0.0, 100.0),
		"base_call_pct": _current_spot.get("base_call_pct", 50.0),
		"base_fold_pct": 100.0 - _current_spot.get("base_call_pct", 50.0),
		"modifiers": modifiers,
		"enemy_name": enemy.get("name", ""),
		"enemy_flavor": enemy.get("flavor", ""),
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
	var showdown: bool = false
	var player_wins: bool = false
	var villain_hand: Array = []
	var player_hand: Array = []
	var board: Array = []
	var pot: int = 0
	var glass_cannon_active: bool = false
	var enemy_name: String = ""
	var enemy_flavor: String = ""

	func variance() -> float:
		return profit - ev
