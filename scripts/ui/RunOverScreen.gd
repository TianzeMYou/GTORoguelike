extends Control

signal restart_pressed

func show_result(reason: String) -> void:
	var gs = get_node("/root/GameState")

	if reason == "win":
		$Panel/TitleLabel.text = "Victory"
		$Panel/ReasonLabel.text = "You defeated the Solver Monk."
		$Panel/TitleLabel.modulate = Color.GOLD
	else:
		$Panel/TitleLabel.text = "Busted Out"
		$Panel/ReasonLabel.text = "Your bankroll hit zero."
		$Panel/TitleLabel.modulate = Color.RED

	var ev_grade = "S" if gs.ev_score > 100 else "A" if gs.ev_score > 50 else "B" if gs.ev_score > 20 else "C" if gs.ev_score > 0 else "D"
	$Panel/StatsLabel.text = "Rooms cleared: %d/6\nFinal bankroll: %dbb\nEV Score: %.1f (%s)" % [
		gs.current_room, gs.bankroll, gs.ev_score, ev_grade
	]

	var relic_names = []
	for r in gs.relics:
		relic_names.append(get_node("/root/RelicData").get_relic(r).get("name", r))
	$Panel/RelicsLabel.text = "Relics: " + (", ".join(relic_names) if relic_names.size() > 0 else "None")

	$Panel/RestartBtn.pressed.connect(func(): emit_signal("restart_pressed"))
