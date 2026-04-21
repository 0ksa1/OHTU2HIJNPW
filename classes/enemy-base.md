---
layout: default
title: EnemyBase
parent: Classes
nav_order: 2
---

# EnemyBase
**Inherits:** CharacterBody2D

A state-machine based base class for all enemies (Rats, Bats, Slimes).

## States (Enum)
- **PATROL:** Moves between points.
- **CHASE:** Pursues the player upon detection.
- **ATTACK:** Executes hit logic when in range.
- **DEAD:** Disables collisions and plays death animation.

## Key Logic
- **Despawn:** Can be toggled via `despawn_on_death`.
- **Groups:** Automatically notifies the `spawn_controller` when a specific group (e.g., "rats") is wiped out.