---
layout: default
title: Inventory System
parent: Manual
nav_order: 6
---

# Inventory System

The Inventory system in *Echoes of the Keep* manages the collection, storage, and usage of items. It is split between world-space objects (`Area2D`) and a global data singleton (`Inventory.gd`).

## Item Interaction Flow
When a player overlaps with an item in the world, the `UpgradeItemPickup` script handles the logic.

1. **Detection:** The item detects the player via `body_entered`.
2. **Input:** The player must press the `interact` action.
3. **Logic Branch:**
   - If `is_inventory_item` is **true**: The item calls the `Inventory` singleton.
   - If `is_inventory_item` is **false**: The item acts as a "World Trigger" (e.g., a quest item that changes the scene).

## Inventory Singleton
The `Inventory` is a Global Autoload. It manages an array of `item_id` (StringNames).

### Adding Items
```gdscript
var added := Inventory.add_item(item_id)
if not added:
    print("Inventory full")