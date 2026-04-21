---
layout: default
title: CollisionWorld
parent: Classes
nav_order: 5
---

# CollisionWorld
**Inherits:** Node2D

A helper utility used to toggle the visibility of collision geometry. 

## Properties
| Type | Name | Description |
| :--- | :--- | :--- |
| bool | hide_in_game | If `true`, the target node is hidden on `_ready()`. |
| NodePath | debug_node_path | The path to the TileMap containing collision data. |

## Why use this?
In the Godot Editor, it is helpful to see the collision shapes while painting levels. This script ensures those "ugly" shapes are automatically hidden when the game actually runs.