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