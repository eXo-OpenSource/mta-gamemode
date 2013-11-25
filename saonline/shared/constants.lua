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
	["Coutt and Schutz"] = {
		ImgPath = "files/images/CouttSchutz.png";
		Position = {2132, -1150.3, 23};
		Spawn = {2136.59, -1119.32, 25};
		Vehicles = {
			[411] = 10210,
			[602] = 112300,
			[496] = 100,
			[401] = 10041,
			[518] = 1010,
			[589] = 100,
			[419] = 11100,
			[526] = 97300,
			[474] = 10,
			[466] = 123123,
			[492] = 12312323,
			[409] = 123123,
			[540] = 69999,
			[529] = 123123123
		};
	};
}

BankStat = {
	Transfer = 0,
	Job = 1,
	
}
