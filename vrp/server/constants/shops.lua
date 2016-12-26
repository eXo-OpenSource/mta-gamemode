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
	},
	[11] = {
		["Name"] = "Lil probe inn",
		["Marker"] = Vector3(-224.79, 1404.38, 27),
		["Ped"] = {201, Vector3(-223.31, 1404.32, 27.77), 90},
		["Interior"] = {18, Vector3(-229.29, 1401.25, 27.77)},
		["Class"] = BarShop
	},
	[12] = {
		["Name"] = "Pleasure domes",
		["Marker"] = Vector3(-2654.02, 1407.67, 905.4),
		["Ped"] = {214, Vector3(-2655.51, 1407.74, 906.27), 270},
		["Interior"] = {3, Vector3(-2636.64, 1402.46, 906.46)},
		["Class"] = BarShop
	},
	[13] = {
		["Name"] = "Tankstelle",
		["Marker"] = Vector3(-23.37, -55.63, 1002.6),
		["Ped"] = {160, Vector3(-23.46, -57.32, 1003.55), 0},
		["Interior"] = {6, Vector3(-27.48, -58.27, 1003.55)},
		["Class"] = GasStation
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
		["Reparaturkit"] = 1000
	};
	["Tankstelle"] = {
		["Zigarette"] = 10,
		["Mautpass"] = 250,
		["Benzinkanister"] = 250,
		["Reparaturkit"] = 1000
	};
	["Stadthalle"] = {
		["Ausweis"] = 400,
		["Handelsvertrag"] = 200
	};
	["Bar"] = {
		["Bier"] = 7,
		["Whiskey"] = 9,
		["Sex on the Beach"] = 15,
		["Pina Colada"] = 15,
		["Monster"] = 25,
		["Shot"] = 8,
		["Cuba-Libre"] = 12
	};
}

SHOP_OWNER_TYPES = {
	[1] = "Player",
	[2] = "Group"
}

for i, k in pairs(SHOP_OWNER_TYPES) do
	SHOP_OWNER_TYPES[k] = i
end

SHOP_BAR_STRIP = {
	["Alhambra"] = {
		["Skins"] = {63, 92, 138, 139, 140, 152, 243, 238, 244, 178},
		[1] = { ["Pos"] = Vector3(1215.25, -33.73, 1001.39), ["Rot"] = 74 },
		[2] = { ["Pos"] = Vector3(1209.24, -35.90, 1001.48), ["Rot"] = 10 },
		[3] = { ["Pos"] = Vector3(1212.53, -40.42, 1001.48), ["Rot"] = 323 },
	},
	["The Pig Pen"] = {
		["Skins"] = {63, 92, 138, 139, 140, 152, 243, 238, 244, 178},
		[1] = { ["Pos"] = Vector3(1208.21, -7.46, 1001.33), ["Rot"] = 170 },
		[2] = { ["Pos"] = Vector3(1215.50, -7.15, 1001.33), ["Rot"] = 126 },
		[3] = { ["Pos"] = Vector3(1213.87, -4.31, 1001.33), ["Rot"] = 25 },
		[4] = { ["Pos"] = Vector3(1222.97, -2.31, 1001.33), ["Rot"] = 25 },
		[5] = { ["Pos"] = Vector3(1222.97, -11.57, 1001.33), ["Rot"] = 135 },
		[6] = { ["Pos"] = Vector3(1221.21, 8.31, 1001.34), ["Rot"] = 129 }
	},
	["Green Bottle"] = {
		["Skins"] = {246, 245, 64, 87, 257, 199},
		[1] = { ["Pos"] = Vector3(510.23, -84.41, 999.83), ["Rot"] = 18 },
		[2] = { ["Pos"] = Vector3(489.81, -79.76, 999.63), ["Rot"] = 342 },
		[3] = { ["Pos"] = Vector3(496.41, -73.17, 999.67), ["Rot"] = 196 },
	},
	["Lil probe inn"] = {
		["Skins"] = {246, 245, 64, 87, 257, 199},
		[1] = { ["Pos"] = Vector3(-223.71, 1408.43, 28.71), ["Rot"] = 14 },
		[2] = { ["Pos"] = Vector3(-228.64, 1404.52, 28.69), ["Rot"] = 254 },
	},
	["Pleasure domes"] = {
		["Skins"] = {63, 92, 138, 139, 140, 152, 243, 238, 244, 178},
		[1] = { ["Pos"] = Vector3(-2658.69, 1415.23, 907.39), ["Rot"] = 52 },
		[2] = { ["Pos"] = Vector3( -2663.70, 1410.26, 907.39), ["Rot"] = 51 },
		[3] = { ["Pos"] = Vector3( -2659.48, 1405.70, 907.39), ["Rot"] = 192 },
		[4] = { ["Pos"] = Vector3(-2671.01, 1409.99, 907.57), ["Rot"] = 280 },
		[5] = { ["Pos"] = Vector3(-2677.78, 1416.03, 907.56), ["Rot"] = 290 },
		[6] = { ["Pos"] = Vector3(-2670.72, 1428.26, 907.36), ["Rot"] = 160 },
		[7] = { ["Pos"] = Vector3(-2661.22, 1427.29, 907.36), ["Rot"] = 200 },
		[8] = { ["Pos"] = Vector3(-2654.14, 1427.75, 907.36), ["Rot"] = 180 },
		[9] = { ["Pos"] = Vector3(-2667.25, 1424.34, 912.41), ["Rot"] = 181 },
		[10]= { ["Pos"] = Vector3(-2660.93, 1424.44, 912.41), ["Rot"] = 182 }
	},

}

