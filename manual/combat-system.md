---
layout: default
title: Combat System
parent: Manual
nav_order: 2
---

# Combat System
The combat in *Echoes of the Keep* relies on a buffered combo system and area-based hit detection.

## Multi-hit Timing
The player can chain attacks if the "attack" action is pressed within the `combo_chain_window`.

{: .note }
> Early clicks are ignored if `combo_early_click_ignored` is true to prevent button mashing.

## Hit Detection
Damage is dealt via `Area2D` overlapping checks. The system supports:
1. **Direct Body Hits:** For standard enemies.
2. **Hurtbox Hits:** For bosses or complex enemies with specific hit zones.