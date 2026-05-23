extends Node

# action_type: "bet" = you act first (Bet/Check/Fold), "call" = facing a villain bet (Call/Raise/Fold)
# equity: your probability of winning at showdown (0.0 - 1.0). Used to compute EV dynamically.

const SPOTS: Array = [
	{
		"id": "river_bluff_deep",
		"name": "River Bluff Spot",
		"situation": "Checked to you on the river. Villain's range is capped.",
		"action_type": "bet",
		"street": "river",
		"stack_depth": "normal",
		"player_hand": ["7h", "6h"],
		"villain_hand": ["Qd", "Jc"],  # top of villain's capped range
		"board": ["Ah", "Kd", "7c", "3s", "2d"],
		"pot": 40,
		"player_stack": 140,
		"enemy_stack": 140,
		"amount_to_call": 0,
		"base_call_pct": 45.0,
		"equity": 0.08,
		"enemy_trait": {"name": "Scared Money", "fold_mod": 10.0, "call_mod": 0.0},
		"ev_check": -8.0,
	},
	{
		"id": "value_bet_river",
		"name": "River Value Spot",
		"situation": "Checked to you on the river. You have top pair top kicker.",
		"action_type": "bet",
		"street": "river",
		"stack_depth": "normal",
		"player_hand": ["Ah", "Kc"],
		"villain_hand": ["9d", "9h"],  # middle set — villain has a strong hand too
		"board": ["As", "7d", "2c", "9h", "3s"],
		"pot": 30,
		"player_stack": 100,
		"enemy_stack": 100,
		"amount_to_call": 0,
		"base_call_pct": 55.0,
		"equity": 0.82,
		"enemy_trait": {"name": "Calling Station", "fold_mod": 0.0, "call_mod": 15.0},
		"ev_check": 2.0,
	},
	{
		"id": "facing_river_bet",
		"name": "Facing River Bet",
		"situation": "Villain bets 20bb into a 30bb pot on the river. You have second pair.",
		"action_type": "call",
		"street": "river",
		"stack_depth": "normal",
		"player_hand": ["Kh", "7c"],
		"villain_hand": ["Ac", "Qh"],  # villain has top pair — often bluffing range too
		"board": ["As", "7d", "2c", "9h", "3s"],
		"pot": 30,
		"villain_bet": 20,
		"player_stack": 100,
		"enemy_stack": 100,
		"amount_to_call": 20,
		"base_call_pct": 50.0,
		"equity": 0.38,
		"enemy_trait": {"name": "Maniac", "fold_mod": 0.0, "call_mod": 0.0},
		"ev_fold": -5.0,
		"ev_raise_fold": 12.0,
		"ev_raise_called": -18.0,
		"raise_called_profit": -100,
	},
	{
		"id": "facing_turn_cbet",
		"name": "Facing Turn C-Bet",
		"situation": "Villain continuation bets 15bb into a 20bb pot on the turn. You have a flush draw.",
		"action_type": "call",
		"street": "turn",
		"stack_depth": "normal",
		"player_hand": ["Jh", "9h"],
		"villain_hand": ["Ac", "Kd"],  # villain has top pair, no flush draw
		"board": ["Ah", "6h", "3c", "Kd"],
		"pot": 20,
		"villain_bet": 15,
		"player_stack": 80,
		"enemy_stack": 80,
		"amount_to_call": 15,
		"base_call_pct": 50.0,
		"equity": 0.36,
		"enemy_trait": {"name": "Pro Reg", "fold_mod": 0.0, "call_mod": 0.0},
		"ev_fold": -6.0,
		"ev_raise_fold": 14.0,
		"ev_raise_called": 2.0,
		"raise_called_profit": 20,
	},
	{
		"id": "shove_or_fold_short",
		"name": "Short Stack Shove/Fold",
		"situation": "25bb effective. Villain raises to 3bb preflop. You have AJo in the big blind.",
		"action_type": "call",
		"street": "preflop",
		"stack_depth": "short",
		"player_hand": ["Ah", "Jd"],
		"villain_hand": ["Kc", "Qs"],  # villain has KQo — AJ is ahead
		"board": [],
		"pot": 4,
		"villain_bet": 2,
		"player_stack": 22,
		"enemy_stack": 25,
		"amount_to_call": 2,
		"base_call_pct": 40.0,
		"equity": 0.55,
		"enemy_trait": {"name": "Pro Reg", "fold_mod": 0.0, "call_mod": 0.0},
		"ev_fold": -1.0,
		"ev_raise_fold": 8.0,
		"ev_raise_called": 4.0,
		"raise_called_profit": 25,
	},
	{
		"id": "deep_stack_river_overbet",
		"name": "Deep Stack River",
		"situation": "150bb effective. Checked to you on river. Villain's range is weak.",
		"action_type": "bet",
		"street": "river",
		"stack_depth": "deep",
		"player_hand": ["Kh", "Qh"],
		"villain_hand": ["Jd", "Tc"],
		"board": ["Kd", "9s", "4h", "2c", "7d"],
		"pot": 60,
		"player_stack": 150,
		"enemy_stack": 150,
		"base_call_pct": 40.0,
		"equity": 0.85,
		"enemy_trait": {"name": "Deep Stack Villain", "fold_mod": 0.0, "call_mod": 0.0},
		"ev_check": 5.0,
	},
	{
		"id": "short_stack_value_jam",
		"name": "Short Stack Value Jam",
		"situation": "20bb effective. You have top pair. Shove for value.",
		"action_type": "bet",
		"street": "river",
		"stack_depth": "short",
		"player_hand": ["As", "Kh"],
		"villain_hand": ["Qc", "Jd"],
		"board": ["Ah", "7c", "2d", "9s", "3h"],
		"pot": 8,
		"player_stack": 16,
		"enemy_stack": 18,
		"base_call_pct": 55.0,
		"equity": 0.88,
		"enemy_trait": {"name": "Short Stack Villain", "fold_mod": 0.0, "call_mod": 0.0},
		"ev_check": 3.0,
	},
	{
		"id": "facing_deep_stack_bet",
		"name": "Facing Deep Stack Bet",
		"situation": "150bb effective. Villain bets 40bb into 50bb on river. You have a bluff catcher.",
		"action_type": "call",
		"street": "river",
		"stack_depth": "deep",
		"player_hand": ["Qh", "Jh"],
		"villain_hand": ["Ah", "Kd"],
		"board": ["Qs", "7d", "3h", "2s", "9c"],
		"pot": 50,
		"villain_bet": 40,
		"player_stack": 150,
		"enemy_stack": 150,
		"amount_to_call": 40,
		"base_call_pct": 45.0,
		"equity": 0.52,
		"enemy_trait": {"name": "Deep Stack Villain", "fold_mod": 0.0, "call_mod": 0.0},
		"ev_fold": -8.0,
		"ev_raise_fold": 15.0,
		"ev_raise_called": -25.0,
		"raise_called_profit": -150,
	},
]

func get_spot(id: String) -> Dictionary:
	for spot in SPOTS:
		if spot["id"] == id:
			return spot
	return {}

func get_random_spot() -> Dictionary:
	return SPOTS[randi() % SPOTS.size()]

func get_spot_for_depth(depth: String) -> Dictionary:
	var matching: Array = []
	for spot in SPOTS:
		if spot.get("stack_depth", "normal") == depth:
			matching.append(spot)
	if matching.size() > 0:
		return matching[randi() % matching.size()]
	# Fall back to random normal spot
	var normal_spots: Array = []
	for spot in SPOTS:
		if spot.get("stack_depth", "normal") == "normal":
			normal_spots.append(spot)
	if normal_spots.size() > 0:
		return normal_spots[randi() % normal_spots.size()]
	return SPOTS[randi() % SPOTS.size()]
