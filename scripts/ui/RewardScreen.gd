extends Control

signal relic_chosen(relic_id: String)

var _choices: Array = []

func _ready() -> void:
	var gs = get_node("/root/GameState")
	var rd = get_node("/root/RelicData")
	_choices = rd.get_random_choices(3, gs.relics)

	for i in range(3):
		var btn = $Panel/RelicContainer.get_child(i)
		if i < _choices.size():
			var relic = rd.get_relic(_choices[i])
			btn.text = "[%s]\n%s\n%s" % [relic.get("rarity", "").to_upper(), relic.get("name", ""), relic.get("description", "")]
			btn.pressed.connect(_on_relic_picked.bind(_choices[i]))
		else:
			btn.visible = false

	$Panel/SkipBtn.pressed.connect(func(): emit_signal("relic_chosen", ""))

func _on_relic_picked(relic_id: String) -> void:
	emit_signal("relic_chosen", relic_id)
