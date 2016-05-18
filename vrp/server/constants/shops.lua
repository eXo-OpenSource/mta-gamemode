SHOP_TYPES = {
	[1] = {
		["Name"] = "Burger Shot",
		["Interior"] = {10, Vector3(363.11, -74.88, 1001.5)},
		["Ped"] = {205, Vector3(376.53, -65.59, 1001.51), 180},
		["Marker"] = Vector3(376.60, -68.03, 1000.8),
		["Class"] = BurgerShot
	},
	[2] = {
		["Name"] = "Cluckin Bell",
		["Interior"] = {9, Vector3(365.67, -11.61, 1000.87)},
		["Ped"] = {167, Vector3(368.62, -4.49, 1001.85), 180},
		["Marker"] = Vector3(368.36, -6.42, 1000.9),
		["Class"] = CluckinBell
	},
	[3] = {
		["Name"] = "Pizza Stack",
		["Interior"] = {5, Vector3(372.25, -133.52, 1001.49)},
		["Ped"] = {155, Vector3(374.78, -117.28, 1001.49), 180},
		["Marker"] = Vector3(374.68, -118.80, 1000.6),
		["Class"] = PizzaStack
	},
	[4] = {
		["Name"] = "Rusty Brown",
		["Interior"] = {17, Vector3(377.08, -192.86, 1000.64)},
		["Ped"] = {209, Vector3(380.67, -189.11, 1000.63), 247},
		["Marker"] = Vector3(379.34, -190.71, 999.9),
		["Class"] = RustyBrown
	},
	[5] = {
		["Name"] = "24/7",
		["Interior"] = {18, Vector3(-30.98, -91.9, 1003.5)},
		["Ped"] = {202, Vector3(-28.15, -91.64, 1003.55), 0},
		["Marker"] = Vector3(-28, -89.9, 1002.7),
		["Class"] = ItemShop
	},
	[6] = {
		["Name"] = "Gärtnerei",
		["Interior"] = {0, Vector3(0, 0, 0)},
		["Ped"] = {202, Vector3(2426.27, 125.96, 26.48), 270},
		["Marker"] = Vector3(2427.99, 126.00, 25.5),
		["Class"] = ItemShop
	}
}

SHOP_ITEMS = {
	["Gärtnerei"] = {
		["Weed-Samen"] = 20,
		["Kanne"] = 500
	};
	["24/7"] = {
		["Radio"] = 2000,
		["Zigaretten"] = 10,
		["Wuerfel"] = 10,
		["Kanne"] = 500
	};
}

ROBABLE_SHOP_STATE_TARGETS = {Vector3(1580,-1632.17,13.4)}
ROBABLE_SHOP_EVIL_TARGETS = {
	Vector3(2862.2783203125,-1439.802734375,10.941749572754),
	Vector3(1955.0771484375,-1095.4462890625,25.342666625977),
	Vector3(432.7529296875,-1749.5986328125,8.9852485656738),
	Vector3(1225.869140625,-2346.1435546875,13.895024299622)
}
