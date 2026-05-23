# GTO Poker Roguelike Design Document

## One-Sentence Pitch

A Balatro-inspired GTO poker roguelike where every decision earns EV, every result earns profit, and every bluff, muck, show, relic, and all-in changes how the table plays against you.

---

# 1. Core Identity

The game is a poker roguelike where GTO is the baseline physics, but relics, table image, enemy personalities, and variance bend that baseline.

The player is not only trying to win pots. They are managing four major resources:

```text
1. Profit - how much money/chips the player actually wins
2. EV - how good the player's decisions were
3. Table Image - how enemies perceive and adjust to the player
4. Run Survival - bankroll/health across the run
```

The core fantasy is:

> I am building a poker strategy engine over the course of a run.

---

# 2. Core Game Loop

Each hand plays like a simplified poker decision tree.

```text
Start hand
↓
Show player cards / board / pot / stack
↓
Player decision:
[Call] [Bet/Raise] [Fold]
↓
If Bet/Raise:
Use sizing meter
↓
Enemy responds using GTO baseline + modifiers + visible roll
↓
Hand resolves
↓
EV, profit, variance, and table image update
↓
Player may muck/show when applicable
↓
Move to next hand, reward, or room
```

The hand should feel fast, readable, and strategic.

---

# 3. Player Action UI

At each decision point, the player has simple buttons:

```text
[Call] [Bet/Raise] [Fold]
```

If the player chooses Bet/Raise, a sizing meter appears:

```text
25% pot | 50% pot | 75% pot | Pot | 150% pot | All-In
```

Early-game sizing can be simplified:

```text
Small / Medium / Big
```

Later, relics or upgrades can unlock advanced sizing:

```text
Block bet
Pot bet
Overbet
All-In
Geometric sizing
```

The goal is to keep controls simple while letting strategy become deep.

---

# 4. EV and Profit Split

The main scoring innovation is separating decision quality from actual outcome.

## Profit

Profit is what actually happened.

```text
Won pot: +80
Lost all-in: -100
Folded: -12
```

## EV

EV is how good the decision was, independent of result.

```text
Correct shove: +18 EV
Bad bluff: -22 EV
Close mixed decision: +1 EV
```

This solves the key poker-game problem:

> Good decisions can lose. Bad decisions can win.

Example result:

```text
Profit: -100
Decision EV: +16
Variance: -116

Verdict:
Good shove. Bad outcome.
```

Another example:

```text
Profit: +72
Decision EV: -18
Variance: +90

Verdict:
Bad bluff. Lucky result.
```

---

# 5. Final Score Formula

A possible final score formula:

```text
Final Score = Profit × EV Grade Multiplier + Exploit Bonus
```

Example:

```text
Profit: 10,000
EV Grade: D
Multiplier: ×0.6
Final Score: 6,000
```

Versus:

```text
Profit: 7,000
EV Grade: A
Multiplier: ×1.6
Final Score: 11,200
```

This lets luck matter, but prevents bad lucky play from being optimal.

---

# 6. Enemy Decision System

Enemies do not know the player's hand. They respond according to visible frequencies.

Every enemy decision starts from a baseline response:

```text
Base GTO:
Call 50%
Fold 50%
```

Then modifiers apply:

```text
Enemy Trait:
Calling Station: Call +15%

Relic:
Fear Aura: Fold +10%

Player Table Image:
Shown bluff recently: Call +12%

Final:
Call 67%
Fold 33%
```

Then the game rolls:

```text
Roll: 42 → Call
```

This makes the game feel fair because the player sees:

```text
The enemy had a strategy.
The modifiers changed that strategy.
The result came from a roll.
The NPC did not cheat.
```

---

# 7. Visible Roll Mechanic

For mixed spots, the enemy decision is shown as a probability roll.

Example:

```text
Villain Decision:
Call 48%
Fold 52%

Roll: 71
Result: Fold
```

This helps players accept randomness because roguelike players are used to visible RNG.

A good bluff might still fail:

```text
You made a good bluff.
Enemy folds 62% of the time.
Roll: 18.
Enemy calls.
```

The player may lose profit, but still gain EV if the bluff was correct.

---

# 8. Relics Bend the Poker Physics

Relics modify enemy frequencies, player incentives, scoring, table image, or variance.

The base game is GTO. Relics create the run.

