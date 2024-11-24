extends Node2D

@export var chopping_time: float = 2.0
var is_being_cut: bool = false
var current_chop_time: float = 0.0
var is_chopped: bool = false
var is_gathered: bool = false

func chop(delta: float) -> void:
	if is_chopped:
		return
	$AnimatedSprite2D.play("being_cut")
	current_chop_time += delta
	if current_chop_time >= chopping_time:
		tree_cut()

func tree_cut() -> void:
	is_chopped = true
	$AnimatedSprite2D.play("chopped")

func _ready() -> void:
	$AnimatedSprite2D.play("idle")

func _process(delta: float) -> void:
	if is_chopped:
		return
	if is_being_cut == false:
		$AnimatedSprite2D.play("idle")
