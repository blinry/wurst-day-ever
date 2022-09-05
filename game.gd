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
            "headline"  : "Fan-made levels:",
            "authors"   : "anathem, overflo, lx242",
            "levels"    : [
                "res://levels/contrib/lx.tscn",
                "res://levels/contrib/overflo.tscn",
                "res://levels/contrib/catwalk.tscn",
                "res://levels/contrib/wurst.tscn",
                "res://levels/contrib/bridges.tscn",
                "res://levels/contrib/caldera.tscn",
                "res://levels/contrib/glitch.tscn",
                "res://levels/contrib/quantumleap.tscn",
                "res://levels/contrib/dungeon.tscn",
                "res://levels/contrib/glitchcopter.tscn",
                "res://levels/contrib/key.tscn",
            ]
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
