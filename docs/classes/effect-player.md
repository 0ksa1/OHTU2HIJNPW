---
layout: default
title: EffectPlayer
parent: Classes
nav_order: 4
---

# EffectPlayer
**Inherits:** Node (Global Singleton)

A centralized manager for spawning short-lived visual effects. This ensures that effects like blood splatters or dust clouds are handled independently of the entities that created them.

## Methods

### void play_impact(pos: Vector2)
Instantiates the `IMPACT_VIOLET` scene at the specified global position.
- **Memory Management:** Automatically connects the `animation_finished` signal to `queue_free()` to prevent memory leaks.
- **Usage:** Called by the `Player` during a successful hit window.