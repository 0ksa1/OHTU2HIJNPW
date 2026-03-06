#======================================================#
# Unit testit hahmolle
# HP, healthbar, Damage, Stamina, animaatiot
#======================================================#

# https://www.youtube.com/watch?v=h5HmdD0cAps
# hyvä video GUT:in alustukseen mitä käytin

#käyttää godot unit testiä
extends GutTest

#HP palkin alustus
class FakeHealthBar:
	var health: int = -1

#hahmo
class TestHero extends "res://scripts/player.gd":
	var die_called := false
	var hurt_called := false

	func die() -> void:
		if dead:
			return
		dead = true
		hurting = false
		die_called = true

	func play_hurt() -> void:
		if dead or hurting:
			return
		hurting = true
		hurt_called = true

var hero

#alustetaan pelaaja testeihin
func before_each() -> void:
	hero = TestHero.new()
	hero.healthbar = FakeHealthBar.new()
	hero.health = 100
	hero.max_hp = 100
	hero.dead = false
	hero.hurting = false
	#staminan alustus
	hero.sprint_energy = 1.0
	hero.sprint_regen_timer = 0.0
	hero.sprint_pressed = false
	hero.input_dir = Vector2.ZERO

#HP testit

# Testitapauksia:
# hp toimii - hp:ta liikaa - hp ei toimi - healthbar toimii
# kun hp 0 hahmo kuolee, kun hp > 0 hahmo ottaa vahinkoa
# heal toimii - ei toimi

func test_test_damage_reduces_health() -> void:
	hero._test_damage(30)
	assert_eq(hero.health, 70, "HP:n tulisi vähentyä")
	# true

func test_test_damage_reduces_wrong() -> void:
	hero._test_damage(30)
	assert_eq(hero.health, 60, "HP:n tulisi olla 70")
	#false

func test_heal () -> void:
	hero.health = 50
	hero.heal(30)
	assert_eq(hero.health, 80, "HP:n tulee nousta")
	#true

func test_heal_wrong() -> void:
	hero.health = 80
	hero.heal(20)
	assert_eq(hero.health, 90,"väärä lasku")
	#false

func test_heal_zero() -> void:
	hero.health = 60
	hero.heal(0)
	assert_eq(hero.health, 60, "HP ei muutu kun heal = 0")
	#true

func test_heal_negative() -> void:
	hero.health = 60
	hero.heal(-10)
	assert_eq(hero.health, 60, "Negatiivinen heal ei muuta HP:ta")
	#true

func test_damage_zero() -> void:
	hero._test_damage(0)
	assert_eq(hero.health, 100, "HP:n tulisi olla sama")
	# true

func test_damage_negative() -> void:
	hero._test_damage(-10)
	assert_eq(hero.health, 100,"HP:lle ei tulisi käydä mitään")
	# true
	# Tästä tuleekin false sillä damagen koodissa -10 tekee siitä positiivisen
	# -(-10) = 10, eli siitä tulee heal funktio.
	# voisi periaatteessa käydä jos esim jokin itemi/debuff asettaa damagen negatiiviseksi

#yli/ali menevät testit:

func test_heal_overflow() -> void:
	hero.health = 80
	hero.max_hp = 100
	hero.heal(999)
	
	assert_eq(hero.health, 100, "HP ei saa ylittää max_hp:tä")
	assert_eq(hero.healthbar.health, 100, "Healthbarin pitäisi myös olla maxissa")
	#true

func test_damage_underflow() -> void:
	hero.health = 10

	hero._test_damage(999)

	assert_eq(hero.health, 0, "HP ei saa mennä alle 0")
	assert_eq(hero.healthbar.health, 0, "Healthbar ei saa mennä alle 0")
	#true

#healthbar testaus

func test_heal_updates_healthbar() -> void:
	hero.health = 40
	hero.heal(10)
	assert_eq(hero.healthbar.health, 50, "healthbarin tulisi päivittyä")
	#true

#staminan testaus

func test_stamina_drains_when_sprinting_and_moving() -> void:
	# sprintin testaus, stamina vähentyy juostessa
	hero.input_dir = Vector2.RIGHT
	hero.sprint_pressed = true
	hero.sprint_energy = 1.0
	hero.sprint_drain_per_sec = 0.5

	hero._update_sprint_energy(1.0)

	assert_eq(hero.sprint_energy, 0.5, "Staminan pitäisi vähentyä")
	assert_eq(hero.sprint_regen_timer, hero.sprint_regen_delay, "regen delay pitäisi resetoitua sprintatessa")
	#true

func test_walk_speed() -> void:
	hero.walk_speed = 140.0
	hero.run_speed = 230.0
	hero.sprint_pressed = false
	hero.sprint_energy = 1.0

	assert_eq(hero._current_move_speed(), 140.0, "kävellessä menee hitaammin")
	#true

func test_sprint() -> void:
	hero.walk_speed = 140.0
	hero.run_speed = 230.0
	hero.sprint_pressed = true
	hero.sprint_energy = 1.0

	assert_eq(hero._current_move_speed(), 230.0, "juoksee sprintatessa")
	#true

func test_run_0_stamina() -> void:
	hero.walk_speed = 140.0
	hero.run_speed = 230.0
	hero.sprint_pressed = true
	hero.sprint_energy = 0.0

	assert_eq(hero._current_move_speed(), 140.0, "hahmo ei voi juosta kun staminaa ei ole")
	#true

func test_stamina_not_drain_if_not_moving() -> void:
	hero.input_dir = Vector2.ZERO
	hero.sprint_pressed = true
	hero.sprint_energy = 1.0
	hero._update_sprint_energy(1.0)
	assert_eq(hero.sprint_energy, 1.0, "hahmo ei liiku, staminan ei pitäisi kulua")
	#stamina alkaa vähentyä vasta kun sprint on pohjassa JA pelaaja liikkuu.
	#true

# Vielä kuolema ja hurt testit

func test_lethal_damage() -> void:
	hero._test_damage(100)
	assert_true(hero.dead, "hahmon hp = 0")
	assert_true(hero.die_called, "hahmo kuolee")
	assert_false(hero.hurt_called, "hahmon ei pitäisi vahingoittua kuolleena")
	#true


func test_hurt() -> void:
	hero._test_damage(1)
	assert_true(hero.hurt_called, "hurt kun hp > 0")
	assert_false(hero.die_called, "hahmon ei pidä kuolla")
	#true
