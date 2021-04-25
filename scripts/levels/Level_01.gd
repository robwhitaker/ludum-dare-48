extends Node2D

func _ready():
    Event.emit_signal("hint_requested", "Mom said my power cable was in a box of old toys...", 5)
    yield(get_tree().create_timer(3), "timeout")
    Event.emit_signal("hint_requested", "I'll just hit boxes with my boomerang 'til stuff comes out!", 5)
