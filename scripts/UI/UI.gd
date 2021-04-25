extends CanvasLayer

onready var bandaids_container := $Health/HBoxContainer/Bandaids as HBoxContainer

onready var game_over := $GameOver as MarginContainer
onready var game_over_jk := $GameOver/JustKidding as MarginContainer
onready var game_over_continue := $GameOver/Continue as Label

onready var game_win := $GameWin as MarginContainer

var bandaid_icon = preload("res://scenes/UI/BandaidIcon.tscn")

var can_continue := false

func _ready():
    Event.connect("player_hp_changed", self, "_player_hp_changed")
    Event.connect("game_win", self, "_game_win")
    set_hp(0, State.player_hp)

func set_hp(old_hp : int, hp : int) -> void:
    if hp <= 0:
        _game_over()
    var hp_diff := hp - old_hp
    if hp_diff < 0 and bandaids_container.get_child_count() > 0:
        for _i in range(abs(hp_diff)):
            bandaids_container.get_child(0).queue_free()
    elif hp_diff > 0:
        for _i in range(hp_diff):
            bandaids_container.add_child(bandaid_icon.instance())

func _player_hp_changed(old_hp : int, new_hp : int) -> void:
    set_hp(old_hp, new_hp)

func _input(event : InputEvent) -> void:
    if event.is_action_pressed("ui_accept") and can_continue:
        _go_to_title()

func _game_over() -> void:
    get_tree().paused = true
    game_over.show()
    yield(get_tree().create_timer(1.5), "timeout")
    game_over_jk.show()
    game_over_continue.show()
    can_continue = true

func _game_win() -> void:
    game_win.show()
    can_continue = true

func _go_to_title():
    State.stop_jukebox()
    get_tree().paused = false
    State.player_hp = 3
    get_tree().change_scene("res://scenes/Title.tscn")
