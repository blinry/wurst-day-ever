extends Node

signal faded_out
signal faded_in

var _file = "user://savegame.json"
var state = {}
var level
var _music_position
var levelset = 0

func _ready():
    load_state()
    level = 0

func _input(event):
    #if event.is_action_pressed("quit"):
        #get_tree().quit()
    if event.is_action_pressed("cheat"):
        next_level()
    if event.is_action_pressed("fullscreen"):
        OS.window_fullscreen = !OS.window_fullscreen
    if event.is_action_pressed("mute"):
        if $Music.playing:
            _music_position = $Music.get_playback_position()
            $Music.playing = false
        else:
            $Music.play()
            $Music.seek(_music_position)
    
func current_levelset():
    return levels()[levelset]
    
func current_levels():
    return current_levelset()["levels"]
    
func current_level():
    return current_levelset()["levels"][level]
    
func next_level():
    var levels = current_levels()
    level += 1
    level %= len(levels)
    fade_out()
    yield(self, "faded_out")
    get_tree().change_scene(levels[level % len(levels)])

func load_level(n):
    level = n-1
    next_level()

func list_levels(folder):
    var tscn_regex = RegEx.new()
    tscn_regex.compile("\\.tscn$")
    var levels = []
    var level_dir = Directory.new()
    level_dir.open(folder)
    level_dir.list_dir_begin(true)
    var level = level_dir.get_next()
    while level != "":
        if tscn_regex.search(level) and not ["template.tscn", "test.tscn"].has(level):
            levels.push_back("res://"+folder+"/"+level)
        level = level_dir.get_next()
    return levels

func levels():
    return [
        {
            "headline"  : "Pick a level:",
            "authors"    : "blinry",
            "levels"    : [
                "res://levels/title.tscn",
                "res://levels/first.tscn",
                "res://levels/noedges.tscn",
                "res://levels/shape.tscn",
                "res://levels/starfish.tscn",
                "res://levels/trap.tscn",
                "res://levels/mess.tscn",
                "res://levels/stick.tscn",
                "res://levels/rescue.tscn",
                "res://levels/ambush.tscn",
                "res://levels/toowide.tscn",
                "res://levels/twist.tscn",
                "res://levels/hook.tscn",
                "res://levels/doubletwist.tscn",
                "res://levels/sokoban.tscn",
            ]
        },
        {
            "headline"  : "Contributed levels:",
            "authors"   : "anathem, overflo, lx242",
            "levels"    : list_levels("levels/contrib")+list_levels("levels"),
        },
    ]
    
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

func fade_out():
    $AnimationPlayer.play("fadeout")
    yield($AnimationPlayer, "animation_finished")
    emit_signal("faded_out")

func fade_in():
    $AnimationPlayer.play("fadein")
    yield($AnimationPlayer, "animation_finished")
    emit_signal("faded_in")
