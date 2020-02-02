extends Node2D

onready var button = $Control/MarginContainer/GridContainer/Button
onready var grid = $Control/MarginContainer/GridContainer

func _ready():
    button.hide()
    var n = 0
    for l in game.levels():
        print(l)
        var level = load(l)
        var b2 = button.duplicate()
        b2.text = str(n+1) + ": " + level.instance().name
        b2.connect("button_down", game, "load_level", [n])
        
        b2.show()
        grid.add_child(b2)
        n += 1
    grid.get_child(game.level+1).grab_focus()

func _input(event):
    if event.is_action_pressed("quit"):
        get_tree().quit()
        #get_tree().change_scene("res://title.tscn")
