extends Node

var jukebox = preload("res://scenes/UI/Jukebox.tscn").instance()

var player_hp : int = 3

func _ready():
    add_child(jukebox)

func start_jukebox():
    jukebox.play()

func stop_jukebox():
    jukebox.stop()
