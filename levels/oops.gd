extends Node2D

func _ready():
    pass

func message(message):
    show()
    $Label.text = message
