extends Resource
class_name StatsProgressManager

#Save method
#Load method

var mod = {"Arlan":[20,30,30,40,50],
	
	}

static func increase_xp(character:Character, xp:int)->void:
	#must implement stats in Character Class
	if character.lvl <50:
		character.xp += xp
	else:
		character.xp=0
	print("gained: "+  str(xp)+"xp")
	
static func check_progression(character) ->bool:
	##Check for Level Up
	if character.xp >= character.max_xp and character.lvl<=49:
		return true
	if character.lvl==50:
		print("Max Level")
	return false

static func level_up(character,mod):
	print("level Up!")
	var current_mod
	if mod.has(character.name):
		
		print(str(character.lvl))	
		if character.lvl%10 <8 or character.lvl>=48 :
			current_mod =mod[character.name][((character.lvl)/10)] # calculates current modifier
		else:
			current_mod =mod[character.name][(int)((character.lvl+2)/10)]
		#character.xp = character.xp-character.max_xp
		character.max_xp = current_mod*((character.lvl+2)+(character.lvl+1)) +character.max_xp # calculates new max_xp
		character.lvl+=1
	print(character.name)
	print("mod: " +str(current_mod))
	print("new level: " +str(character.lvl))
	print("until next level up: " + str(character.max_xp))
	print("current xp: "+ str(character.xp))
	print("-----------")
	if check_progression(character):
		level_up(character,mod)
	
