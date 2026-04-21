---
layout: default
title: Visual Effects
parent: Manual
nav_order: 5
---

# Visual Effects System
To keep the game feel "juicy," we use a decoupled effect system. Instead of the Player or Enemy holding effect logic, they call the `EffectPlayer`.

## Impact Effects
Whenever a hit is confirmed in `_try_deal_damage()`, we call:
`EffectPlayer.play_impact(hit_position)`

{: .note }
This ensures that even if an enemy is deleted (queue_free) the frame it dies, its death or hit effect will continue to play until finished.