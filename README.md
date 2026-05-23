# GTORoguelike

A Balatro-inspired GTO poker roguelike where every decision earns EV, every result earns profit, and every bluff, muck, show, relic, and all-in changes how the table plays against you.

## Concept

- **Profit** — what actually happened
- **EV** — how good your decisions were, independent of outcome
- **Table Image** — how enemies perceive and adjust to you
- **Relics** — bend poker physics to create run builds

See [docs/design_doc.md](docs/design_doc.md) for the full design document.

## Tech Stack

- [Godot 4](https://godotengine.org/) — game engine
- GDScript — scripting language

## Project Structure

```
scenes/          # Godot scene files (.tscn)
  ui/            # Menus, HUD, result screens
  rooms/         # Room/encounter scenes
  enemies/       # Enemy scenes
  relics/        # Relic scenes
scripts/         # GDScript logic
  core/          # GameState, HandEngine, ScriptedSpots
  enemies/       # Enemy archetype logic
  relics/        # Relic effect logic
  ui/            # UI controllers
resources/       # Godot resource files (.tres)
assets/          # Art, audio, fonts
docs/            # Design documents
```

## MVP Scope

1. Basic hand loop (Call / Bet / Fold)
2. Bet sizing meter
3. Visible enemy frequency roll
4. Profit + EV result screen
5. Fear / Suspicion table image meters
6. Muck / Show choice
7. 5 relics
8. 3 scripted spots
9. 1 mini-run of 3 rooms
