class_name Layer
extends Node2D
## A part of the world's drawing, between other parts: `painter` draws on it.

var painter: Callable


func _draw() -> void:
	painter.call(self)
