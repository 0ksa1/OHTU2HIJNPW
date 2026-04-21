---
layout: default
title: Items & Progression
parent: Manual
nav_order: 6
---

# Items & Progression
Items in *Echoes of the Keep* are split into two categories: **Inventory Items** and **World Upgrades**.

## The UpgradeItemPickup Class
This script handles the interaction logic for objects in the world.

### Inventory Items
If `is_inventory_item` is enabled, the object will attempt to register itself with the `Inventory` singleton.
- **Example:** Potions, Teleport Flasks.
- **Full Inventory:** If the `Inventory.add_item()` returns `false`, the item remains in the world.

### Narrative/Scene Items
If `is_inventory_item` is disabled, the item acts as a "Trigger."
- **Dialogue:** Upon interaction, it pulls text from `item_dialogue1.json`.
- **Scene Change:** After the dialogue finishes, the game transitions to the `next_scene` defined in the inspector.