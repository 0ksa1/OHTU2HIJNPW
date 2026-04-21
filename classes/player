---
layout: default
title: Player
parent: Classes
nav_order: 1
---

# Player
**Inherits:** CharacterBody2D

The main entity controlled by the player. Handles movement, stamina-based sprinting, and a multi-hit combo system.

## Properties
| Type | Name | Description |
| :--- | :--- | :--- |
| float | walk_speed | Base movement speed (Default: 140.0) |
| float | run_speed | Sprinting movement speed (Default: 230.0) |
| float | sprint_drain | Stamina cost per second of sprinting. |

## Methods
### void _try_deal_damage()
Checks the `attack_area` for overlapping bodies in the "enemy" group. Applies damage once per target per hit-window.