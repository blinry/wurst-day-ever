extends Node

var _file = "user://savegame.json"
var state = {}
var level

func _ready():
    load_state()
    print(levels())
    level = 0

func _input(event):
    if event.is_action_pressed("quit"):
        get_tree().quit()
    if event.is_action_pressed("cheat"):
        next_level()
    if event.is_action_pressed("fullscreen"):
        OS.window_fullscreen = !OS.window_fullscreen
    
func next_level():
    level += 1
    get_tree().change_scene("levels/"+levels()[level % len(levels())])
    print("changed to ", level)
    
func levels():
    var tscn_regex = RegEx.new()
    tscn_regex.compile("\\.tscn$")
    var levels = []
    var level_dir = Directory.new()
    level_dir.open("levels")
    level_dir.list_dir_begin(true)
    var level = level_dir.get_next()
    while level != "":
        if tscn_regex.search(level) and not ["template.tscn"].has(level):
            levels.push_back(level)
        level = level_dir.get_next()
    return levels
    
func _initial_state():
    return {}
    
func save_state() -> bool:
    var savegame = File.new()
    
    savegame.open(_file, File.WRITE)
    savegame.store_line(to_json(state))
    savegame.close()
    return true
    
func load_state() -> bool:
    var savegame = File.new()
    if not savegame.file_exists(_file):
        return false
    
    savegame.open(_file, File.READ)
    
    state = _initial_state()
    var new_state = parse_json(savegame.get_line())
    for key in new_state:
        state[key] = new_state[key]
    savegame.close()
    return true
