extends Resource

class_name CharacterProperties

const SKIN_COLORS : Dictionary = {"WARM_IVORY" : "#fde7ac", 
	"SIENNA" : "#d49e7a",
	"HONEY": "#cf965f",
	"UMBER": "#b26644",
	"SAND": "#f8d998",
	"LIMESTONE": "#ecc091",
	"BAND": "#ad8a60",
	"GOLDEN": "#7f4422",
	"PALE_IVORY": "#fee3c4",
	"BEIGE": "#f2c280",
	"ALMOND": "#935f37",
	"ESPRESSO": "#5f3310",
	"ROSE_BEIGE": "#f9d4a0",
	"AMBER": "#bb6436",
	"BRONZE": "#733f17",
	"CHOCOLATE": "#291709"}

const HAIR_COLORS : Dictionary = {
	"DARK_GRAY": "#D2D0D0",
	"SANDY_TAN": "#D0BSAD",
	"WHEAT": "#EBD4BE",
	"CREAM": "#F3E4C7",
	"BISQUE": "#D6C297",
	"PEACH_PUFF": "#D6C297",
	"TAN": "#COA277",

	"MAHOGANY": "#481711",
	"CHOCOLATE": "#54352E",
	"SADDLE_BROWN": "#703514",
	"MAROON": "#954536",
	"RUST": "#6D3836",
	"CHESTNUT": "#7F553E",
	"OLIVE": "#1997A4",
	"COPPER": "#A47F53",

	"BLACK": "#3F1300",
	"DARK_RED": "#60321D",
	"BURGUNDY": "#5A361E",
	"MAHOGANY_2": "#4D2C19",
	"SABLE": "#271205",
	"SEPIA": "#A5724A",
	"CHOCOLATE_2": "#76482E",

	"TOFFEE": "#573E30",
	"CARAMEL": "#644C4A",
	"GRAY": "#787879",
	"CHARCOAL": "#3A2C29",
	"PLUM": "#473847",
	"ONYX": "#2F2020",
	"EBONY": "#201405",
	"JET_BLACK": "#0A0B07"}

const FEMALE_HAIRCUTS : Array[String] = ["res://src/main/resources/assets/3d/models/hair_cuts/female/female_1.glb",
"res://src/main/resources/assets/3d/models/hair_cuts/female/female_2.glb"]

const MALE_HAIRCUTS : Array[String] = ["res://src/main/resources/assets/3d/models/hair_cuts/male/male_1.glb",
"res://src/main/resources/assets/3d/models/hair_cuts/male/male_2.glb"]

enum TopClothTypes {SHIRT, TSHIRT, LONGSLEEVE}
enum BotClothTypes {SHORTS,BREECHES,TROUSERS}

static var skin_color : Color

static var top_cloth_lenth : int
static var color_top_cloth : Color

static var bot_cloth_lenth : int
static var color_bot_cloth : Color

static var shoes_color : Color

static var hair_color : Color

static var hair_type : String

static func create_random(gender : int) -> CharacterProperties:
	var character_properties : CharacterProperties = CharacterProperties.new()
	
	var skin_color_values : Array = SKIN_COLORS.values()
	character_properties.skin_color = Color.html(skin_color_values.pick_random()) 
	
	var TopClothTypes_values : Array = TopClothTypes.values()
	character_properties.top_cloth_lenth = TopClothTypes_values.pick_random()
	
	character_properties.color_top_cloth = get_random_color()
	
	var BotClothTypes_values : Array = BotClothTypes.values()
	character_properties.bot_cloth_lenth = BotClothTypes_values.pick_random()
	
	character_properties.color_bot_cloth = get_random_color()
	
	character_properties.shoes_color = get_random_color()
	
	var hair_colors_values : Array = HAIR_COLORS.values()
	character_properties.hair_color = Color.html(hair_colors_values.pick_random())
	
	match gender:
		0:
			character_properties.hair_type = MALE_HAIRCUTS.pick_random()
			#print(character_properties.hair_type)
		1:
			character_properties.hair_type = FEMALE_HAIRCUTS.pick_random()
			#print(character_properties.hair_type)

	
	return character_properties

static func get_random_color() -> Color:
	var r : float = randf_range(0.0,1.0)
	var g : float = randf_range(0.0,1.0)
	var b : float = randf_range(0.0,1.0)
	return Color(r,g,b)
