---
layout: default
title: CutsceneManager
parent: Classes
nav_order: 3
---

# CutsceneManager
**Inherits:** Node

A global coordinator for cinematic camera movements and player input suppression.

## Properties
| Type | Name | Description |
| :--- | :--- | :--- |
| bool | cutscene_active | Whether a cinematic is currently playing. Blocks player interaction. |
| Camera2D | cutscene_camera | The dedicated camera used for panning. |

## Methods
### void play_pan_to(Vector2 target, float hold_time)
Transitions the view from the player to a specific coordinate, waits for `hold_time`, and returns control.

### void return_to_player(float return_time)
Smoothly tweens the `cutscene_camera` back to the player's position and enables the `player_camera`.