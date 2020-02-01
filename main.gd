extends Node2D

onready var bg = $Background
onready var objects = $Objects

var PLAYER = 16
var EMPTY = -1

var player

func _ready():
    player = objects.get_used_cells_by_id(PLAYER)[0]

func _input(event):
    var dir = Vector2(0, 0)
    if event.is_action_pressed("left"):
        dir = Vector2(-1, 0)
    if event.is_action_pressed("right"):
        dir = Vector2(1, 0)
    if event.is_action_pressed("up"):
        dir = Vector2(0, -1)
    if event.is_action_pressed("down"):
        dir = Vector2(0, 1)
    
    
    if dir != Vector2(0, 0):
        print("player: ", player)
        try_move(player, dir)
        player += dir
    #objects.set_cellv(player, EMPTY)
    #player += dir
    #objects.set_cellv(player, PLAYER)

func try_move(pos, dir):
    var to_move = []
    find_moves(pos, dir, to_move)
    
    if dir == Vector2(-1, 0):
        to_move.sort_custom(self, "left_to_right")
    if dir == Vector2(1, 0):
        to_move.sort_custom(self, "right_to_left")
    if dir == Vector2(0, -1):
        to_move.sort_custom(self, "top_to_bottom")
    if dir == Vector2(0, 1):
        to_move.sort_custom(self, "bottom_to_top")
        
    print(to_move)
        
    for p in to_move:
        var t = objects.get_cellv(p)
        objects.set_cellv(p, EMPTY)
        objects.set_cellv(p+dir, t)

func left_to_right(a, b):
    return a.x <= b.x
func right_to_left(a, b):
    return a.x >= b.x
func top_to_bottom(a, b):
    return a.y <= b.y
func bottom_to_top(a, b):
    return a.y >= b.y
    
func find_moves(pos, dir, to_move):
    to_move.push_back(pos)
    var front = (pos+dir).round()
    var back = (pos-dir).round()
    var right = (pos+dir.rotated(PI/2)).round()
    var left = (pos+dir.rotated(-PI/2)).round()
    print("front: ", front)
    print("right: ", right)
    print("left: ", left)
    
    if is_piece(front) and (not to_move.has(front)):
        find_moves(front, dir, to_move)
    if is_piece(back) and (not to_move.has(back)) and connected(pos, back):
        find_moves(back, dir, to_move)
    if is_piece(left) and (not to_move.has(left)) and connected(pos, left):
        find_moves(left, dir, to_move)
    if is_piece(right) and (not to_move.has(right)) and connected(pos, right):
        find_moves(right, dir, to_move)
    
func is_piece(pos):
    var id = objects.get_cellv(pos)
    return id >= 0 and id <= 15

func connected(p1, p2):
    var id1 = objects.get_cellv(p1)
    var id2 = objects.get_cellv(p2)
    
    if p1.x == p2.x and p1.y == p2.y+1:
        return id1 & 1 == 1 and id2 & 4 == 4
    if p1.x == p2.x and p1.y == p2.y-1:
        return id2 & 1 == 1 and id1 & 4 == 4
    if p1.y == p2.y and p1.x == p2.x+1:
        return id1 & 8 == 8 and id2 & 2 == 2
    if p1.y == p2.y and p1.x == p2.x-1:
        return id2 & 8 == 8 and id1 & 2 == 2
    
    return false
