extends Node

const ENEMIES: Array = [
	{
		"id": "scared_money",
		"name": "Scared Money",
		"description": "Folds too much under pressure.",
		"call_mod": -10.0,
		"fold_mod": 10.0,
		"flavor": "Their hands tremble at every raise.",
	},
	{
		"id": "calling_station",
		"name": "Calling Station",
		"description": "Calls with almost anything.",
		"call_mod": 15.0,
		"fold_mod": -15.0,
		"flavor": "I just want to see what you have.",
	},
	{
		"id": "pro_reg",
		"name": "Pro Reg",
		"description": "Plays balanced, close to GTO.",
		"call_mod": 0.0,
		"fold_mod": 0.0,
		"flavor": "Eyes like a calculator.",
	},
	{
		"id": "maniac",
		"name": "Maniac",
		"description": "Aggro and hard to read.",
		"call_mod": 10.0,
		"fold_mod": -10.0,
		"flavor": "Chaos is their edge.",
	},
	{
		"id": "ego_hero",
		"name": "Ego Hero",
		"description": "Hates being bluffed.",
		"call_mod": 8.0,
		"fold_mod": -8.0,
		"flavor": "You DARE bluff me?",
	},
	{
		"id": "solver_monk",
		"name": "Solver Monk",
		"description": "Near-perfect play.",
		"call_mod": 0.0,
		"fold_mod": 2.0,
		"flavor": "They have solved the game.",
	},
]

func get_enemy(id: String) -> Dictionary:
	for enemy in ENEMIES:
		if enemy["id"] == id:
			return enemy
	return {
		"id": "pro_reg",
		"name": "Pro Reg",
		"description": "Plays balanced.",
		"call_mod": 0.0,
		"fold_mod": 0.0,
		"flavor": "Eyes like a calculator.",
	}
