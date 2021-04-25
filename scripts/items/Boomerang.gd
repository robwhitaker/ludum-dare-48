extends KinematicBody2D

signal returned

export var max_speed : float = 320
export var travel_distance : float = 150
export var return_acceleration : float = 800

var player : KinematicBody2D

onready var animation_player := $AnimationPlayer as AnimationPlayer
onready var hit_wall_noise := $HitWall as AudioStreamPlayer2D

var move_direction := Vector2.RIGHT
var velocity := Vector2.ZERO
var elapsed_distance : float = 0

var returning := false

var last_wall_hit = null

func _ready():
    animation_player.play("Flying")

func _physics_process(delta : float) -> void:
    var current_position := get_position()
    var player_position : Vector2 = player.get_center()
    if returning:
        move_direction = get_position().direction_to(player_position)
    if !returning:
        velocity = move_direction * max_speed
    else:
        var distance_to_player := abs(current_position.distance_to(player_position))
        var acceleration = return_acceleration
        if distance_to_player < 80:
            acceleration *= 3
        velocity += move_direction * acceleration * delta
        velocity = velocity.clamped(max_speed)
    velocity = move_and_slide(velocity)
    for i in get_slide_count():
        var collider = get_slide_collision(i).collider
        if collider.is_in_group("Tilemap"):
            returning = true
            move_direction = get_position().direction_to(player_position)
            velocity = move_direction * max_speed
            if collider != last_wall_hit:
                hit_wall_noise.play()
            last_wall_hit = collider
            break


    if elapsed_distance >= travel_distance:
        returning = true
    else:
        elapsed_distance += abs(current_position.distance_to(get_position()))

func _on_Area2D_area_entered(area : Area2D):
    if area.get_parent() == player and returning:
        emit_signal("returned")
        queue_free()
    elif area.get_parent() != player:
        var dir_to_area := get_position().direction_to(area.get_global_position())
        velocity = dir_to_area.tangent().tangent() * max_speed
        returning = true
