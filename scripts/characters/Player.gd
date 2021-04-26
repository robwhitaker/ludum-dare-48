extends KinematicBody2D

export var recovery_seconds : float = 1

export var max_speed : float = 300
export var acceleration : float = 2000
export var friction : float = 2000

onready var animation_player := $AnimationPlayer as AnimationPlayer
onready var animation_tree := $AnimationTree as AnimationTree
onready var animation_state = animation_tree.get("parameters/playback")
onready var hurt_blink := $HurtBlink as AnimationPlayer
onready var hint := $Hint as Label
onready var hint_timer := $HintTimer as Timer
onready var catch_noise := $BoomerangCatch as AudioStreamPlayer
onready var hurt_noise := $Hurt as AudioStreamPlayer
onready var heal_noise := $Heal as AudioStreamPlayer

enum {
    MOVE,
    THROW
}

var state := MOVE
var velocity : Vector2 = Vector2.ZERO

var recovering := false
var can_spawn_boomerang := true

func _ready() -> void:
    Event.connect("hint_requested", self, "show_hint")
    Event.connect("bandaid_picked_up", self, "_on_Bandaid_picked_up")
    hint.hide()
    visible = true

func _physics_process(delta : float) -> void:
    match state:
        MOVE:
            _move_player(delta)

        THROW:
            _throw_boomerang()

func _move_player(delta : float) -> void:
    var move_direction := Vector2.ZERO
    move_direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
    move_direction.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
    move_direction = move_direction.normalized()

    animation_tree.set("parameters/Idle/blend_position", get_local_mouse_position().normalized())

    if move_direction == Vector2.ZERO:
        velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
    else:
        velocity += move_direction * acceleration * delta
        velocity = velocity.clamped(max_speed)
    velocity = move_and_slide(velocity)

func _throw_boomerang():
    pass

func _throw_finished() -> void:
    state = MOVE
    animation_state.travel("Idle")

func get_center() -> Vector2:
    return get_hurtbox().get_global_position()

func get_hurtbox() -> Area2D:
    return $Hurtbox as Area2D

func _unhandled_input(event : InputEvent) -> void:
    match state:
        MOVE:
            if ( event is InputEventMouseButton
             and event.button_index == BUTTON_LEFT
             and event.is_pressed()
             and can_spawn_boomerang ):
                 var boom = preload("res://scenes/items/Boomerang.tscn").instance()
                 boom.player = self
                 boom.set_position(get_center())
                 boom.move_direction = boom.get_position().direction_to(get_global_mouse_position())
                 boom.connect("returned", self, "_on_Boomerang_returned")
                 get_parent().add_child(boom)
                 can_spawn_boomerang = false

        THROW:
            pass

func _on_Boomerang_returned():
    can_spawn_boomerang = true
    catch_noise.play()

func _on_Hurtbox_area_entered(_area : Area2D) -> void:
    if !recovering:
        var new_hp : int = State.player_hp - 1
        hurt_noise.play()
        if new_hp <= 0:
            yield(get_tree().create_timer(0.5), "timeout")
        Event.emit_signal("player_hp_changed", State.player_hp, new_hp)
        State.player_hp = new_hp
        if new_hp <= 0:
            pass # TODO: game over or something
        else:
            recovering = true
            hurt_blink.play("recovery_blink")
            yield(get_tree().create_timer(recovery_seconds), "timeout")
            hurt_blink.stop()
            visible = true
            recovering = false

func _on_HintTimer_timeout():
    hint.hide()

func show_hint(text : String, duration : float) -> void:
    hint.set_text(text)
    hint.show()
    hint_timer.start(duration)

func _on_Bandaid_picked_up() -> void:
    heal_noise.play()
    var new_hp : int = State.player_hp + 1
    Event.emit_signal("player_hp_changed", State.player_hp, new_hp)
    State.player_hp = new_hp
