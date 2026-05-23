# GTORoguelike

Balatro-inspired GTO poker roguelike. Godot 4.6, GDScript.
Repo: https://github.com/TianzeMYou/GTORoguelike

## What this game is

A poker roguelike where GTO is the baseline physics, but relics, table image, and enemy personalities bend that baseline. The player manages:
- **Profit** — what actually happened
- **EV** — how good the decision was, independent of outcome
- **Table Image** — Fear/Suspicion/Mystery/Targetability affect enemy frequencies
- **Bankroll** — run survival resource

Core fantasy: building a poker strategy engine over the course of a run.

## Tech

- Godot 4.6, GDScript
- No external dependencies
- Autoloads: `GameState`, `RelicData`, `EnemyData`

## Project structure

```
scenes/ui/          # HandScreen, ResultScreen, RewardScreen, RunOverScreen, Main
scripts/core/       # GameState, HandEngine, ScriptedSpots, RelicData, EnemyData
scripts/ui/         # HandScreen, ResultScreen, RewardScreen, RunOverScreen, Main
docs/               # design_doc.md — full design reference
```

## Core systems

### HandEngine
Computes EV dynamically:
```
EV(bet) = fold% × pot + call% × (equity × (pot + 2×bet) - bet)
EV(call) = equity × (pot + villain_bet + to_call) - to_call
```
Enemy frequencies modified by: table image, enemy archetype, relics.

### Scripted spots
Each spot has `action_type: "bet"` (Check/Bet/Fold) or `"call"` (Call/Raise/Fold), plus `street`, `stack_depth`, `equity`, and hand-authored EV fallbacks.

### Run structure
6 rooms in sequence (GameState.ROOM_SEQUENCE), 3 hands per room, reward screen between rooms.
Room order: Scared Money → Calling Station → Pro Reg (short) → Maniac → Ego Hero (deep) → Solver Monk (boss)

### Relics (10)
fear_aura, sticky_table, advertising_campaign, clean_reputation, glass_cannon, insurance_policy, pressure_cooker, muck_artist, short_stack_ninja, polarizer

### Enemy archetypes (6)
scared_money, calling_station, pro_reg, maniac, ego_hero, solver_monk

## Current state & known issues

Last session added run structure, relics, enemy archetypes in one large commit. May have node path errors — check Godot Output panel on first run and fix parse/runtime errors before continuing.

## Build order (from design doc)

Done:
- [x] Basic hand loop
- [x] Stack/pot/bet sizing
- [x] Scripted decision spots
- [x] Enemy frequency + visible roll
- [x] Post-hand result screen
- [x] EV scoring (dynamic formula)
- [x] Table image meters
- [x] Muck/show choices
- [x] Table image modifies enemy rolls
- [x] Enemy archetypes
- [x] Relics (10)
- [x] Run/room structure
- [x] Bankroll/health system
- [x] Stack-depth room variety

Next:
- [ ] Fix any errors from last session
- [ ] More scripted spots (target ~10-15)
- [ ] Frequency debt system
- [ ] Achievements
- [ ] Stage 2 EV: real equity from hand evaluator
- [ ] Polish, animations, card art

## Dev notes

- User is new to game dev, learning Godot — explain Godot concepts when relevant
- Move fast, skip UX polish until core loop is fun
- Always push after commits
- Full design doc at docs/design_doc.md
