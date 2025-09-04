extends Window

@onready var plate1 = $Control/Plate1
@onready var plate1Texture = $Control/Plate1/plateContent
@onready var plate1Text = $Control/Plate1/Label1
@onready var plate1Button = $Control/Plate1/TextureButton1

@onready var plate2 = $Control/Plate2
@onready var plate2Texture = $Control/Plate2/plateContent
@onready var plate2Text = $Control/Plate2/Label2
@onready var plate2Button = $Control/Plate2/TextureButton2

@onready var plate3 = $Control/Plate3
@onready var plate3Texture = $Control/Plate3/plateContent
@onready var plate3Text = $Control/Plate3/Label3
@onready var plate3Button = $Control/Plate3/TextureButton3

@onready var aliceaDoro = $AliceaDoroObject

@onready var optionsMenuScene = load("res://Scenes/OptionsMenu.tscn")
@onready var global = get_node("/root/Global")

const saveDataPath: String = "user://feedItData.json"

var mealsList = [
	# Name, Description, Happiness Level, Feed Level, Texture Path, EffectEnum default None.
	MealObject.new("Beans Cane", "Cane of keinze beans", 25, 35, "res://Assets/Meals/BeansCane.png"),
	MealObject.new("Black Mass", "Mug full of burn't mass at the bottom. Was suppose to be soup?", -20, 1, "res://Assets/Meals/BlackMass.png", MealObject.effectsEnum.HatingIt),
	MealObject.new("Carrot Cake", "Carrot cake that is made of vegan ingrediants.", 30, 40, "res://Assets/Meals/CarrotCake.png"),
	MealObject.new("Cheese Pizza", "Cheese pizza sourced from natural ingrediants.", 45, 30, "res://Assets/Meals/CheesePizza.png", MealObject.effectsEnum.LovingIt),
	MealObject.new("Mushrooms", "Locally sourced mushrooms from the local supermarket.", 25, 30, "res://Assets/Meals/EdableMushrooms.png", MealObject.effectsEnum.LovingIt),
	MealObject.new("Mushroom Pizza", "Cheesy pizza with mmushroom toppings.", 50, 35, "res://Assets/Meals/MushroomPizza.png", MealObject.effectsEnum.LovingIt),
	MealObject.new("Red Velvet Cake", "Fancy red velvet cake.", 30, 40, "res://Assets/Meals/RedVelvetCake.png"),
	MealObject.new("Brocolie", "Little brocoli tree...", 15, 25, "res://Assets/Meals/Brocolie.png", MealObject.effectsEnum.LovingIt),
	MealObject.new("Uranium-235", "Uranium-235 locally sourced from the local powerplant. Wait... How this here?", 40, 5, "res://Assets/Meals/Uranium235.png", MealObject.effectsEnum.EvilPlan),
	MealObject.new("Cat Food", "Caned cat food. It's for the cat.", 15, 25, "res://Assets/Meals/CatFoodCane.png", MealObject.effectsEnum.HatingIt),
	MealObject.new("Dog Food", "Caned dog food. It's for the dog.", 15, 25, "res://Assets/Meals/DogFoodCane.png", MealObject.effectsEnum.HatingIt),
	MealObject.new("Milk Chocolate", "Nice and cold cup of milk chocolate.", 45, 35, "res://Assets/Meals/MilkChocolate.png", MealObject.effectsEnum.LovingIt),
	MealObject.new("Hot Chocolate", "Warm mug of hot chocolate.", 35, 30, "res://Assets/Meals/HotChocolate.png", MealObject.effectsEnum.LovingIt),
	MealObject.new("Milk Chocolates", "Handfull of milk chocolate bars.", 15, 25, "res://Assets/Meals/MilkChocolates.png", MealObject.effectsEnum.LovingIt),
	MealObject.new("Dark Chocolates", "Dark chocolate bar.", 30, 25, "res://Assets/Meals/DarkChocolate.png", MealObject.effectsEnum.LovingIt),
	MealObject.new("Mushrooms", "Locally sourced mushrooms that have a slite discolouring on them.", -20, 25, "res://Assets/Meals/MagicMushrooms.png", MealObject.effectsEnum.Psychedelic),
	MealObject.new("Strawberries", "Locally sourced strawberries.", 25, 35, "res://Assets/Meals/Strawberries.png", MealObject.effectsEnum.LovingIt),
	MealObject.new("Appls", "Plate of 3 locally sourced appls.", 20, 10, "res://Assets/Meals/Appls.png"),
	MealObject.new("Fish", "3 Fish that have been dragged out the fish tank from the store next door.", -25, 5, "res://Assets/Meals/Fish.png", MealObject.effectsEnum.HatingIt),
	MealObject.new("Borger", "Made and prepared by a local resturant McResenfor's.", -45, 5, "res://Assets/Meals/Borger.png", MealObject.effectsEnum.HatingIt),
]

