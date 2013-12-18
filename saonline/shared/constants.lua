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
		Rect = {2141.3, -1207.74, 24.47, 76.15};
		Spawn = {2148.2, -1179.96, 23.5, 90};
		Vehicles = {
			[445] = 10210,
			[527] = 112300,
			[542] = 100,
			[585] = 10041,
			[546] = 1010,
			[404] = 100,
			[600] = 11100,
			[479] = 97300,
			[543] = 10,
			[567] = 123123,
			[439] = 12312323,
			[566] = 123123,
			[549] = 69999,
			[491] = 123123123
		};
	};
}

BankStat = {
	Transfer = 0,
	Income = 1,
	Payment = 2,
	Withdrawal = 3,
	Deposit = 4,
	Job = 5,
	
}