## Overfold Relics

These encourage bluffing.

```text
Fear Aura:
Enemies fold +10% versus river overbets.

Scare Card Lens:
Enemies fold +15% more on A/K/Q turns and rivers.

Polarizer:
150% pot bets gain +20% fold frequency, but small bets lose fold equity.

Bubble Pressure:
When you cover the enemy, enemies overfold by +8%.
```

## Overcall Relics

These encourage value-heavy play.

```text
Sticky Table:
Enemies call +15% versus river bets.

Hero Caller's Curse:
Enemies call +25% with bluff-catchers.

Blood in the Water:
After you show a bluff, enemies call +10% for the next 3 hands.

Curiosity Tax:
Enemies call more often when your line is unusual.
```

## Overbet Relics

These encourage pressure.

```text
Glass Cannon:
Bets above pot count double for profit, but EV mistakes are doubled.

Pressure Cooker:
Each consecutive large bet increases enemy fold frequency by +5%, stacking up to +20%.

No Small Pots:
You cannot bet below 75% pot, but value bets gain a multiplier.

Juggernaut Sizing:
Overbets gain bonus EV when used with nut advantage.
```

## Enemy Aggression Relics

These affect how much enemies bluff or attack.

```text
Truth Serum:
Enemies bluff 15% less often. Correct folds and value raises gain bonus EV.

Madness Chip:
Enemies bluff 20% more often, but their value bets shrink.

Tilt Engine:
After losing a big pot, enemies overbluff the next hand.

Broken Compass:
Enemy mixed actions have wider variance.
```

## Table Image Relics

```text
Advertising Campaign:
When you show a bluff, your next value bet gets enemies to call +20%.

Clean Reputation:
If you have shown only value this combat, your next bluff gets enemies to fold +15%.

Mask of Chaos:
Your table image modifiers are doubled, both positive and negative.

Muck Artist:
Mucking increases Mystery. Mystery increases enemy response variance.

Boy Who Cried Bluff:
After showing two bluffs, enemies call +30%. Your value bets gain bonus EV when called.

Stone Face:
Your table image does not change for 3 hands after activation.
```

## Stack and All-In Relics

```text
Deep Pockets:
Start deep-stack encounters with +50bb effective stack. River EV bonuses increased.

Short Stack Ninja:
At 30bb or less, correct all-ins gain bonus EV.

Insurance Policy:
First lost all-in each combat deals 50% less bankroll damage.

Pressure Stack:
When you cover the enemy, their fold frequency increases by 8%.

Desperation Jam:
When below 25bb, all-ins gain +15% fold equity but EV mistakes are doubled.
```

---

# 9. Exploit EV

The game can track two forms of EV:

```text
GTO EV:
How close the player's play was to baseline optimal.

Exploit EV:
How well the player's play used this run's relics, enemies, and table image.
```

Example:

```text
You overbet river as a bluff.

Baseline GTO EV: -4
Exploit EV: +19
Actual Profit: +80

Verdict:
Bad at baseline, great in this run.
```

This is important because roguelikes are about becoming broken. The player should be allowed to make plays that are not pure GTO if their build supports them.

---

# 10. Player Table Image

The player has a reputation that changes based on actions and revealed cards.

Possible table image meters:

```text
Fear - makes enemies fold more
Suspicion - makes enemies call more
Targetability - makes enemies bluff/attack more
Mystery - makes enemy responses more volatile or uncertain
```

Simple starting version:

```text
Fear
Suspicion
```

Example updates:

```text
Big bet with no showdown:
Fear +1
Suspicion +1
Mystery +1

Show bluff:
Fear -1
Suspicion +3
Mystery -2

Show value:
Fear +2
Suspicion -1
Mystery -2

Muck:
Mystery +1
```

Core principle:

```text
Muck = preserve uncertainty
Show = intentionally steer enemy behavior
```

---

# 11. Muck or Show Mechanic

After certain hands, the player can decide whether to reveal their cards.

This turns information into a strategic resource.

## After Folding

```text
[Fold and Muck] [Fold and Show]
```

Showing changes table image based on what was folded.

### Show Weak Fold

```text
Discipline +2
Suspicion -1
Enemies bluff slightly less often.
```

### Show Medium Fold

```text
Targetability +2
Enemies may attack more often.
```

### Show Strong Fold

