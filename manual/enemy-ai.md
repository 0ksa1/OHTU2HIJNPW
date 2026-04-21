---
layout: default
title: Enemy AI Logic
parent: Manual
nav_order: 7
---

# Enemy AI Logic
Enemies use a structured **State Machine** to decide behavior. 



## State Breakdown
1. **PATROL:** Moves back and forth within the `patrol_distance`.
2. **CHASE:** Triggered when the Player enters the `DetectArea`. The enemy increases speed to `chase_speed`.
3. **ATTACK:** Triggered when the Player enters the `AttackArea`. 
4. **DEAD:** Disables all monitoring areas and physics processing.

## Group Notifications
When an enemy dies, it checks if it belongs to a specific group (e.g., `"rats"`, `"slimes"`). 
If it is the **last** member of that group in the scene, it notifies the `spawn_controller` by setting `rats_dead = true`. This is often used to unlock doors or trigger events.