extends Control

@onready var coinLabel = $CoinLabel
@onready var coinTexture = $MarginContainer/CoinTexture
@onready var global = get_node("/root/Global")

func _ready() -> void:
	coinTexture.play("default")

func _process(delta: float) -> void:
	coinLabel.set_text("Alicea Coin: %d" % global.getDoroNode().getCoins())
