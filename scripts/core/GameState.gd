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
var current_room: int = 0
var rooms_cleared: int = 0

func reset_run() -> void:
	bankroll = 1000
	ev_score = 0.0
	table_image = {"fear": 0, "suspicion": 0, "targetability": 0, "mystery": 0}
	relics = []
	current_room = 0
	rooms_cleared = 0

func apply_table_image_delta(delta: Dictionary) -> void:
	for key in delta:
		if table_image.has(key):
			table_image[key] += delta[key]

func has_relic(relic_id: String) -> bool:
	return relic_id in relics
