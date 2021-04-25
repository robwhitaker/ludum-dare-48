extends StaticBody2D

export var spawn_on_break : bool
export var scene_to_spawn : PackedScene

export var hint_on_break : bool
export var hint_text : String
export var hint_duration : float = 3

onready var break_noise := $Break as AudioStreamPlayer2D

func _on_Hurtbox_area_entered(_area : Area2D) -> void:
    call_deferred("_handle_break")

func _handle_break() -> void:
    break_noise.play()
    yield(get_tree().create_timer(0.25), "timeout")
    if spawn_on_break:
        var spawn = scene_to_spawn.instance()
        spawn.set_position(get_position())
        get_parent().add_child(spawn)
    if hint_on_break:
        Event.emit_signal("hint_requested", hint_text, hint_duration)
    queue_free()
