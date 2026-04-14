# Echoes of the Keep - Central hub

## Teema

-   Central hub kesäinen maisema
-   Ainakin yksi talo, joka raunioitunut
-   Tyttö NPC sijaitsee aina raunioituneen talon vieressä
-   Central hubin reuna-alueilla sijaitsee dungeonien sisäänpääsyt
-   Hyvin rauhallinen, eikä sisällä lainkaan dungeonien vihollisia

## How it works 
- created using `TileMapLayer` nodes
- visibility is based on the node's location on node tree
- has `Area2D` Dungeon_bridge_1 with a subnode `CollisionShape2D` portti. Used for player to teleport in dungeon 1
- `StaticBody2D` called collisions that handles world collisions
- `Node` cutsceneManager that handles a small cutscene after player interacts with girl and dungeon port opens

player node `CharacterBody2D` that includes the following: 
- `Camera2D`
- `Collision`
- `AnimatedSprite2D`called sprite
- `Node` audio with many `AudioStreamPlay2D`subnodes that bring audio effects such as chirping in hub
- `progressbar` nodes healthBar and StaminaBar
- `Area2D` calles AttackArea that has a subnode `CollisionShape2D`
