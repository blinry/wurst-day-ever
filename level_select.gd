extends Node2D

onready var button = $Control/ScrollContainer/GridContainer/Button
onready var grid = $Control/ScrollContainer/GridContainer
onready var title = $Control/Label
onready var next = $Control/NextLevelsetButton
onready var prev = $Control/PrevLevelsetButton
onready var author = $Control/LevelAuthorLabel

func _ready():
    game.fade_in()
    var current_levelset = game.current_levelset()
    title.text = current_levelset["headline"]
    #var clevel = load(game.current_level())
    #author.text = "Level by: " + clevel.instance().author
    button.hide()
    var n = 0
    for l in current_levelset["levels"]:
        print("Loading " + l)
        var level = load(l)
        var b2 = button.duplicate()
        b2.text = str(n+1) + ": " + level.instance().name
        b2.connect("button_down", game, "load_level", [n])
        
        b2.show()
        grid.add_child(b2)
        n += 1
    grid.reconnect()
    manage_levelset_buttons()
    select_current_level_button()

func manage_levelset_buttons():
    var levelsets = game.levels()
    prev.visible = !(game.levelset == 0)
    prev.connect("button_down", self, "show_levelset", [game.levelset-1])
    next.visible = !(game.levelset == len(levelsets)-1)
    next.connect("button_down", self, "show_levelset", [game.levelset+1])
    
func select_current_level_button():
    var active_button = grid.get_child(game.level+1)
    if active_button:
        active_button.grab_focus()
    else:
        grid.get_child(1).grab_focus()

func show_levelset(levelsetnum):
    game.levelset = levelsetnum
    game.level = 0
    game.fade_out()
    yield(game, "faded_out")
    get_tree().change_scene("res://level_select.tscn")
    return

func _input(event):
    if event.is_action_pressed("quit"):
        pass#get_tree().quit()
        #get_tree().change_scene("res://title.tscn")
