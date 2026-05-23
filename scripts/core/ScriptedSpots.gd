extends Node

# action_type: "bet" = you act first (Bet/Check/Fold), "call" = facing a villain bet (Call/Raise/Fold)
# equity: your probability of winning at showdown (0.0 - 1.0). Used to compute EV dynamically.

const SPOTS: Array = [
	{
		"id": "river_bluff_deep",
		"name": "River Bluff Spot",
		"situation": "Checked to you on the river. Villain's range is capped.",
		"action_type": "bet",
		"player_hand": ["7h", "6h"],
		"board": ["Ah", "Kd", "7c", "3s", "2d"],
		"pot": 40,
		"player_stack": 140,
		"enemy_stack": 140,
		"amount_to_call": 0,
		"base_call_pct": 45.0,
		"equity": 0.08,  # missed draw — almost never wins at showdown
		"enemy_trait": {"name": "Scared Money", "fold_mod": 10.0, "call_mod": 0.0},
		"ev_check": -8.0,
	},
	{
		"id": "value_bet_river",
		"name": "River Value Spot",
		"situation": "Checked to you on the river. You have top pair top kicker.",
		"action_type": "bet",
		"player_hand": ["Ah", "Kc"],
		"board": ["As", "7d", "2c", "9h", "3s"],
		"pot": 30,
		"player_stack": 100,
		"enemy_stack": 100,
		"amount_to_call": 0,
		"base_call_pct": 55.0,
		"equity": 0.82,  # top pair top kicker — strong favourite
		"enemy_trait": {"name": "Calling Station", "fold_mod": 0.0, "call_mod": 15.0},
		"ev_check": 2.0,
	},
	{
		"id": "facing_river_bet",
		"name": "Facing River Bet",
		"situation": "Villain bets 20bb into a 30bb pot on the river. You have second pair.",
		"action_type": "call",
		"player_hand": ["Kh", "7c"],
		"board": ["As", "7d", "2c", "9h", "3s"],
		"pot": 30,
		"villain_bet": 20,
		"player_stack": 100,
		"enemy_stack": 100,
		"amount_to_call": 20,
		"base_call_pct": 50.0,
		"equity": 0.38,  # second pair vs polarised range
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
		"player_hand": ["Jh", "9h"],
		"board": ["Ah", "6h", "3c", "Kd"],
		"pot": 20,
		"villain_bet": 15,
		"player_stack": 80,
		"enemy_stack": 80,
		"amount_to_call": 15,
		"base_call_pct": 50.0,
		"equity": 0.36,  # flush draw ~36% equity on turn
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
		"player_hand": ["Ah", "Jd"],
		"board": [],
		"pot": 4,
		"villain_bet": 2,
		"player_stack": 22,
		"enemy_stack": 25,
		"amount_to_call": 2,
		"base_call_pct": 40.0,
		"equity": 0.55,  # AJo slight favourite vs villain's open range
		"enemy_trait": {"name": "Pro Reg", "fold_mod": 0.0, "call_mod": 0.0},
		"ev_fold": -1.0,
		"ev_raise_fold": 8.0,
		"ev_raise_called": 4.0,
		"raise_called_profit": 25,
	},
]

func get_spot(id: String) -> Dictionary:
	for spot in SPOTS:
		if spot["id"] == id:
			return spot
	return {}

func get_random_spot() -> Dictionary:
	return SPOTS[randi() % SPOTS.size()]
