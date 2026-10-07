extends Label

@export var notice_color := Color(0.18, 0.12, 0.08)
@export var default_font_size := 32
@export_range(0.0, 1.0) var default_opacity := 0.65

func configure(message: String, font_size: int, opacity: float = -1.0) -> void:
	text = message
	modulate = Color(notice_color, default_opacity if opacity < 0.0 else opacity)
	add_theme_font_size_override("font_size", font_size if font_size > 0 else default_font_size)
