extends Area2D

export var next_level : int

func _on_Teleporter_area_entered(area : Area2D) -> void:
    var entering_from_above := area.get_global_position().y < get_global_position().y
    var all_boxes_opened := len(get_tree().get_nodes_in_group("Box")) < 1
    var no_enemies_left := len(get_tree().get_nodes_in_group("Enemy")) == 0
    if entering_from_above and all_boxes_opened and no_enemies_left:
        if next_level == -1:
            Event.emit_signal("game_win")
        else:
            var level_string := ""
            if len(str(next_level)) < 2:
                level_string = "0" + str(next_level)
            var scene_string := "res://scenes/levels/Level_" + level_string + ".tscn"
            get_tree().change_scene(scene_string)
    else:
        if !all_boxes_opened:
            Event.emit_signal("hint_requested", "I should check all the boxes first...", 3)
        elif !no_enemies_left:
            Event.emit_signal("hint_requested", "I probably shouldn't just leave these dangerous bugs around...", 4)
