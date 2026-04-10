# cutscene
- plays when the game is started

has the following  components:
- TextureRect - still image, plays for 2 seconds
- VideoStreamPlayer - starts playing the cutscene video after textureReact
- Camera2D  - to show the cutscene, it's own component not tied to other scenes
- ColorRect - black rectangle to fill in rest of camera space, set as below other nodes

## how it works
- Uses `AnimationPlayer` to control the scene actions
- after animation finishes, signal `animation_finished(anim_name: StringName)` is linked to `_on_animation_player_animation_finished` and the scene switches to `hub1.tscn`