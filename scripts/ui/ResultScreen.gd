extends Control

signal continue_pressed

func show_result(result: Object) -> void:
	_build_card_display($CardArea/BoardCards, result.board)
	_build_card_display($CardArea/PlayerCards, result.player_hand)

	var profit = result.profit
	var ev = result.ev
	var variance = result.variance()

	$Panel/ProfitLabel.text = "Profit: %+d bb" % profit
	$Panel/ProfitLabel.modulate = Color.GREEN if profit >= 0 else Color.RED

	$Panel/EVLabel.text = "Decision EV: %+.1f" % ev
	$Panel/EVLabel.modulate = Color.CYAN if ev >= 0 else Color.ORANGE

	$Panel/VarianceLabel.text = "Variance: %+.1f" % variance
	$Panel/VerdictLabel.text = _verdict(profit, ev)

	if result.action_taken == "bet":
		$Panel/ActionLabel.text = "You bet %.0f bb" % result.bet_sizing
		$Panel/EnemySection/EnemyBaseLabel.text = "Base GTO: Call %.0f%% / Fold %.0f%%" % [result.base_call_pct, result.base_fold_pct]
		$Panel/EnemySection/EnemyModsLabel.text = "\n".join(result.modifiers) if result.modifiers.size() > 0 else "(no modifiers active)"
		$Panel/EnemySection/EnemyFreqLabel.text = "Final: Call %.0f%% / Fold %.0f%%" % [result.enemy_call_pct, result.enemy_fold_pct]
		$Panel/EnemySection/RollLabel.text = "Roll: %d → %s" % [result.roll, "Call" if result.enemy_called else "Fold"]
		$Panel/EnemySection.visible = true
	elif result.action_taken == "call":
		$Panel/ActionLabel.text = "You called"
		$Panel/EnemySection.visible = false
	elif result.action_taken == "check":
		$Panel/ActionLabel.text = "You checked"
		$Panel/EnemySection.visible = false
	elif result.action_taken == "fold":
		$Panel/ActionLabel.text = "You folded"
		$Panel/EnemySection.visible = false

	if result.showdown:
		var villain_cards = " ".join(result.villain_hand) if result.villain_hand.size() > 0 else "?? ??"
		$Panel/ShowdownSection/VillainHandLabel.text = "Villain shows: %s" % villain_cards
		$Panel/ShowdownSection/ShowdownResultLabel.text = "You win the pot" if result.player_wins else "Villain wins the pot"
		$Panel/ShowdownSection/ShowdownResultLabel.modulate = Color.GREEN if result.player_wins else Color.RED
		$Panel/ShowdownSection.visible = true
	else:
		$Panel/ShowdownSection.visible = false

	# Muck/show only after winning a bet without showdown
	if result.action_taken == "bet" and not result.enemy_called:
		$Panel/MuckShowButtons.visible = true
		$Panel/MuckShowButtons/MuckBtn.pressed.connect(_on_muck)
		$Panel/MuckShowButtons/ShowBluffBtn.pressed.connect(_on_show_bluff)
		$Panel/MuckShowButtons/ShowValueBtn.pressed.connect(_on_show_value)
	else:
		$Panel/ContinueBtn.visible = true

	$Panel/ContinueBtn.pressed.connect(func(): emit_signal("continue_pressed"))

func _verdict(profit: int, ev: float) -> String:
	if ev >= 5 and profit >= 0:
		return "Good decision. Good result."
	elif ev >= 5 and profit < 0:
		return "Good decision. Bad result.\nTrust the process."
	elif ev < 0 and profit >= 0:
		return "Bad decision. Lucky result."
	else:
		return "Bad decision. Bad result."

func _build_card_display(container: Node, cards: Array) -> void:
	for child in container.get_children():
		child.queue_free()
	for card in cards:
		var lbl = Label.new()
		lbl.text = card
		lbl.add_theme_font_size_override("font_size", 24)
		lbl.custom_minimum_size = Vector2(50, 70)
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		container.add_child(lbl)

func _on_muck() -> void:
	var gs = get_node("/root/GameState")
	gs.apply_table_image_delta({"mystery": 1})
	_finish_muck_show("Mystery +1")

func _on_show_bluff() -> void:
	var gs = get_node("/root/GameState")
	gs.apply_table_image_delta({"suspicion": 3, "fear": -1})
	_finish_muck_show("Suspicion +3  Fear -1")

func _on_show_value() -> void:
	var gs = get_node("/root/GameState")
	gs.apply_table_image_delta({"fear": 2, "suspicion": -1})
	_finish_muck_show("Fear +2  Suspicion -1")

func _finish_muck_show(delta_text: String) -> void:
	$Panel/MuckShowButtons.visible = false
	$Panel/ImageDeltaLabel.text = "Table Image: " + delta_text
	$Panel/ContinueBtn.visible = true
