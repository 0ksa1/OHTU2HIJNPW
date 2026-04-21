---
layout: default
title: Scene Management
parent: Manual
nav_order: 3
---

# Scene Management
We use a global transition system to move between the `game_scene` (Hub) and `dungeon_1`.

## Transition Process
1. **Trigger:** `_on_dungeon_bridge_1_body_entered` is called.
2. **Global State:** The `global.next_scene` variable is set.
3. **Camera Fix:** On load, `_force_game_camera()` is called deferred to ensure the camera tracks the player immediately after spawning.