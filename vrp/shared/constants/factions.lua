VEHICLE_BOX_LOAD = {}
VEHICLE_BOX_LOAD[543] = {["count"]= 1,	[1] = Vector3(0, -1.2, 0)}
VEHICLE_BOX_LOAD[427] = {["count"]= 2,	[1] = Vector3(0, -1.5, -0.2), [2] = Vector3(0, -3, -0.2)}

FACTION_TRUNK_MAX_ITEMS = {
	["Barrikade"] = 10,
	["Nagel-Band"] = 3,
	["Blitzer"] = 3,
	["Warnkegel"] = 10,
}

VEHICLE_BAG_LOAD = {}
VEHICLE_BAG_LOAD[428] = {["count"]=5,[1] = Vector3(0, -1.2, 0), [2] = Vector3(0, -1.2, 0), [3] = Vector3(0, -1.2, 0), [4] = Vector3(0, -1.2, 0), [5] = Vector3(0, -1.2, 0)}

FACTION_FBI_BUGS = 5

FACTION_DIPLOMACY = {
	[1] = "Verbündet",
	[2] = "Waffenstillstand",
	[3] = "im Krieg",
}
for i, v in pairs(FACTION_DIPLOMACY) do
	FACTION_DIPLOMACY[v] = i
end

FACTION_DIPLOMACY_REQUEST = {
	[1] = "Bündnis-Anfrage",
	[2] = "Waffenstillstands-Anfrage",
	[3] = "Kriegserklärung",
}