var plate1Meal: MealObject = null
var plate2Meal: MealObject = null
var plate3Meal: MealObject = null
var selectedMeal: MealObject = null

enum PlateSideEnum { Undecided, Left, Middle, Right }
var plateSide: PlateSideEnum = PlateSideEnum.Undecided
var plateAnimationComplete: bool = false
var doroAnimationComplete: bool = false
var rewardGiven: bool = false
var closeDelay: TimeDelay = TimeDelay.new()
var animationSpeed: float = 8.0

var reRollCost: int = 20

func _ready() -> void:
	readFoodItemData()

func distance(fromX, toX) -> float:
	return sqrt((fromX - toX) * (fromX - toX))
	
func hideText(delta) -> void:
	plate1Text.modulate.a = lerp(plate1Text.modulate.a, 0.0, animationSpeed * delta)
	plate2Text.modulate.a = lerp(plate2Text.modulate.a, 0.0, animationSpeed * delta)
	plate3Text.modulate.a = lerp(plate3Text.modulate.a, 0.0, animationSpeed * delta)
	
func runAnimation(plateNode1, plateNode2, chosenPlate, delta) -> void:
	hideText(delta)
	plateNode1.modulate.a = lerp(plateNode1.modulate.a, 0.0, animationSpeed * delta)
	plateNode2.modulate.a = lerp(plateNode2.modulate.a, 0.0, animationSpeed * delta)
			
	if plateNode1.modulate.a <= 0.0001:
		var destXpos = (500.0 / 2 - (chosenPlate.get_texture().get_size().x / 2))
		chosenPlate.position.x = lerp(chosenPlate.position.x, destXpos, animationSpeed * delta)
		if distance(chosenPlate.position.x, destXpos) <= 0.9:
			plateAnimationComplete = true
	else:
		plateNode1.modulate.a = lerp(plateNode1.modulate.a, 0.0, animationSpeed * delta)
		plateNode2.modulate.a = lerp(plateNode2.modulate.a, 0.0, animationSpeed * delta)
	
func _physics_process(delta: float) -> void:
	if plateAnimationComplete:
		if doroAnimationComplete:
			aliceaDoro.setAnimation(aliceaDoro.animations.Eating)
			if not rewardGiven:
				var doroNode = global.getDoroNode()
				doroNode.changeHungyLevel(-selectedMeal.getHungyAmount())
				doroNode.changeHappinessScore(selectedMeal.getHappinessAmount())
				match selectedMeal.getEffect():
					MealObject.effectsEnum.HatingIt:
						doroNode.veryAngyDoro()
					MealObject.effectsEnum.LovingIt:
						doroNode.veryHappyDoro()
					MealObject.effectsEnum.Psychedelic:
						doroNode.psychedlicDoro()
					MealObject.effectsEnum.EvilPlan:
						doroNode.evilLaughDoro()
				rewardGiven = true
			if closeDelay.hasPassed(5):
				reRollCost = 20
				generateRandomMeals()
				writeFoodItemsData()
				queue_free()
			return
		
		var destYPos: float = (500.0 / 2) - (112.0 / 2)
		aliceaDoro.position.y = lerp(aliceaDoro.position.y, destYPos, 3.0 * delta)
		var destXPos: float = (500.0 / 2) - (112.0 / 2)  + 150.0
		aliceaDoro.position.x = lerp(aliceaDoro.position.x, destXPos, 3.0 * delta)
		if distance(aliceaDoro.position.y, destYPos) <= 0.9 and distance(aliceaDoro.position.x, destXPos) <= 0.9:
			doroAnimationComplete = true
	else:
		match plateSide:
			PlateSideEnum.Left:
				runAnimation(plate2, plate3, plate1, delta)
			PlateSideEnum.Middle:
				runAnimation(plate1, plate3, plate2, delta)
			PlateSideEnum.Right:
				runAnimation(plate1, plate2, plate3, delta)

func _on_close_requested() -> void:
	queue_free()

func _on_texture_button_1_pressed() -> void:
	plateSide = PlateSideEnum.Left
	selectedMeal = plate1Meal

