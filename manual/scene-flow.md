---
layout: default
title: Scene Flow & Spawning
parent: Manual
nav_order: 4
---

# Scene Flow & Spawning
The game uses a global state to track player entry and exit points to ensure the player doesn't spawn in a wall when moving between maps.

## Spawn Logic
When a scene loads, it checks `global.current_scene`:
1. **Hub Load:** If coming from `dungeon_1`, the player is moved to `player_exit_dungeon_1_pos`.
2. **Dungeon Load:** The player is automatically snapped to the `Marker2D` named "Spawn."

{: .important }
> **Camera Initialization:** Because Godot's `Camera2D` can take a frame to settle, we use `call_deferred("_force_game_camera")` in `_ready()` to prevent visual "snapping" artifacts.

## Transitioning
Transitions are triggered by `Area2D` bridges.
- **Bridge Entered:** Sets `global.next_scene`.
- **Bridge Exited:** Cancels the transition (if applicable).