```text
Targetability +3
Fear -1
Enemies bluff and overbet more often.
```

This is dangerous but can support a trap or bluff-catcher build.

## After Winning Without Showdown

```text
[Take Pot Quietly] [Show Bluff] [Show Value]
```

### Show Bluff

```text
Suspicion +3
Enemies call future bets more often.
Future value bets become stronger.
```

### Show Value

```text
Fear +2
Enemies fold more to future pressure.
Future bluffs become stronger.
```

### Muck / Take Pot Quietly

```text
Mystery +1
Preserve uncertainty.
```

---

# 12. Table Image Affects Enemy Rolls

Player reputation modifies enemy decision frequencies.

Example:

```text
Base GTO:
Call 46%
Fold 54%

Enemy Trait:
Cautious: Fold +8%

Player Table Image:
Frequent overbettor: Call +12%
Shown bluff recently: Call +10%

Relic:
Fear Aura: Fold +15%

Final:
Call 45%
Fold 55%

Roll:
68 → Fold
```

When the enemy calls an overbet, the player should not think the NPC cheated. The player should think:

> My image made them suspicious.

---

# 13. Enemy Archetypes

Enemies should react differently to table image and relics.

## Calling Station

Calls too much.

```text
Your aggression makes them call even more.
Great target for value builds.
Bad target for bluff builds.
```

## Scared Money

Folds too much.

```text
Your aggression creates fear.
Showing a bluff makes them fight back.
```

## Pro Reg

Adjusts slowly and accurately.

```text
Punishes imbalance.
Responds strongly to repeated overbets or overfolding.
```

## Ego Hero

Hates being bluffed.

```text
After you show a bluff, they call much more.
Good target for value traps.
```

## Maniac

Bluffs and raises aggressively.

```text
Good for bluff-catching builds.
Dangerous for weak/passive players.
```

## Solver Monk

Near-GTO boss.

```text
Few leaks.
Rewards clean technical play.
```

---

# 14. Stack System

The game should have stacks, but hand stack should not be the same as run health.

Use three resources:

```text
Hand Stack - chips available in the current hand
Bankroll/Health - run survival resource
EV Score - skill score
```

During a hand, poker works normally:

```text
You have 100bb.
Villain has 100bb.
Pot is 12bb.
You bet 9bb.
Villain raises to 32bb.
You can fold, call, or jam.
```

After the hand, profit/loss converts into run effects:

```text
Profit: -100bb
Bankroll Damage: -30
EV Score: +18
Variance: -118
```

This allows all-ins without one unlucky cooler ending the whole run.

---

# 15. Stack Depth Creates Room Variety

Not every hand should start with the same stack. Stack depth creates different poker puzzles.

## Normal Rooms

```text
60-120bb
Standard poker decisions
Good for normal encounters
```

## Short Stack Rooms

```text
20-40bb
More shove/fold
More preflop pressure
Fast, volatile rooms
```

## Deep Stack Rooms

```text
150-250bb
More implied odds
More river pressure
More massive mistakes
```

## Asymmetric Rooms

```text
You: 40bb
Enemy: 180bb

Enemy pressures you.
Double-ups are valuable.
```

## Boss Rooms

Custom stack setups:

```text
Final Table Bubble
Deep Stack Duel
Short Stack Survival
All-In Gauntlet
```

---

# 16. All-In System

All-in should exist because it is emotionally powerful.

But it should feel special, not spammy.

All-in can appear when:

```text
1. Stack-to-pot ratio is low
2. Player drags bet meter to max
3. Certain relics unlock all-in pressure
4. Boss or challenge rooms allow it
5. Tournament-style rooms force shove/fold spots
```

All-in result screen:

```text
You jam turn.

Fold equity: 38%
Equity when called: 42%
Jam EV: +16bb

Villain calls.
You lose.

Profit: -100bb
EV: +16
Variance: -116

Verdict:
Good shove. Bad result.
```

---

# 17. Room Types

The run can be structured like a map.

Each room is a poker encounter with its own rules.

```text
Standard Table - normal hand sequence
Short Stack Table - fast shove/fold spots
Deep Stack Table - high-stakes postflop decisions
Image Table - table image changes are doubled
Mystery Table - mucking is stronger, showing is riskier
Maniac Table - enemies bluff and raise more
Bubble Table - folding has strategic value, calling off too wide is punished
Boss Table - custom enemy with unique rules, relic counters, or image memory
```

