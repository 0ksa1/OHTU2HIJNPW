---
layout: default
title: UpgradeItemPickup
parent: Classes
---

# UpgradeItemPickup
**Inherits:** Area2D

Handles world-space pickups that either trigger a scene change (Progress Items) or enter the player's inventory.

## Key Logic
- **Inventory Integration:** Calls `Inventory.add_item(item_id)` if `is_inventory_item` is true.
- **Dialogue Trigger:** Uses `item_dialogue1.json` to describe the item before it is removed from the world.