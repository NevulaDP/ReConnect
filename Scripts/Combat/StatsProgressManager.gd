extends Resource
class_name StatsProgressManager

# Save method
# Load method

var mod = {"Arlan":[20,30,30,40,50]}


static func increase_xp(character:Character, xp:int):
	if character.level < 50:
		character.xp += xp
		print("XP_GAIN: char={0}, xp_gain={1}, new_total_xp={2}".format({"0": character.c_name, "1": xp, "2": character.xp}))

static func check_progression(character):
	# check for Level Up
	if character.xp >= character.max_xp and character.level <= 49:
		return true
	if character.level == 50:
		print("Max Level")
	return false

static func level_up(character, mod):
	var current_mod
	if mod.has(character.name):
		print(str(character.level))	
		if character.level % 10 < 8 or character.level >= 48 :
			current_mod =mod[character.name][((character.level) / 10)] # calculates current modifier
		else:
			current_mod = mod[character.name][(int)((character.level + 2) / 10)]
		# character.xp = character.xp-character.max_xp
		character.max_xp = current_mod * ((character.level + 2) + (character.level + 1)) + character.max_xp # calculates new max_xp
		character.level += 1
		print("LEVEL UP: char={0}, new_level={1}".format({"0": character.c_name, "1": character.level}))
	if check_progression(character):
		level_up(character, mod)
