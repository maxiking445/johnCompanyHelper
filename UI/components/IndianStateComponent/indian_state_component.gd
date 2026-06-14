@tool
extends Control

@export var title: String
@export var title_color: Color

@export var unrest_size: int
@export var armies_size: int
@export var hasGovenor: bool
@export var treasury_size: int

@onready var background_panel: PanelContainer = $"."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_ui()




func update_ui()-> void:
	


	$VBoxContainer/Title.title = title
	$VBoxContainer/Title.color = title_color
	$VBoxContainer/Unrest.amount = unrest_size
	$VBoxContainer/Armies.amount = armies_size
	$VBoxContainer/Govenor.isChecked = hasGovenor
	$VBoxContainer/Treasury.amount = treasury_size
	
	$VBoxContainer/Title.update_ui()
	$VBoxContainer/Unrest.update_ui()
	$VBoxContainer/Armies.update_ui()
	$VBoxContainer/Govenor.update_ui()
	$VBoxContainer/Treasury.update_ui()
