extends Node2D

onready var bg = $Background
onready var objects = $Objects

var WATER = -1
var LAND = 0

var PLAYER = 16
var WALL = 17
var EMPTY = -1

var undo_stack = []

func _ready():
    pass

func _input(event):
    if event.is_action_pressed("undo"):
        if len(undo_stack) > 0:
            objects.queue_free()
            objects = undo_stack.pop_back()
            add_child(objects)
        return
    
    if event.is_action_pressed("reset"):
        if len(undo_stack) > 0:
            objects.queue_free()
            objects = undo_stack[0].duplicate()
            add_child(objects)
        return
    
    var dir = Vector2(0, 0)
    if event.is_action_pressed("left"):
        dir = Vector2(-1, 0)
    if event.is_action_pressed("right"):
        dir = Vector2(1, 0)
    if event.is_action_pressed("up"):
        dir = Vector2(0, -1)
    if event.is_action_pressed("down"):
        dir = Vector2(0, 1)
    
    var player = objects.get_used_cells_by_id(PLAYER)[0]
    
    if dir != Vector2(0, 0) and is_land(player+dir):
        var old_state = objects.duplicate()
        if try_move(player, dir):
            undo_stack.push_back(old_state)
            if won():
                print("won")
                game.next_level()

func won():
    var pieces = []
    for id in range(16):
        pieces += objects.get_used_cells_by_id(id)
    
    for p in pieces:
        var id = objects.get_cellv(p)
        
        var right = (p+Vector2(1, 0)).round()
        var left = (p+Vector2(-1, 0)).round()
        var top = (p+Vector2(0, -1)).round()
        var bottom = (p+Vector2(0, 1)).round()
        
        var right_id = objects.get_cellv(right)
        var left_id = objects.get_cellv(left)
        var top_id = objects.get_cellv(top)
        var bottom_id = objects.get_cellv(bottom)
        
        if (id & 1 == 1 and (not is_piece(top) or top_id & 4 == 0)) or \
           (id & 2 == 2 and (not is_piece(right) or right_id & 8 == 0)) or \
           (id & 4 == 4 and (not is_piece(bottom) or bottom_id & 1 == 0)) or \
           (id & 8 == 8 and (not is_piece(left) or left_id & 2 == 0)):
            return false
    return true

func try_move(pos, dir):
    var to_move = []
    find_moves(pos, dir, to_move)
     
    for p in to_move:
        if is_wall(p+dir):
            return false
    
    if dir == Vector2(-1, 0):
        to_move.sort_custom(self, "left_to_right")
    if dir == Vector2(1, 0):
        to_move.sort_custom(self, "right_to_left")
    if dir == Vector2(0, -1):
        to_move.sort_custom(self, "top_to_bottom")
    if dir == Vector2(0, 1):
        to_move.sort_custom(self, "bottom_to_top")
        
    var moved = []
        
    for p in to_move:
        var t = objects.get_cellv(p)
        objects.set_cellv(p, EMPTY)
        objects.set_cellv(p+dir, t)
        moved.push_back(p+dir)
        
    while len(moved) > 0:
        var object = []
        find_object(moved[0], moved, object)
        var on_land = false
        for p in object:
            if is_land(p):
                on_land = true
        if not on_land:
            for p in object:
                objects.set_cellv(p, EMPTY)
    
    return true
    
func find_object(p, all, object):
    all.erase(p)
    object.push_back(p)
    var right = (p+Vector2(1, 0)).round()
    var left = (p+Vector2(-1, 0)).round()
    var top = (p+Vector2(0, -1)).round()
    var bottom = (p+Vector2(0, 1)).round()
    
    if all.has(right) and is_piece(right) and connected(p, right):
        find_object(right, all, object)
    if all.has(left) and is_piece(left) and connected(p, left):
        find_object(left, all, object)
    if all.has(top) and is_piece(top) and connected(p, top):
        find_object(top, all, object)
    if all.has(bottom) and is_piece(bottom) and connected(p, bottom):
        find_object(bottom, all, object)
    
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
    
func is_wall(pos):
    var id = objects.get_cellv(pos)
    return id == WALL

func is_land(pos):
    var id = bg.get_cellv(pos)
    return id == LAND

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
