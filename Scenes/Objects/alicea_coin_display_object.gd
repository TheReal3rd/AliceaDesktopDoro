extends Control

@onready var coinLabel = $CoinLabel
@onready var global = get_node("/root/Global")

func _process(delta: float) -> void:
	coinLabel.set_text("Alicea Coin: %d" % global.getDoroNode().getCoins())
