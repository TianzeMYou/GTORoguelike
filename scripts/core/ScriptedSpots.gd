extends Node

# MVP scripted decision spots — hand-authored for early prototype

const SPOTS: Array = [
	{
		"id": "river_bluff_deep",
		"name": "River Bluff — Deep Stack",
		"description": "You have a missed draw. Enemy range is capped. 150% pot overbet is available.",
		"player_hand": ["7h", "6h"],
		"board": ["Ah", "Kd", "7c", "3s", "2d"],
		"pot": 40,
		"player_stack": 140,
		"enemy_stack": 140,
		"amount_to_call": 0,
		"base_call_pct": 45.0,
		"enemy_trait": {"name": "Scared Money", "fold_mod": 10.0, "call_mod": 0.0},
		"ev_fold": -5,
		"ev_call": -12,
		"ev_bet_fold": 14,
		"ev_bet_called": -8,
		"bet_called_profit": -60,
	},
	{
		"id": "value_bet_river",
		"name": "River Value Bet",
		"description": "You have top pair top kicker. Enemy is a calling station.",
		"player_hand": ["Ah", "Kc"],
		"board": ["As", "7d", "2c", "9h", "3s"],
		"pot": 30,
		"player_stack": 100,
		"enemy_stack": 100,
		"amount_to_call": 0,
		"base_call_pct": 55.0,
		"enemy_trait": {"name": "Calling Station", "fold_mod": 0.0, "call_mod": 15.0},
		"ev_fold": -8,
		"ev_call": 0,
		"ev_bet_fold": 2,
		"ev_bet_called": 18,
		"bet_called_profit": 60,
	},
	{
		"id": "shove_or_fold_short",
		"name": "Short Stack Shove/Fold",
		"description": "25bb effective. You have AJo facing a raise. Shove or fold.",
		"player_hand": ["Ah", "Jd"],
		"board": [],
		"pot": 3,
		"player_stack": 22,
		"enemy_stack": 25,
		"amount_to_call": 2,
		"base_call_pct": 40.0,
		"enemy_trait": {"name": "Pro Reg", "fold_mod": 0.0, "call_mod": 0.0},
		"ev_fold": -2,
		"ev_call": 1,
		"ev_bet_fold": 8,
		"ev_bet_called": 4,
		"bet_called_profit": 25,
	},
]

func get_spot(id: String) -> Dictionary:
	for spot in SPOTS:
		if spot["id"] == id:
			return spot
	return {}

func get_random_spot() -> Dictionary:
	return SPOTS[randi() % SPOTS.size()]
