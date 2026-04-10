#Loading Screen
- used when player teleports in/out of dungeon

consists of:
- main node
- `Sprite2D` called background1 that fills the screen
- `AnimatedSprite2D` called character that shows the mc running towards something
- `ProgressBar` that shows the download process of new scene in real time
- has a script called `loading.gd` in `res://scenes/loading.gd` that handles animation and download