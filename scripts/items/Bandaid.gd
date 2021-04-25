extends Area2D

onready var animation_player := $AnimationPlayer as AnimationPlayer


func _ready():
    animation_player.play("Float")

func _on_Bandaid_area_entered(_area : Area2D) -> void:
    Event.emit_signal("bandaid_picked_up")
    queue_free()
