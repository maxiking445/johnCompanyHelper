class_name FormattedAction
extends Action


func configure(values: Dictionary) -> void:
	var formatted_display_text := text
	var has_highlighted_value := false
	for key in values:
		var value := str(values[key])
		value = value.replace("[", "[lb]").replace("]", "[rb]")
		var replacement := value
		if key != "message":
			replacement = "[color=#6E0E1F]%s[/color]" % value
			has_highlighted_value = true
		formatted_display_text = formatted_display_text.replace(
			"{%s}" % key, replacement
		)
	display_text = formatted_display_text if has_highlighted_value else ""
	_format_text(values)
