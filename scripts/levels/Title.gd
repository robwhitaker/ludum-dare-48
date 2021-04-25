extends CanvasLayer

onready var animation_player := $AnimationPlayer as AnimationPlayer

func _ready() -> void:
    animation_player.play("StartBlink")

func _input(event : InputEvent) -> void:
    if event.is_action_pressed("ui_accept"):
        State.start_jukebox()
        get_tree().change_scene("res://scenes/levels/Level_01.tscn")
