extends Node

func _ready() -> void:
	await get_tree().process_frame
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)

# Central game state — single source of truth for a run
var bankroll: int = 1000
var ev_score: float = 0.0
var table_image: Dictionary = {
	"fear": 0,
	"suspicion": 0,
	"targetability": 0,
	"mystery": 0,
}
var relics: Array = []

# Run structure
var current_room: int = 0
var hands_in_room: int = 0
var run_active: bool = false

# Relic tracking state
var pressure_cooker_stacks: int = 0
var insurance_used_this_room: bool = false
var bluff_shown_last_hand: bool = false
var shown_only_value_this_room: bool = true
var blood_in_water_hands_remaining: int = 0

const HANDS_PER_ROOM: int = 3
const STARTING_BANKROLL: int = 500

const ROOM_SEQUENCE: Array = [
	{"enemy": "scared_money",    "type": "normal",      "stack": "normal", "name": "The Timid Grinder"},
	{"enemy": "calling_station", "type": "normal",      "stack": "normal", "name": "The Fish Tank"},
	{"enemy": "pro_reg",         "type": "short_stack", "stack": "short",  "name": "Short Stack Duel"},
	{"enemy": "maniac",          "type": "normal",      "stack": "normal", "name": "The Maniac's Table"},
	{"enemy": "ego_hero",        "type": "deep_stack",  "stack": "deep",   "name": "Deep Stack Grudge Match"},
	{"enemy": "solver_monk",     "type": "boss",        "stack": "normal", "name": "The Solver Monk"},
]

func start_run() -> void:
	bankroll = STARTING_BANKROLL
	ev_score = 0.0
	table_image = {"fear": 0, "suspicion": 0, "targetability": 0, "mystery": 0}
	relics = []
	current_room = 0
	hands_in_room = 0
	run_active = true
	_reset_room_tracking()

func get_current_room_data() -> Dictionary:
	if current_room < ROOM_SEQUENCE.size():
		return ROOM_SEQUENCE[current_room]
	return {}

func advance_hand() -> void:
	hands_in_room += 1
	bluff_shown_last_hand = false
	if blood_in_water_hands_remaining > 0:
		blood_in_water_hands_remaining -= 1

func is_room_clear() -> bool:
	return hands_in_room >= HANDS_PER_ROOM

func advance_room() -> void:
	current_room += 1
	hands_in_room = 0
	table_image["fear"] = 0
	table_image["suspicion"] = 0
	table_image["targetability"] = 0
	table_image["mystery"] = 0
	_reset_room_tracking()

func _reset_room_tracking() -> void:
	pressure_cooker_stacks = 0
	insurance_used_this_room = false
	bluff_shown_last_hand = false
	shown_only_value_this_room = true
	blood_in_water_hands_remaining = 0

func is_run_over() -> bool:
	return bankroll <= 0

func is_run_won() -> bool:
	return current_room >= ROOM_SEQUENCE.size()

func on_show_bluff() -> void:
	bluff_shown_last_hand = true
	shown_only_value_this_room = false
	if has_relic("blood_in_water"):
		blood_in_water_hands_remaining = 3

func on_show_value() -> void:
	pass  # shown_only_value_this_room stays true

func apply_table_image_delta(delta: Dictionary) -> void:
	for key in delta:
		if table_image.has(key):
			table_image[key] += delta[key]

func has_relic(relic_id: String) -> bool:
	return relic_id in relics

func add_relic(relic_id: String) -> void:
	if not has_relic(relic_id):
		relics.append(relic_id)
