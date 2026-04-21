---
layout: default
title: Introduction
nav_order: 1
---

# Introduction to Echoes of the Keep

Welcome to the official developer documentation for **Echoes of the Keep**. This project is a 2D Top-Down Action-RPG built in Godot 4, focusing on atmospheric exploration, rhythmic combat, and environmental storytelling.

## Project Vision
The Keep is not just a setting; it is a character. The documentation here is designed to help contributors understand the technical systems that breathe life into this world.

### Key Pillars
- **Impactful Combat:** Utilizing a multi-hit combo system and "juice" via the `EffectPlayer`.
- **Seamless Exploration:** A global scene-transition system that maintains player state between the Hub and Dungeons.
- **Narrative Depth:** Integration of a JSON-based dialogue system for items and world events.

## How to use this Manual
- **[Manual](./manual/introduction):** Start here if you are a Designer or Writer. This section covers high-level concepts like Scene Flow and Combat.
- **[Classes](./classes/player):** Start here if you are a Programmer. This is a technical API-style reference of every GDScript in the project.

{: .note }
> Looking for the latest build instructions? Check the [Installation Guide](./manual/getting-started).

## Contributing
When adding new features, please ensure you update the relevant class documentation. We aim for a "Code First, Document Second" workflow to keep our technical debt low.

## 📖 Core Manual
- [Combat & Combos](./combat-system)
- [Scene Transitions](./scene-flow)
- [Visual Effects](./effect-system)
- [Enemy AI Behavior](./enemy-ai)
- [Items & Pickups](./progression-items)