---

# 18. Frequency Debt

Frequency debt prevents degenerate strategies.

Purpose:

```text
Prevent overbet every river from being optimal forever.
```

Example:

```text
Enemy has folded too often compared to expected strategy.
Call Debt +12%
```

This modifies the next decision:

```text
Base:
Call 45%
Fold 55%

Frequency Debt:
Call +12%

Final:
Call 57%
Fold 43%
```

This creates drama:

```text
Enemy has high Call Debt.
Your bluff is dangerous now.
```

---

# 19. Post-Hand Screen

After each hand, show a clean result summary.

```text
Hand Result

Profit: +80
Decision EV: +14
Exploit EV: +8
Variance: +58

Table Image:
Fear +1
Suspicion +2
Mystery -1

Reason:
Your overbet worked because your relics made the enemy overfold.
However, repeated overbets are increasing suspicion.
```

Enemy decision breakdown:

```text
Enemy Response

Base GTO:
Call 48% / Fold 52%

Modifiers:
Calling Station: Call +15%
Shown bluff recently: Call +10%
Fear Aura: Fold +12%

Final:
Call 61% / Fold 39%

Roll:
72 → Fold
```

Transparency is a major trust feature.

---

# 20. Build Archetypes

The roguelike should naturally produce build types.

## The Bully

Goal: make enemies fold.

Tools:

```text
Fear Aura
Polarizer
Pressure Cooker
Bubble Pressure
```

Playstyle:

```text
Big bets
River overbets
Attack capped ranges
Bluff more
```

Weakness:

```text
Calling stations and suspicious enemies.
```

## The Value Farmer

Goal: make enemies call too much.

Tools:

```text
Sticky Table
Hero Caller's Curse
Blood in the Water
Advertising Campaign
```

Playstyle:

```text
Show bluffs
Value bet thin
Reduce bluff frequency
Get paid
```

Weakness:

```text
Needs hands or thin value skill.
```

## The Bluff Catcher

Goal: induce enemy bluffs.

Tools:

```text
Madness Chip
Tilt Engine
Strong Fold Reveals
Targetability build
```

Playstyle:

```text
Check more
Call more
Trap
Let enemies punt
```

Weakness:

```text
Can get value-owned.
```

## The Solver Monk

Goal: maximize clean EV.

Tools:

```text
Balanced Scale
Equilibrium Stone
Mixed Frequency Charm
```

Playstyle:

```text
Close to GTO
Small mistakes
Consistent scoring
```

Weakness:

```text
Less explosive profit.
```

## The Maniac

Goal: high variance, high multiplier.

Tools:

```text
Glass Cannon
No Small Pots
All-In Idol
Redline Demon
```

Playstyle:

```text
Huge bets
All-ins
High pressure
Massive score swings
```

Weakness:

```text
Runs can implode.
```

---

# 21. Achievements

Achievements should reinforce mechanics, not just count grindy milestones.

## Table Image Achievements

```text
Advertising Budget:
Show a bluff, then get paid by worse within the next 3 hands.

Wolf in Wool:
Maintain low aggression for 5 hands, then win with an overbet bluff.

Open Book:
Voluntarily show 10 hands in one run.

Closed Book:
Win a run without voluntarily showing a single hand.

Information Warfare:
Gain 200+ exploit EV from table image modifiers.
```

## GTO / EV Achievements

```text
Solver Monk:
Finish a run with an A-grade EV score.

No Punt Zone:
Complete an encounter with zero major EV mistakes.

Indifference Engine:
Win a hand where call and fold were within 1 EV.

Balanced Breakfast:
Maintain correct value/bluff ratio across a full encounter.

Pure Frequency:
Take 10 mixed-frequency actions without losing EV.
```

## Exploit Achievements

```text
Population Crusher:
Gain 100+ exploit EV in one run.

Value Printer:
Win 5 called river bets against overcalling enemies.

Fold Equity Farmer:
Force 10 folds from overfolding enemies.

Not GTO, But It Works:
Win a hand with a baseline-negative play made profitable by relics.

Read the Room:
Correctly adjust against three different enemy archetypes in one run.
```

## Variance Achievements

