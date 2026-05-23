extends Node

const RELICS: Array = [
	{
		"id": "fear_aura",
		"name": "Fear Aura",
		"description": "Enemies fold +10% to all your bets.",
		"rarity": "common",
	},
	{
		"id": "sticky_table",
		"name": "Sticky Table",
		"description": "Enemies call +15% vs all your bets.",
		"rarity": "common",
	},
	{
		"id": "advertising_campaign",
		"name": "Advertising Campaign",
		"description": "After showing a bluff, enemies call +20% next hand.",
		"rarity": "uncommon",
	},
	{
		"id": "clean_reputation",
		"name": "Clean Reputation",
		"description": "If you've only shown value this room, bluffs get +15% fold equity.",
		"rarity": "uncommon",
	},
	{
		"id": "glass_cannon",
		"name": "Glass Cannon",
		"description": "Overbets (>pot) win double profit. EV losses also doubled.",
		"rarity": "rare",
	},
	{
		"id": "insurance_policy",
		"name": "Insurance Policy",
		"description": "First losing hand each room deals only 50% bankroll damage.",
		"rarity": "common",
	},
	{
		"id": "pressure_cooker",
		"name": "Pressure Cooker",
		"description": "Each consecutive large bet (>=75% pot) gives enemies +5% fold, up to +20%.",
		"rarity": "uncommon",
	},
	{
		"id": "muck_artist",
		"name": "Muck Artist",
		"description": "Mucking gives Mystery +2 instead of +1.",
		"rarity": "common",
	},
	{
		"id": "short_stack_ninja",
		"name": "Short Stack Ninja",
		"description": "When stack <=30bb, fold equity +10%.",
		"rarity": "uncommon",
	},
	{
		"id": "polarizer",
		"name": "Polarizer",
		"description": "150% pot bets get +20% fold frequency.",
		"rarity": "uncommon",
	},
]

func get_relic(id: String) -> Dictionary:
	for relic in RELICS:
		if relic["id"] == id:
			return relic
	return {}

func get_random_choices(count: int, exclude: Array) -> Array:
	var available: Array = []
	for relic in RELICS:
		if not (relic["id"] in exclude):
			available.append(relic["id"])
	available.shuffle()
	return available.slice(0, mini(count, available.size()))
