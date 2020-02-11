extends Node2D

onready var bg = $Background
onready var objects = $Objects

var WATER = -1
var LAND = 0

var PLAYER = 16
var WALL = 17
var EMPTY = -1

var undo_stack = []

var lost = false
var prev_object_count = -1

var swipe_start

func _ready():
    $Name/Label.text = name
    game.fade_in()

func _input(event):
    if event.is_action_pressed("click"):
        swipe_start = get_global_mouse_position()
    if event.is_action_released("click"):
        swipe(swipe_start, get_global_mouse_position())
        
    if event.is_action_pressed("quit"):
        game.fade_out()
        yield(game, "faded_out")
        get_tree().change_scene("res://level_select.tscn")
        return
    if event.is_action_pressed("undo"):
        if len(undo_stack) > 0:
            objects.queue_free()
            objects = undo_stack.pop_back()
            add_child(objects)
            unoops()
        return
    
    if event.is_action_pressed("reset"):
        if len(undo_stack) > 0:
            objects.queue_free()
            objects = undo_stack[0].duplicate()
            add_child(objects)
            unoops()
        return
        
    if lost:
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
    move(dir)

func move(dir): 
    var player = objects.get_used_cells_by_id(PLAYER)[0]
    
    if dir != Vector2(0, 0) and is_land(player+dir):
        var old_state = objects.duplicate()
        if try_move(player, dir):
            $Step.position = objects.map_to_world(player)
            $Step.pitch_scale = rand_range(0.8, 1.2)
            $Step.play()
            var d = preload("res://dust.tscn").instance()
            d.position = objects.map_to_world(player) + Vector2(16, 16)/2 + objects.position
            d.rotation = dir.angle()+PI
            add_child(d)
            d.emitting = true
            undo_stack.push_back(old_state)
            if won():
                $AnimationPlayer.play("win")
                set_process_input(false)
                var c = preload("res://confetti.tscn").instance()
                add_child(c)
                yield($AnimationPlayer, "animation_finished")
                game.next_level()

func won():
    if lost:
        return false # duh
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
    
    var all = []
    for id in range(16):
        all += objects.get_used_cells_by_id(id)
    
    var object_count = 0
    
    while len(all) > 0:
        var object = []
        find_object(all[0], all, object)
        var on_land = false
        for p in object:
            if is_land(p):
                on_land = true
        if not on_land:
            for p in object:
                objects.set_cellv(p, EMPTY)
            oops("You pushed a piece into the water!")
            $Drop.position = objects.map_to_world(object[0])
            $Drop.play()
        object_count += 1
    
    if object_count < prev_object_count and prev_object_count > 0:
        $Snap.position = objects.map_to_world(pos)
        $Snap.play()
    
    prev_object_count = object_count
    
    return true
    
func oops(message):
    $Oops.message(message)
    lost = true
    
func unoops():
    $Oops.hide()
    lost = false
    
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

func swipe(from, to):
    print(from, to)
    var d = to-from
    if d.length() < 8:
        return
        
    var h = abs(d.x)
    var v = abs(d.y)
    
    if h > 2*v:
        move(Vector2(sign(d.x), 0))
    elif v > 2*h:
        move(Vector2(0, sign(d.y)))
    else:
        pass # ignore this swipe
