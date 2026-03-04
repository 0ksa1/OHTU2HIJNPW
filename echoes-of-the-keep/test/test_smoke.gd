extends "res://addons/gut/test.gd"

# Smoke test: lataa ja instanssaa KAIKKI projektin .tscn-skenet.
# Tämä nappaa mm. korruptoituneet scene-tiedostot, puuttuvat resurssit,
# rikkinäiset script-polut ja monet merge-ongelmat.

func test_all_scenes_load_and_instantiate() -> void:
	var root := "res://"
	var scene_paths: Array[String] = []
	_collect_scene_paths(root, scene_paths)

	assert_true(scene_paths.size() > 0, "No .tscn scenes found to test.")

	var failures: Array[String] = []

	for path in scene_paths:
		var packed := load(path)
		if packed == null:
			failures.append("LOAD FAILED: " + path)
			continue

		if packed is PackedScene:
			var inst = (packed as PackedScene).instantiate()
			if inst == null:
				failures.append("INSTANTIATE FAILED: " + path)
				continue
			# Varmuuden vuoksi pois
			inst.queue_free()
		else:
			failures.append("NOT A PACKEDSCENE: " + path)

	if failures.size() > 0:
		# Tulostetaan kaikki kerralla, jotta CI-logista näkee nopeasti mikä hajosi.
		var msg := "Scene smoke test failures:\n- " + "\n- ".join(failures)
		assert_true(false, msg)


func _collect_scene_paths(dir_path: String, out_paths: Array[String]) -> void:
	var dir := DirAccess.open(dir_path)
	if dir == null:
		# Jos joku hakemisto ei ole saavutettavissa, ei kaadeta testiä tämän takia.
		return

	dir.list_dir_begin()
	while true:
		var name := dir.get_next()
		if name == "":
			break

		# Skipataan Godotin sisäiset/import-kansiot
		if name.begins_with("."):
			continue

		var full := dir_path.path_join(name)
		if dir.current_is_dir():
			# Skipataan myös .godot kansio jos se sattuu olemaan repo:ssa
			if name == ".godot":
				continue
			_collect_scene_paths(full, out_paths)
		else:
			if name.get_extension().to_lower() == "tscn":
				out_paths.append(full)

	dir.list_dir_end()