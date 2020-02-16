extends GridContainer

onready var scroll_container = get_parent()

func _ready():
    reconnect()
    
func reconnect():
    for child in self.get_children():
        child.connect("focus_entered", self, "_on_focus_change")

func _on_focus_change():
    var focused = get_focus_owner()
    if self.get_child_count() > 0:
        # hardcoded the vseparation of the gridcontainer theme properties, because
        # there does not seem to be any way to determine the effective line height 
        # of a gridcontainer nor any way to access that theme properties' custom constant.
        var scroll_step = self.get_child(1).get_size().y + 4
        var focus_line = (focused.get_position_in_parent()-1) / self.columns
        var top_line = int(scroll_container.get_v_scroll() / scroll_step)
        var bottom_line = int(((scroll_container.get_size().y + scroll_container.get_v_scroll()) / scroll_step)+1)
        if focus_line <= top_line:
            scroll_container.set_v_scroll((top_line-2)*scroll_step)
        if focus_line >= bottom_line-1:
            scroll_container.set_v_scroll((top_line+2)*scroll_step)
