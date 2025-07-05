extends Node

const save_path = "user://userdata.save"


func save_data():
	var data = {
		"bananas": Globals.bananas,
		"amount_per_click": Globals.amount_per_click,
		"bananas_per_second": Globals.bananas_per_second,
		"upgrades": Globals.upgrades,
	}
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_var(data)
	file.close()

func load_data():
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		var data = file.get_var()
		file.close()
		if typeof(data) == TYPE_DICTIONARY:
			Globals.bananas = data.get("bananas",0)
			Globals.amount_per_click = data.get("amount_per_click",0)
			Globals.bananas_per_second = data.get("bananas_per_second",0)
			# Load the upgrades array
			var loaded_upgrades = data.get("upgrades", [])
			# Merge loaded upgrades with default upgrades to handle new upgrades
			for i in range(Globals.upgrades.size()):
				for loaded_upgrade in loaded_upgrades:
					if Globals.upgrades[i]["id"] == loaded_upgrade["id"]:
						Globals.upgrades[i]["purchased"] = loaded_upgrade["purchased"]
						break
	else:
		save_data()
