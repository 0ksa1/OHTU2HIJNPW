---
layout: default
title: Dialogue & JSON
parent: Manual
nav_order: 7
---

# Dialogue & JSON System
Most interactions in the Keep trigger a text sequence. These are handled via the `Dialogue` node using external JSON files.

## JSON Structure
Dialogue files must follow this format to be parsed correctly:

```json
{
  "start": [
    {"text": "You found an old flask..."},
    {"text": "It echoes with a faint hum."}
  ]
}