SHOP_BAR_STRIP_ANIMATIONS = {"STR_Loop_A", "STR_Loop_A", "STR_Loop_C"}

SHOP_FUEL = {
	["Temple"] = {
		["Marker"] = Vector3(1007.8759155273, -940.43975830078, 41.18),
		["FuelStation"] = {1007.2157, -936.54523, 42.9, 8}
	},
	["San Fierro Downtown"] = {
		["Marker"] = Vector3(-1672.8955078125,415.9296875, 5.68),
		["FuelStation"] = {-1669.9, 412.39999, 8, 46}
	},
	["San Fierro Juniper Hill"] = {
		["Marker"] = Vector3(-2405.73828125,975.3662109375,43.896875),
		["FuelStation"] = {-2410.8994, 975.7998, 46, 90}
	},
	["Angle Pine"] = {
		["Marker"] = Vector3(-2246.2653808594, -2561.2934570313, 30.921875),
		["FuelStation"] = {-2246.8994, -2559.5, 32.7, 63.243}
	},
	["Dillimore"] = {
		["Marker"] = Vector3(655.52795410156, -565.03424072266, 15.3359375),
		["FuelStation"] = {655.5, -564.90002, 16.9, 90}
	},
	["Flint County"] = {
		["Marker"] = Vector3(-92.113708496094, -1171.3128662109 ,1.3799414634705),
		["FuelStation"] = {-88.1, -1171.4, 2.9, 68}
	},
	["Red Sands West"] = {
		["Marker"] = Vector3(1597.9239501953 ,2199.1923828125 ,9.9),
		["FuelStation"] = {1596.3, 2204.5, 11.6, 0}
	},
	["Spinybed"] = {
		["Marker"] = Vector3(2146.923828125,2748.362304687 ,9.8203125),
		["FuelStation"] = {2147.6001, 2753.3999, 11.5, 0}
	},
	["Las Venturas 2"] = {
		["Marker"] = Vector3(2114.7553710938 ,920.28552246094 ,9.8203125),
		["FuelStation"] = {2114.8999, 925.5, 11.5, 359.989}
	},
	["Valle Ocultado"] = {
		["Marker"] = Vector3(-731.541015625,2741.8486328125,46.5),
		["FuelStation"] = {-731.5, 2745, 47.8, 0}
	},
	["Tierra Roboda 2"] = {
		["Marker"] = Vector3(-1327.8564453125,2682.9794921875 ,49.0625),
		["FuelStation"] = {-1328.1, 2680.2, 51, 354}
	},
	["Idlewood"] = {
		["Marker"] = Vector3(1936.951171875,-1775.9375,12.3828125),
		["FuelStation"] = {1941.7957, -1776.4347, 14.2, 90}
	},
	["Fort Carson"] = {
		["Marker"] = Vector3(71.8173828125,1220.35546875,17.815870285034),
		["FuelStation"] = {68.1, 1221.3, 19.6, 252}
	},
	["Whetstone"] = {
		["Marker"] = Vector3(-1612.5341796875 ,-2723.4165039063 ,47.6),
		["FuelStation"] = {-1607.8096, -2716.1602, 49.428, 323.998}
	},
	["Last Venturas East"] = {
		["Marker"] = Vector3(2638.4443359375 ,1106.2412109375 ,9.8203125),
		["FuelStation"] = {2639.8999, 1100.9, 11.5, 359.243}
	},
	["The Emerald Isle"] = {
		["Marker"] = Vector3(2203.1423339844 ,2473.5385742188 ,9.8203125),
		["FuelStation"] = {2196.9246, 2475.0313, 11.47524, 270}
	},
	["Montegomery"] = {
		["Marker"] = Vector3(1380.0498046875,456.221679687,19.4),
		["FuelStation"] = {1381.0996, 460.09961, 20.8, 155.495}
	},
	["Bone County"] = {
		["Marker"] = Vector3(615.7958984375,1690.638671875,5.6),
		["FuelStation"] = {617.59998, 1687.9, 7.8, 35.5}
	},
	["Tierra Roboda 1"] = {
		["Marker"] = Vector3(-1465.9541015625,1864.23046875,32),
		["FuelStation"] = {-1465.5, 1868.2, 33.4, 3.239}
	}
}

ROBABLE_SHOP_STATE_TARGETS = {Vector3(1580, -1632.17, 12.4)}
ROBABLE_SHOP_EVIL_TARGETS = {
	Vector3(2862.30, -1439.80, 9),
	Vector3(1955.00, -1095.44, 24.3),
	Vector3(432.80, -1749.60, 7.5),
	Vector3(1225.90, -2346.14, 11.90)
}
