extends Node2D

func _ready():
    Event.emit_signal("hint_requested", "Do I hear... buzzing?", 3)