```text
Correct and Punished:
Make a +EV decision and lose a huge pot.

Wrong and Rewarded:
Make a negative-EV decision and win anyway.

Trust the Process:
Lose 5 hands in a row while maintaining positive EV.

Run Good Incarnate:
Finish an encounter far above EV expectation.

One Outer Energy:
Win after having less than 10% equity.
```

## Stack / All-In Achievements

```text
Fearless Jam:
Make 5 profitable all-ins in one run.

Deep Water:
Win a 200bb+ pot.

Short Stack Ninja:
Win a short-stack encounter without making an EV mistake.

They Finally Snapped:
Get called after 3 consecutive overbets and win with value.
```

---

# 22. Example Full Hand

```text
Room:
Deep Stack Table

Effective Stack:
180bb

Enemy:
Scared Money

Your Table Image:
Fear: 4
Suspicion: 2
Mystery: 3

Relics:
Fear Aura: enemies fold +10% to overbets
Polarizer: 150% pot bets gain +20% fold frequency
```

River spot:

```text
Pot: 40bb
Effective stack: 140bb
You have a missed draw.
Enemy range is capped.
```

Player chooses:

```text
Bet/Raise → 150% pot
```

Enemy response calculation:

```text
Base GTO:
Call 45%
Fold 55%

Enemy Trait:
Scared Money: Fold +10%

Your Image:
High Fear: Fold +8%
Moderate Suspicion: Call +5%

Relics:
Fear Aura: Fold +10%
Polarizer: Fold +20%

Frequency Debt:
Enemy folded too much recently: Call +12%

Final:
Call 24%
Fold 76%

Roll:
61 → Fold
```

Result:

```text
Profit: +40bb
Decision EV: +11
Exploit EV: +24
Variance: +5

Table Image:
Fear +1
Suspicion +2
Mystery +1

Verdict:
Great exploit.
Your build made this bluff highly profitable.
Warning: Suspicion is rising.
```

---

# 23. Build Checkpoints

This section is the order to build the game.

## 1. Define the smallest playable poker loop

Goal: one hand can start, the player can act, the enemy can respond, and the hand can end.

Build:

```text
Start hand
Show player cards / board / pot / stack
Player chooses Call, Bet/Raise, or Fold
If Bet/Raise, choose sizing
Enemy responds
Hand resolves
Show profit result
```

At this stage, the enemy can be dumb or scripted.

## 2. Add stack, pot, and bet sizing rules

Build reliable poker accounting.

```text
Player stack
Enemy stack
Current pot
Amount to call
Legal bet sizes
All-in handling
Fold/call/bet/raise logic
```

Checkpoint:

```text
Can the player bet 75% pot?
Can the enemy call?
Does the pot update correctly?
Can someone go all-in?
Does the hand end correctly?
```

## 3. Build a simplified hand evaluator

Build:

```text
Deal hole cards
Deal board cards
Evaluate best hand
Compare player vs enemy
Award pot
```

Checkpoint:

```text
Pair beats high card
Flush beats straight
Tie splits pot
All-in runs out remaining board cards
```

## 4. Create scripted decision spots

Use designed spots before full random generation.

Example:

```text
Spot 1:
River decision
Pot: 40bb
Stack: 100bb
Board: A K 7 3 2
Player has missed draw
Enemy has capped range
```

Build:

```text
Preset hands
Preset boards
Preset pot sizes
Preset stacks
Preset enemy ranges or response profiles
```

## 5. Add enemy response frequencies

Add the visible roll system.

```text
Enemy response:
Call %
Fold %
Raise %
```

Checkpoint:

```text
Enemy decision displays percentages
Game rolls visibly
Enemy action matches the roll
Player can inspect result afterward
```

## 6. Add post-hand result screen

Show:

```text
Profit
Pot won/lost
Enemy decision roll
Basic hand result
```

## 7. Add rough EV scoring

Start with hand-authored EV values.

Example:

```text
Spot: River bluff
Best action: Bet 150% pot
EV values:
Fold: -5
Check: -12
Bet 50%: +2
Bet 100%: +8
Bet 150%: +14
All-in: +5
```

Checkpoint:

```text
Good decisions gain EV
Bad decisions lose EV
Winning with a bad decision still shows bad EV
Losing with a good decision still shows good EV
```

## 8. Add table image meters

Start with:

```text
Fear
Suspicion
```

