extends Node
class_name GameState

var bombay: StateModel
var madras: StateModel
var hyperbad: StateModel
var punjab: StateModel
var bengal: StateModel
var maratha: StateModel
var delhi: StateModel
var mysore: StateModel

var seaWest: SeaModel
var seaEast: SeaModel
var seaSouth: SeaModel


func _init(
	bombay: StateModel,
	madras: StateModel,
	hyperbad: StateModel,
	punjab: StateModel,
	bengal: StateModel,
	maratha: StateModel,
	delhi: StateModel,
	mysore: StateModel,
	seaWest: SeaModel,
	seaEast: SeaModel,
	seaSouth: SeaModel
):
	self.bombay = bombay
	self.madras = madras
	self.hyperbad = hyperbad
	self.punjab = punjab
	self.bengal = bengal
	self.maratha = maratha
	self.delhi = delhi
	self.mysore = mysore

	self.seaWest = seaWest
	self.seaEast = seaEast
	self.seaSouth = seaSouth
