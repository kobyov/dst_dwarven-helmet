PrefabFiles = {
	"dwarven_helmet",
}

local Ingredient = GLOBAL.Ingredient
local RecipeTabs = GLOBAL.RECIPETABS
local Tech = GLOBAL.TECH

local dwarven_helmetRecipe = Recipe("dwarven_helmet", {Ingredient("strawhat", 1),Ingredient("transistor", 1),Ingredient("lightbulb", 1),Ingredient("charcoal", 8)}, RecipeTabs.LIGHT, Tech.SCIENCE_TWO)
dwarven_helmetRecipe.atlas = "images/inventoryimages/junkerang.xml"

GLOBAL.STRINGS.NAMES.DWARVEN_HELMET = "Dwarven Mining Helmet"
GLOBAL.STRINGS.RECIPE_DESC.DWARVEN_HELMET = "Light is all that matters, right?"
