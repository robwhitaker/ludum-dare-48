extends Node2D

func _ready():
    Event.emit_signal("hint_requested", "Why do we even have this room? All the shelves are empty...", 5)
