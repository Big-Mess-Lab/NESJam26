@tool
extends EditorScript

const ROOT_DIR := "res://assets/sfx/"
const RECURSIVE := true
const OVERWRITE := true
const AUDIO_EXTS := ["wav", "ogg", "mp3"]

var _name_re := RegEx.new()

func _run() -> void:
	_name_re.compile("^(?<base>.+)_(?<num>\\d+)$")
	
	var dirs := _collect_dirs(ROOT_DIR)
	var made := 0
	var skipped := 0
	
	for dir_path in dirs:
		var groups := _group_audio_in_dir(dir_path)
		for base_name in groups:
			var files: Array = groups[base_name]
			files.sort()
	
			var out_path := dir_path.path_join(base_name + ".tres")
			if not OVERWRITE and ResourceLoader.exists(out_path):
				print("SKIP (exists): ", out_path)
				skipped += 1
				continue
			
			var randomizer := AudioStreamRandomizer.new()
			for f in files:
				var stream := load(f) as AudioStream
				if stream == null:
					push_warning("Could not load as AudioStream: " + f)
					continue
				randomizer.add_stream(-1, stream)
			
			if randomizer.streams_count == 0:
				push_warning("No valid streams for group '%s' in %s" % [base_name, dir_path])
				continue
			
			var err := ResourceSaver.save(randomizer, out_path)
			if err == OK:
				print("MADE (%d streams): %s" % [randomizer.streams_count, out_path])
				made += 1
			else:
				push_error("Failed to save %s (error %d)" % [out_path, err])
	
	EditorInterface.get_resource_filesystem().scan()
	print("\nDone. Created %d randomizer(s), skipped %d." % [made, skipped])

func _collect_dirs(root: String) -> Array[String]:
	var result: Array[String] = [root]
	if not RECURSIVE:
		return result
	
	var da := DirAccess.open(root)
	if da == null:
		push_error("Cannot open directory: " + root)
		return result
	
	da.list_dir_begin()
	var entry := da.get_next()
	while entry != "":
		if da.current_is_dir() and not entry.begins_with("."):
			var sub := root.path_join(entry)
			result.append_array(_collect_dirs(sub))
		entry = da.get_next()
	da.list_dir_end()
	return result

func _group_audio_in_dir(dir_path: String) -> Dictionary:
	var groups := {}
	var da := DirAccess.open(dir_path)
	if da == null:
		return groups
	
	da.list_dir_begin()
	var entry := da.get_next()
	while entry != "":
		if not da.current_is_dir():
			var ext := entry.get_extension().to_lower()
			if AUDIO_EXTS.has(ext):
				var stem := entry.get_basename()
				var m := _name_re.search(stem)
				if m != null:
					var base: String = m.get_string("base")
					var full := dir_path.path_join(entry)
					if not groups.has(base):
						groups[base] = []
					groups[base].append(full)
		entry = da.get_next()
	da.list_dir_end()
	return groups
