class_name MealObject extends Resource

var mealName: String = "MealName" : get = getMealName
var mealDescription: String = "MealDescription" : get = getMealDescription

var mealHappinessAmount: int = 5 : get = getHappinessAmount
var mealHungyAmount: int = 5 : get = getHungyAmount

var mealTexturePath: CompressedTexture2D = load("res://Assets/Meals/PlaceHolder.png") : get = getMealTexture

enum effectsEnum { None, LovingIt, Psychedelic, HatingIt, EvilPlan } 
var mealEffect: effectsEnum = effectsEnum.None

func _init(name:String, description:String, mealHappiness: int = 5, mealHungy: int = 5, image: String = "res://Assets/Meals/PlaceHolder.png", effect: effectsEnum = effectsEnum.None) -> void:
	self.mealName = name
	self.mealDescription = description
	self.mealHappinessAmount = mealHappiness
	self.mealHungyAmount = mealHungy
	self.mealTexturePath = load(image)
	self.mealEffect = effect
	
func getEffect() -> effectsEnum:
	return mealEffect
	
func getMealName() -> String:
	return mealName
	
func getMealDescription() -> String:
	return mealDescription
	
func getHappinessAmount() -> int:
	return mealHappinessAmount
	
func getHungyAmount() -> int:
	return mealHungyAmount
	
func getMealTexture() -> CompressedTexture2D:
	return mealTexturePath
	
	
