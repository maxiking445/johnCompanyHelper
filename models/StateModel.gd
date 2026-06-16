extends Node
class_name StateModel

var unrest_size: int
var armies_size: int
var hasGovenor: bool
var treasury_size: int


func _init(
	unrest_size: int,
	armies_size: int,
	has_governor: bool,
	treasury_size: int
):
	self.unrest_size = unrest_size
	self.armies_size = armies_size
	self.hasGovenor = has_governor
	self.treasury_size = treasury_size
