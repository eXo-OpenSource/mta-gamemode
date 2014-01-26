MAX_CHARACTERS = 5
PRIVATE_DIMENSION_SERVER = 1 -- This dimension should not be used for playing
PRIVATE_DIMENSION_CLIENT = 2 -- This dimension should be used for things which 
							 -- happen while the player is in PRIVATE_DIMENSION on the server

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
			[445] = 3750,
			[527] = 4000,
			[542] = 6000,
			[585] = 7500,
			[546] = 5700,
			[404] = 3000,
			[600] = 7200,
			[479] = 3700,
			[543] = 2700,
			[567] = 8000,
			[439] = 6500,
			[566] = 5000,
			[549] = 3500,
			[491] = 5000
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

GroupRank = {
	Normal = 0,
	Manager = 1,
	Leader = 2
}
