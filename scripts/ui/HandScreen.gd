extends Control

signal hand_complete(result: Object)

var _spot: Dictionary
var _engine: Node

func _ready() -> void:
	_engine = preload("res://scripts/core/HandEngine.gd").new()
	add_child(_engine)
	_engine.hand_resolved.connect(_on_hand_resolved)
	_engine.enemy_responding.connect(_on_enemy_responding)

	var spots = preload("res://scripts/core/ScriptedSpots.gd").new()
	_spot = spots.get_random_spot()
	spots.free()

	_setup_ui()
	_engine.start_hand(_spot)

	$ActionArea/MainButtons/FoldBtn.pressed.connect(_on_fold)
	$ActionArea/MainButtons/CallBtn.pressed.connect(_on_call)
	$ActionArea/MainButtons/BetBtn.pressed.connect(_on_bet_pressed)

	for btn in $ActionArea/SizingMeter.get_children():
		btn.pressed.connect(_on_sizing_chosen.bind(btn.name))

func _setup_ui() -> void:
	$SpotName.text = _spot.get("name", "")
	$EnemyInfo.text = "Enemy: " + _spot.get("enemy_trait", {}).get("name", "Unknown")
	$PotStackInfo/PotLabel.text = "Pot: %dbb" % _spot.get("pot", 0)
	$PotStackInfo/StackLabel.text = "Stack: %dbb" % _spot.get("player_stack", 0)

	var gs = get_node("/root/GameState")
	$TableImage/FearLabel.text = "Fear: %d" % gs.table_image["fear"]
	$TableImage/SuspicionLabel.text = "Suspicion: %d" % gs.table_image["suspicion"]
	$TableImage/MysteryLabel.text = "Mystery: %d" % gs.table_image["mystery"]
	$BankrollLabel.text = "Bankroll: %d" % gs.bankroll

	_build_card_display($Board, _spot.get("board", []))
	_build_card_display($PlayerHand, _spot.get("player_hand", []))

func _build_card_display(container: Node, cards: Array) -> void:
	for child in container.get_children():
		child.queue_free()
	for card in cards:
		var lbl = Label.new()
		lbl.text = card
		lbl.theme_override_font_sizes = {"font_size": 28}
		lbl.custom_minimum_size = Vector2(60, 80)
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		container.add_child(lbl)

func _on_fold() -> void:
	_engine.player_action("fold")

func _on_call() -> void:
	_engine.player_action("call")

func _on_bet_pressed() -> void:
	$ActionArea/SizingMeter.visible = true
	$ActionArea/MainButtons.visible = false

func _on_sizing_chosen(btn_name: String) -> void:
	var sizing_map = {
		"Btn25": 0.25, "Btn50": 0.50, "Btn75": 0.75,
		"BtnPot": 1.0, "Btn150": 1.5, "BtnAllin": 999.0
	}
	var sizing = sizing_map.get(btn_name, 0.75)
	_engine.player_action("bet", sizing * _spot.get("pot", 0))

func _on_enemy_responding(call_pct: float, fold_pct: float, roll: int) -> void:
	var roll_display = $EnemyRollDisplay
	roll_display.visible = true
	roll_display/FreqLabel.text = "Call %.0f%% / Fold %.0f%%" % [call_pct, fold_pct]
	roll_display/RollLabel.text = "Roll: %d" % roll
	roll_display/RollResultLabel.text = "→ %s" % ("Call" if roll < call_pct else "Fold")
	$ActionArea.visible = false
	await get_tree().create_timer(1.8).timeout
	_engine.hand_resolved  # result will fire through signal

func _on_hand_resolved(result: Object) -> void:
	var gs = get_node("/root/GameState")
	gs.bankroll += result.profit
	gs.ev_score += result.ev
	emit_signal("hand_complete", result)
