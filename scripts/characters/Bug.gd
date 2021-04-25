extends KinematicBody2D

export var hp : int = 3
export var recovery_seconds : float = 1.5
export var speed : float = 150

onready var recovery_animation := $RecoveryBlink as AnimationPlayer
onready var sprite := $Sprite as Sprite

onready var player := get_node("/root/Game/").find_node("Player") as KinematicBody2D

var overlapping_enemies := []

var velocity := Vector2.ZERO
var recovering : bool = true

func _ready():
    visible = true
    yield(get_tree().create_timer(0.5), "timeout")
    _play_walk_animation()
    recovering = false

func _physics_process(_delta : float) -> void:
    if !recovering:
        var movement_direction := get_global_position().direction_to(player.get_center()).normalized()
        for enemy_area2d in overlapping_enemies:
            var toward_enemy := get_global_position().direction_to(enemy_area2d.get_parent().get_global_position()).normalized()
            if ( get_global_position().distance_to(player.get_center())
               > enemy_area2d.get_parent().get_global_position().distance_to(player.get_center())
               ):
                velocity += toward_enemy.tangent() * speed
        velocity += movement_direction * speed
        velocity = velocity.clamped(speed)
        sprite.set_flip_h(velocity.x >= 0)
        velocity = move_and_slide(velocity)


func _on_HitHurtBox_area_shape_entered(_x, _y, _z, _p) -> void:
    if !recovering:
        hp -= 1
        if hp <= 0:
            queue_free()
        else:
            recovering = true
            call_deferred("_set_collision_disabled", true)
            recovery_animation.play("recovery_blink")
            _stop_walk_animation()
            yield(get_tree().create_timer(recovery_seconds), "timeout")
            recovery_animation.stop()
            visible = true
            recovering = false
            _play_walk_animation()
            call_deferred("_set_collision_disabled", false)

func _set_collision_disabled(disable : bool) -> void:
    $Hurtbox/CollisionShape2D.set_disabled(disable)
    $CollisionShape2D.set_disabled(disable)
    $Hitbox/CollisionShape2D.set_disabled(disable)

func _on_EnemyAversionBox_area_entered(area : Area2D) -> void:
    overlapping_enemies.push_back(area)

func _on_EnemyAversionBox_area_exited(area : Area2D) -> void:
    overlapping_enemies.erase(area)

func _play_walk_animation():
    var node = get_node_or_null("Walk")
    if node != null:
        node.play("Walk")

func _stop_walk_animation():
    var node = get_node_or_null("Walk")
    if node != null:
        node.stop()

func set_player(p : KinematicBody2D) -> void:
    player = p
