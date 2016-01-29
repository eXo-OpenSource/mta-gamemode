local weapons = { 
["Schlagring"]=1,
["Golfschlaeger"]=2,
["Schlagstock"]=3,
["Messer"]=4,
["Baseballschlaeger"]=5,
["Schaufel"]=6,
["Billiard Koe"]=7,
["Katana"]=8,
["Kettensaege"]=9,
["Pistole"]=22,
["Schalldaempferpistole"]=23,
["Desert Eagle"]=24,
["Schrotflinte"]=25,
["Sawn-Off Schrotflinte"]=26,
["SPAZ-12 Gefechtsschrotflinte"]=27,
["Uzi"]=28,
["MP5"]=29,
["TEC-9"]=32,
["AK-47"]=30,
["M4"]=31,
["Countryschrotflinte"]=33,
["Sniper"]=34,
["Raketenwerfer"]=35,
["Waermelenkraketenwerfer"]=36,
["Flammenwerfer"]=37,
["Granate"]=16,
["Traenengas"]=17,
["Molotov Cocktails"]=18,
["Rucksackbomben"]=39,
["Spraydose"]=41,
["Feuerloescher"]=42,
["Digitalkamera"]=43,
["Langer purpel Dildo"]=10,
["Kurzer Dildo"]=11,
["Vibrator"]=12,
["Blumen"]=14,
["Gehstock"]=15,
["Nachtsichtgeraet"]=44,
["Infrarotsichtgeraet"]=45,
["Fallschirm"]=46,
["Rucksackbombenzuender"]=40
}

local _getWeaponIDFromName = getWeaponIDFromName
function getWeaponIDFromName(name)
	return weapons[refreshString(name)] or false
end

local _getWeaponNameFromID = getWeaponsNameFromID
function getWeaponsNameFromID(id)
	for index,value in pairs(weapons) do
		if(value == id) then
			return refreshStringManuel(index)
		end
	end
	return false
end
