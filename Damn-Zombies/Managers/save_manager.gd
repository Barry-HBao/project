extends Node

const SAVE_PATH = "user://saves/"
const GLOBAL_DATA_FILE_NAME = "global.json"
const SAVE_FILE_NAME = "save.json"
var current_save_file : String
var current_save_resource : SaveResource = SaveResource.new() # for testing purposes
#const SECURITY_KEY = "0923874590"

func _ready():
	verify_save_dir(SAVE_PATH)
	
func verify_save_dir(path : String):
	DirAccess.make_dir_absolute(path)

func check_save_exist(file_name):
	return FileAccess.file_exists(SAVE_PATH + file_name)

func save_data(file_name : String, save_resource : SaveResource = null):
	var path = SAVE_PATH + file_name
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		print(FileAccess.get_open_error())
		return
	
	if save_resource == null:
		save_resource = current_save_resource
	var data = {
		"current_level": GameManager.get_current_level_name(),
		"player_data":{
			"name": save_resource.player_name,
			"coins": GameManager.main_player.coins, 
			"current_weapon": save_resource.current_weapon_equip,
			"weapons":{
				"sword": save_resource.has_sword,
				"whip": save_resource.has_whip,
				"axe": save_resource.has_axe,
				"great_sword": save_resource.has_great_sword
			},
			"current_suit": save_resource.current_suit_equip,
			"suits": {
				"green": save_resource.has_green_suit,
				"rage": save_resource.has_rage_suit,
				"snow": save_resource.has_snow_suit
			},
			"seeds": {
				"seed4": save_resource.hasSeed4,
				"seed5": save_resource.hasSeed5,
				"seed6": save_resource.hasSeed6
			},
			"saved_grafts":{
				"grafts": save_resource.saved_grafts,
				"has_saved_grafts": save_resource.has_saved_grafts,
			},
			"time": {
				"day":GameManager.day,
				"time_elapsed": GameManager.time_elapsed
			}
		},
		"openedChests": save_resource.openedChests
	}
	print(data)
	
	var json_string = JSON.stringify(data, "\t")
	file.store_string(json_string)
	file.close()

func load_data(file_name : String):
	var data = _load_file(file_name)
	print(data)
	if data == null:
		return
	#Load data:
	var save_resource = SaveResource.new()
	save_resource.player_name = data.player_data.name
	save_resource.current_scene = data.current_level
	save_resource.coins = data.player_data.coins
	save_resource.openedChests = data.openedChests
	
	var weapons = data.player_data.weapons
	if weapons != null:
		save_resource.set_weapons(weapons.sword, weapons.whip, weapons.axe, weapons.great_sword)
		save_resource.current_weapon_equip = data.player_data.current_weapon
	var suits = data.player_data.suits
	if suits != null:
		save_resource.set_suits(suits.green, suits.rage, suits.snow)
	save_resource.current_suit_equip = data.player_data.current_suit
	var seeds = data.player_data.seeds
	if seeds != null:
		save_resource.set_seeds(seeds.seed4, seeds.seed5, seeds.seed6)
	# 添加嫁接植物数据的加载
	if data.player_data.saved_grafts != null:
		save_resource.saved_grafts = data.player_data.saved_grafts.grafts
		save_resource.has_saved_grafts = data.player_data.saved_grafts.has_saved_grafts

	# 添加时间数据的加载
	if data.player_data.time != null:
		save_resource.day = data.player_data.time.day
		save_resource.time_elapsed = data.player_data.time.time_elapsed
	
	return save_resource

func _load_global_data():	
	var data = _load_file(GLOBAL_DATA_FILE_NAME)
	if data == null:
		return
	
func _load_file(file_name : String):
	var path = SAVE_PATH + file_name
	if !FileAccess.file_exists(path):
		printerr("Cannot open non-existent file at %s" % [path])
		return null

	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		print(FileAccess.get_open_error())
		return null
	
	var content = file.get_as_text()
	file.close()
	
	var data = JSON.parse_string(content)
	if data == null:
		printerr("Cannot parse %s as a json_string: (%s)" % [path, content])
		return null
		
	return data
