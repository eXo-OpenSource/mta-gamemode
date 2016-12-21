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
		["Interior"] = {9, Vector3(365.67, -11.61, 1001.87)},
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
	},
	[7] = {
		["Name"] = "Stadthalle",
		["Interior"] = {0, Vector3(0, 0, 0)},
		["Class"] = ItemShop
	},
	[8] = {
		["Name"] = "Alhambra",
		["Marker"] = Vector3(1207.23, -28.55, 1000),
		["Ped"] = {256, Vector3(1206.23, -28.63, 1000.95), 270},
		["Interior"] = {3, Vector3(1212.27, -25.88, 1000.95)},
		["Class"] = BarShop
	},
	[9] = {
		["Name"] = "Green Bottle",
		["Marker"] = Vector3(496.88, -75.49, 997.9),
		["Ped"] = {201, Vector3(497.23, -77.57, 998.77), 0},
		["Interior"] = {11, Vector3(502.01, -67.75, 998.76)},
		["Class"] = BarShop
	},
	[10] = {
		["Name"] = "The Pig Pen",
		["Marker"] = Vector3(1214.61, -12.98, 1000),
		["Ped"] = {214, Vector3(1214.70, -15.26, 1000.92), 0},
		["Interior"] = {2, Vector3(1204.69, -13.85, 1000.92)},
		["Class"] = BarShop
	}

}

SHOP_ITEMS = {
	["Gärtnerei"] = {
		["Weed-Samen"] = 20,
		["Kanne"] = 500
	};
	["24/7"] = {
		["Radio"] = 2000,
		["Zigarette"] = 10,
		["Wuerfel"] = 10,
		["Kanne"] = 500,
		["Mautpass"] = 250,
		["Benzinkanister"] = 250,
		["Reparaturkit"] = 1000
	};
	["Stadthalle"] = {
		["Ausweis"] = 400,
		["Handelsvertrag"] = 200
	};
	["Bar"] = {
		["Bier"] = 7
	};
}

ROBABLE_SHOP_STATE_TARGETS = {Vector3(1580, -1632.17, 12.4)}
ROBABLE_SHOP_EVIL_TARGETS = {
	Vector3(2862.30, -1439.80, 9),
	Vector3(1955.00, -1095.44, 24.3),
	Vector3(432.80, -1749.60, 7.5),
	Vector3(1225.90, -2346.14, 11.90)
}
