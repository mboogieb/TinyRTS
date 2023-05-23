# TinyRTS
Fun little side project in Godot 4

# Controls
## Select unit
- LMB on unit to select.
- LMB + drag to select multiple units.

## Command unit
- RMB to command unit(s)

# Units
## Soldier
- Resource Costs: 5x wood, 5x stone
- Command: RMB on enemy to attack. Will fight to the death unless canceled.
- Spawns from: Barracks
- Press 'E' to start summon.

## Cleric
- Resource Costs: 6x wood, 6x stone
- Command: RMB on ground to move to location. Will heal friendly units within range.
- Spawns from: Priory
- Press 'Q' to start summon.

## Laborer
- Resource Costs: 3x wood, 3x stone
- Command: RMB on rock or tree to begin harvesting corresponding resource. Will continue to travel between selected resource and drop off until canceled or node is depleted.
- Spawns from: Tent
- Press 'W' to start summon

# Notes
- Building construction is not finished. Tap 'B' key repeatedly to complete construction for all buildings.
- Player team limits are in effect, but players can buffer the spawn queue. Buildings will produce a unit when team capacity and/or resources can support it.

## Coming Soon
- Laborer will also be able to construct buildings.
- Building construction will cost resources.
- Summon units from building UI panel.
- Buildings can be destroyed.
