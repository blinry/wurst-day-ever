extends Node2D

onready var button = $Control/MarginContainer/GridContainer/Button
onready var grid = $Control/MarginContainer/GridContainer
onready var title = $Control/Label

func _ready():
    game.fade_in()
    title.text = "Pick a level:" if game.level_selector == "levels" else "Contributed levels:"
    button.hide()
    var n = 0
    for l in game.call(game.level_selector):
        var level = load(l)
        var b2 = button.duplicate()
        b2.text = str(n+1) + ": " + level.instance().name
        b2.connect("button_down", game, "load_level", [n])
        
        b2.show()
        grid.add_child(b2)
        n += 1
    add_levelset_button()
    select_current_level_button()
    
func add_levelset_button():
    var b3 = button.duplicate()
    b3.text = "contrib" if game.level_selector == "levels" else "back"
    b3.connect("button_down", self, "show_levelset", ["levels_contrib" if game.level_selector == "levels" else "levels"])
    b3.show()
    grid.add_child(b3)
    
func select_current_level_button():
    var active_button = grid.get_child(game.level+1)
    if active_button:
        active_button.grab_focus()
    else:
        grid.get_child(1).grab_focus()

func show_levelset(level_selector):
    game.level_selector = level_selector
    game.fade_out()
    yield(game, "faded_out")
    get_tree().change_scene("res://level_select.tscn")
    return

func _input(event):
    if event.is_action_pressed("quit"):
        pass#get_tree().quit()
        #get_tree().change_scene("res://title.tscn")