Later add:

```text
Targetability
Mystery
```

## 9. Add muck/show choices

After folding:

```text
[Muck] [Show]
```

After winning without showdown:

```text
[Take Pot Quietly] [Show]
```

## 10. Connect table image to enemy rolls

Simple first version:

```text
Each Fear = +3% enemy fold
Each Suspicion = +3% enemy call
```

Checkpoint:

```text
Player shows bluff
Suspicion rises
Next enemy call frequency increases
UI explains why
```

## 11. Add enemy archetypes

Start with:

```text
Calling Station
Scared Money
Maniac
Pro Reg
```

## 12. Add relics

Start with 10 relics, not 100.

Good first batch:

```text
Fear Aura
Sticky Table
Advertising Campaign
Clean Reputation
Glass Cannon
Insurance Policy
Pressure Cooker
Muck Artist
Short Stack Ninja
Balanced Scale
```

## 13. Add run structure

Simple version:

```text
Run starts
Choose room
Play 3-5 hands
Get reward/relic
Choose next room
Boss
```

## 14. Add bankroll/health

Separate hand chips from run survival.

```text
Hand stack = poker chips in the current hand
Bankroll/Health = run survival
EV Score = skill score
```

## 15. Add stack-depth room variety

```text
Normal Room: 100bb effective
Short Stack Room: 25bb effective
Deep Stack Room: 200bb effective
Asymmetric Room: Player 40bb, enemy 180bb
Boss: Custom stack rules
```

## 16. Add achievements

Add achievements once the mechanics are stable.

Categories:

```text
Table Image
GTO/EV
Exploit
Variance
Stack/All-In
Relic Synergy
```

## 17. Add frequency debt

Add this as a balancing system.

```text
Enemy folded more than expected recently.
Call Debt +12%
```

## 18. Improve EV models

Development path:

```text
Stage 1: Hand-authored EV values
Stage 2: Range-based approximations
Stage 3: Precomputed solver tables for common spots
Stage 4: Real solver integration or offline-generated spot library
```

Do not start with solver integration. It will slow development.

## 19. Add polish and juice

```text
Roll animations
Chip movement
Enemy tells
Table image animations
Relic combo effects
Boss intros
Post-hand replay
Run summary
EV graph
Profit graph
Variance graph
```

---

# 24. Recommended MVP Scope

For the first playable prototype, build only this:

```text
1 enemy
10 scripted spots
Call / Bet / Fold buttons
Bet sizing meter
Visible enemy roll
Profit result
Hand-authored EV score
Fear/Suspicion meters
Muck/show choice
5 relics
1 mini-run of 3 rooms
```

This is enough to test whether the concept is fun.

---

# 25. Build Order Summary

```text
1. Basic hand loop
2. Stack/pot/bet sizing system
3. Hand evaluator/showdown
4. Scripted decision spots
5. Enemy frequency + visible roll
6. Post-hand result screen
7. Rough EV scoring
8. Table image meters
9. Muck/show choices
10. Table image modifies enemy rolls
11. Enemy archetypes
12. Relics
13. Run/room structure
14. Bankroll/health system
15. Stack-depth room variety
16. Achievements
17. Frequency debt
18. Better EV model
19. Polish, animations, graphs, boss flavor
```

The most important checkpoint is number 7: once profit and EV both work, it will be clear whether the whole idea has legs.

---

# 26. Design Pillars

## Transparent Randomness

The player should see the roll and the frequencies.

```text
No black-box cheating.
No feeling that the NPC just knew.
```

## EV Over Outcome

The player is rewarded for good poker even when unlucky.

```text
Profit tells what happened.
EV tells whether it was good.
```

## Relics Bend Strategy

Relics should not just give generic bonuses. They should create new poker incentives.

```text
Bluff more.
Value bet thinner.
Trap.
Muck.
Show.
Overbet.
Short-stack jam.
```

## Table Image Is a Resource

The player can manipulate how enemies react.

```text
Show bluffs to get paid.
Show value to gain fold equity.
Muck to preserve mystery.
Show strong folds to invite bluffs.
```

## Stack Depth Creates Encounter Variety

Different stack depths create different puzzles.

```text
Short stack = shove/fold
Medium stack = standard poker
Deep stack = big river pressure
Asymmetric stack = survival or bullying
```
