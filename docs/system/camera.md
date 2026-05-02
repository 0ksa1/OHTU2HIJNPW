# Camera
- manages primarly `Camera2D` viewport, centering target nodes (player)
- Uses a "Target" variable to determine who to follow
- Godot built-in `position_smoothing` is used
- is located in `/scenes/game_scene.tscn`
- relevant scripts are `global.gd`
- every scene has a script that moves the camera alonside player from scene to scene