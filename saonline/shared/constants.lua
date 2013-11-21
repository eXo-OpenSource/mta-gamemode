MAX_CHARACTERS = 5
RANK = {}
RANK[-1] = "Banned"
RANK[0] = "User"
RANK[1] = "UNUSED"
RANK[2] = "Moderator"
RANK[3] = "Administrator"
RANK[4] = "Developer"

local r2 = {}
for k, v in pairs(RANK) do
	r2[k] = v
	r2[v] = k
end
RANK = r2

VEHICLESHOPS = {
	CoutSchutz = {
		Name = "Cout and Schutz";
		Position = {0, 0, 5};
		Vehicles = {
			["Infernus"] = 10210,
			["Banshee"] = 112300,
			["Bullet"] = 100,
			["Tampa"] = 10041,
			["Super GT"] = 1010,
			["Turismo"] = 100,
			["Sabre"] = 11100,
			["NRG-500"] = 97300,
			["FCR-600"] = 10,
			["Alpha"] = 123123,
			["Jester"] = 12312323,
			["Uranus"] = 123123,
			["ZR-350"] = 69999,
			["Blade"] = 123123123
		};
	};
}
