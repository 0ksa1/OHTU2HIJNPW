extends ProgressBar


@onready var timer = $Timer
@onready var damage_bar = $DamageBar

# hp:n asetus,tällä asetetaan arvo
var health = 0 : set = _set_health

func _set_health(new_health):
	var prev_health = health
	health = min(max_value, new_health)
	value = health
	
	# jos hp loppuu, poistetaan healthbar
	if health <= 0:
		queue_free()
	
	#jos otetaan damagea
	if health < prev_health:
		timer.start()
	
	#jos tulee hp:ta 
	else:
		pass

#hp bar:in alustus
func init_health(_health):
	health = _health
	max_value = health
	value = health
	damage_bar.max_value = health
	damage_bar.value = health

#timer, jotta health ei laske heti kun tulee damagea
func _on_timer_timeout() -> void:
	damage_bar.value = health
