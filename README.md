# TinyRTS
Fun little side project in Godot 4

# Controls
## Select unit
- LMB on unit to select.
- LMB + drag to select multiple units.
## Construct building
### Propose building site:
- 1: Build priory
- 2: Build tent
- 3: Build barracks
### Placement
- LMB on valid location
## Summon units
- Q: summon cleric
- W: summon laborer
- E: summon soldier
## Command unit
- RMB to command unit(s)

# Units
## Cleric
- Resource Costs: 6x wood, 6x stone
- Command: RMB on ground to move to location. Will heal friendly units within range.
- Spawns from: Priory
## Laborer
- Resource Costs: 3x wood, 3x stone
- Command: RMB on rock or tree to begin harvesting corresponding resource. Will continue to travel between selected resource and drop off until canceled or node is depleted.
- Spawns from: Tent
## Soldier
- Resource Costs: 5x wood, 5x stone
- Command: RMB on enemy to attack. Will fight to the death unless canceled.
- Spawns from: Barracks

# Buildings
## Priory
- Spawns clerics
- Construction costs: 10x wood, 10x stone
## Tent
- Spawns laborers
- Construcion costs: 20x wood, 20x stone
## Barracks
- Spawns soldiers
- Construction costs: 10x wood, 20x stone

# Notes
- Buildings now cost resources to build.
- Building construction is not finished. Tap 'B' key repeatedly to complete construction for all unfinished buildings.
- Player team limits are in effect, but players can buffer the spawn queue. Buildings will produce a unit when team capacity and/or resources can support it.
- Units can slowly heal by being near lit campfire

## Coming Soon
- Laborer will also be able to construct buildings.
- Ability to increase team capacity.
- Summon units from building UI panel.
- Buildings can be destroyed.
