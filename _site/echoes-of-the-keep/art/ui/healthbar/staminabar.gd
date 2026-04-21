#Stamina palkille arvot
#päivitetään UI arvoja staminapalkille

extends ProgressBar


func set_stamina(current: float, maxStamina: float) -> void:
	max_value = maxStamina
	value = current