func _on_texture_button_2_pressed() -> void:
	plateSide = PlateSideEnum.Middle
	selectedMeal = plate2Meal

func _on_texture_button_3_pressed() -> void:
	plateSide = PlateSideEnum.Right
	selectedMeal = plate3Meal
	
func writeFoodItemsData() -> void:
	var file = FileAccess.open(saveDataPath, FileAccess.WRITE)
	var data : Dictionary = {
		"meal1" : plate1Meal.getMealName(),
		"meal2" : plate2Meal.getMealName(),
		"meal3" : plate3Meal.getMealName(),
		"cost" : reRollCost
	}
	if file:
		var jsonString = JSON.stringify(data)
		file.store_string(jsonString)
		file.close()
		print("FeedIt Data Saved.")

func readFoodItemData() -> void:
	if not FileAccess.file_exists(saveDataPath):
		generateRandomMeals()
		writeFoodItemsData()
		print("No FeedIt Data Saved.")
		return
		
	var file = FileAccess.open(saveDataPath, FileAccess.READ)
	if file:
		var jsonString: String = file.get_as_text()
		var parsed = JSON.parse_string(jsonString)
		var data: Dictionary = {}
		if typeof(parsed) == TYPE_DICTIONARY:
			data = parsed
			print("FeedIt Data loaded: ", data)
		else:
			printerr("Error: The Save file is not a dictionary.")
		file.close()
		
		handleSaveData(data)
		
func getFoodByName(name: String):
	for item in mealsList:
		if name.to_lower() == item.getMealName().to_lower():
			return item
	return "none"
	
func generateRandomMeals():
	randomize()
	var index1: int = randi_range(0, mealsList.size() - 1)
	plate1Meal = mealsList[index1]
	plate1Texture.set_texture(plate1Meal.getMealTexture())
	plate1Button.set_tooltip_text(plate1Meal.getMealDescription())
	plate1Text.set_text(plate1Meal.getMealName())
	randomize()
	var index2: int = randi_range(0, mealsList.size() - 1)
	while index2 == index1:
		index2 = randi_range(0, mealsList.size() - 1)
	plate2Meal = mealsList[index2]
	plate2Texture.set_texture(plate2Meal.getMealTexture())
	plate2Button.set_tooltip_text(plate2Meal.getMealDescription())
	plate2Text.set_text(plate2Meal.getMealName())
	randomize()
	var index3: int = randi_range(0, mealsList.size() - 1)
	while index3 == index1 or index3 == index2:
		index3 = randi_range(0, mealsList.size() - 1)
	plate3Meal = mealsList[index3]
	plate3Texture.set_texture(plate3Meal.getMealTexture())
	plate3Button.set_tooltip_text(plate3Meal.getMealDescription())
	plate3Text.set_text(plate3Meal.getMealName())
		
func handleSaveData(data:Dictionary) -> void:
	for name in ["meal1", "meal2", "meal3"]:
		if data.has(name):
			var foodName = data.get(name)
			if foodName == "none":
				generateRandomMeals()
				writeFoodItemsData()
				return
			match name:
				"meal1":
					plate1Meal = getFoodByName(foodName)
					plate1Texture.set_texture(plate1Meal.getMealTexture())
					plate1Button.set_tooltip_text(plate1Meal.getMealDescription())
					plate1Text.set_text(plate1Meal.getMealName())
				"meal2":
					plate2Meal = getFoodByName(foodName)
					plate2Texture.set_texture(plate2Meal.getMealTexture())
					plate2Button.set_tooltip_text(plate2Meal.getMealDescription())
					plate2Text.set_text(plate2Meal.getMealName())
				"meal3":
					plate3Meal = getFoodByName(foodName)
					plate3Texture.set_texture(plate3Meal.getMealTexture())
					plate3Button.set_tooltip_text(plate3Meal.getMealDescription())
					plate3Text.set_text(plate3Meal.getMealName())


func _on_re_roll_button_pressed() -> void:
	var doroNode = global.getDoroNode()
	var currencyAmount = doroNode.getCoins()
	if currencyAmount >= reRollCost:
		global.getDoroNode().setCoins(currencyAmount - reRollCost)
		reRollCost = reRollCost * 2
		generateRandomMeals()
		writeFoodItemsData()


func _on_exit_button_pressed() -> void:
	if Input.is_action_just_pressed("optionsMenuBind"):
		get_tree().root.add_child(optionsMenuScene.instantiate())
