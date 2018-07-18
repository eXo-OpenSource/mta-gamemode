-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/InteriorManager.lua
-- *  PURPOSE:     Manages interiors and its dimensions
-- *
-- ****************************************************************************
InteriorManager = inherit(Singleton)

function InteriorManager:constructor()
    self.m_Map = {}

    self:createDefaultInteriors()
end

function InteriorManager:registerInterior(Id, interiorId, spawnPosition)
    self.m_Map[Id] = {
        InteriorId = interiorId,
        SpawnPosition = spawnPosition
    }
end

function InteriorManager:getInteriorInfo(Id)
    local info = self.m_Map[Id]
    if info then
        return info.InteriorId, info.SpawnPosition
    end
    return false, false
end

function InteriorManager:teleportPlayerToInterior(player, Id)
    local interiorId, position = self:getInteriorInfo(Id)
    if interiorId then
        setElementInterior(player,interiorId, position)
        setElementDimension(player,Id)
        player:setUniqueInterior(Id)
    end
end

function InteriorManager:createDefaultInteriors()
	--[[
    for k, info in pairs(self.InteriorData) do
        InteriorEnterExit:new(info.enter + Vector3(0, 0, 0.5), info.spawn + Vector3(0, 0, 0.5), info.rotation, 0, info.interior, info.dimension, true)
    end
	--]]

    -- Copied over from InteriorEnterExit
	local data = {
		{1554.8, -1675.7, 16, 246.7, 63, 1003.64, 0, 90, 6},
        {1567.91, -1898.01, 13.56, 460.56, -88.65, 999.55, 90, 0, 4},
	}

	for k, info in pairs(data) do
		InteriorEnterExit:new(Vector3(info[1], info[2], info[3]), Vector3(info[4], info[5], info[6]), info[7], info[8], info[9], info[10])
	end
end

InteriorManager.InteriorData = {
    --[[ Converted from [gameplay]/interiors/interiors.map using the following regexes
        <interiorEntry\tid=\".*?\"\tposX=\"(.*)\"\tposY=\"(.*)\"\tposZ=\"(.*)\".*?dimension=\"(.*)\"\tinterior=\"(.*)\"
        {enter = Vector3(\0, \1, \2)

        <interiorReturn\trefid=\".*?\"\tposX=\"(.*)\"\tposY=\"(.*)\"\tposZ=\"(.*)\"\trotation=\"(.*?)\".*?interior=\"(.*)\"\tdimension=\"(.*?)\".*/>
        Vector3\(\1, \2, \3\), dimension = \6, interior = \5, rotation = \4
    ]]
    {enter = Vector3(-225.433, 1397.02, 69.0501), spawn = Vector3(-224.733, 1395.82, 172.05), dimension = 0, interior = 0, rotation = 0},
    {enter = Vector3(2896.57, 57.2165, 0), spawn = Vector3(2980.16, 76.1581, 0), dimension = 1, interior = 0, rotation = 0},
    {enter = Vector3(-1749.35, 869.279, 24.0593), spawn = Vector3(-1753.85, 885.679, 295.059), dimension = 2, interior = 0, rotation = 0},
    {enter = Vector3(-1753.75, 883.965, 294.645), spawn = Vector3(-1749.38, 865.158, 24.1455), dimension = 3, interior = 0, rotation = 0},
    {enter = Vector3(966.608, 2160.68, 9.82222), spawn = Vector3(965.38, 2159.33, 1010.02), dimension = 0, interior = 1, rotation = 270},
    {enter = Vector3(1038.15, -1340.33, 13.74), spawn = Vector3(377.08, -192.86, 1000.64), dimension = 0, interior = 17, rotation = 270}, -- RustyBrown
    -- AmmuNations
    --[[{enter = Vector3(1368.35, -1279.06, 12.55), spawn = Vector3(286.15, -41.54, 1000.57), dimension = 0, interior = 1, rotation = 90},
    {enter = Vector3(-2625.85, 208.345, 3.98935), spawn = Vector3(286.15, -41.54, 1000.57), dimension = 1, interior = 1, rotation = 5400.06},
    {enter = Vector3(242.668, -178.478, 0.621441), spawn = Vector3(285.8, -85.45, 1000.54), dimension = 0, interior = 4, rotation = -269.903},
    {enter = Vector3(2333.43, 61.5173, 25.7342), spawn = Vector3(285.8, -85.45, 1000.54), dimension = 1, interior = 4, rotation = -90},
    {enter = Vector3(2159.51, 943.329, 9.82339), spawn = Vector3(285.8, -85.45, 1000.54), dimension = 2, interior = 4, rotation = -3870.01},
    {enter = Vector3(2539.04, 2083.56, 9.82222), spawn = Vector3(285.8, -85.45, 1000.54), dimension = 3, interior = 4, rotation = 90},
    {enter = Vector3(777.231, 1871.47, 3.97687), spawn = Vector3(296.92, -111.97, 1000.57), dimension = 3, interior = 6, rotation = 300.994},
    {enter = Vector3(-315.676, 829.868, 13.4266), spawn = Vector3(296.92, -111.97, 1000.57), dimension = 4, interior = 6, rotation = 300.994},
    {enter = Vector3(-2093.51, -2464.79, 29.6404), spawn = Vector3(296.92, -111.97, 1000.57), dimension = 5, interior = 6, rotation = 319},
    {enter = Vector3(2400.5, -1981.48, 12.5604), spawn = Vector3(296.92, -111.97, 1000.57), dimension = 6, interior = 6, rotation = 0},
    {enter = Vector3(-1508.89, 2610.8, 54.8902), spawn = Vector3(316.53, -169.61, 998.66), dimension = 0, interior = 6, rotation = 180},]]
    {enter = Vector3(1727.64, -1636.88, 19.2198), spawn = Vector3(1726.19, -1638.01, 19.27), dimension = 0, interior = 18, rotation = 180},
    {enter = Vector3(1699.36, -1667.16, 19.2198), spawn = Vector3(1700.74, -1668.48, 19.22), dimension = 0, interior = 18, rotation = 270},
    {enter = Vector3(1836.9, -1681.75, 12.3635), spawn = Vector3(493.39, -24.92, 999.69), dimension = 0, interior = 17, rotation = 90},
    {enter = Vector3(-2551.79, 193.778, 5.21905), spawn = Vector3(493.39, -24.92, 999.69), dimension = 1, interior = 17, rotation = 105},
    {enter = Vector3(2507.44, 1242.31, 9.83339), spawn = Vector3(493.39, -24.92, 999.69), dimension = 2, interior = 17, rotation = -3600.01},
    {enter = Vector3(2309.62, -1643.63, 13.8385), spawn = Vector3(501.98, -67.75, 997.84), dimension = 0, interior = 11, rotation = 93},
    {enter = Vector3(-2242.69, -88.2558, 34.3578), spawn = Vector3(501.98, -67.75, 997.84), dimension = 1, interior = 11, rotation = 3691.82},
    {enter = Vector3(2441.15, 2065.15, 9.8472), spawn = Vector3(501.98, -67.75, 997.84), dimension = 2, interior = 11, rotation = 180},
    {enter = Vector3(672.355, -496.834, 15.3751), spawn = Vector3(418.65, -84.14, 1000.96), dimension = 0, interior = 3, rotation = -88.9025},
    {enter = Vector3(-1449.87, 2591.85, 54.8378), spawn = Vector3(418.65, -84.14, 1000.96), dimension = 1, interior = 3, rotation = 360},
    {enter = Vector3(823.629, -1588.9, 12.5764), spawn = Vector3(418.65, -84.14, 1000.96), dimension = 2, interior = 3, rotation = -1297.58},
    {enter = Vector3(-2571.18, 246.698, 9.64213), spawn = Vector3(418.65, -84.14, 1000.96), dimension = 3, interior = 3, rotation = -138},
    {enter = Vector3(2080.36, 2122.13, 9.82222), spawn = Vector3(418.65, -84.14, 1000.96), dimension = 4, interior = 3, rotation = 180},
    {enter = Vector3(2723.76, -2026.72, 12.5753), spawn = Vector3(412.02, -54.55, 1000.96), dimension = 0, interior = 12, rotation = 90},
    {enter = Vector3(2070.86, -1793.84, 12.661), spawn = Vector3(411.63, -23.33, 1000.8), dimension = 0, interior = 2, rotation = -90},
    {enter = Vector3(2808, -1175.99, 24.7745), spawn = Vector3(2807.62, -1174.1, 1024.58), dimension = 0, interior = 8, rotation = -180},
    {enter = Vector3(2495.33, -1690.75, 13.7847), spawn = Vector3(2496.05, -1692.73, 1013.75), dimension = 0, interior = 3, rotation = 0},
    {enter = Vector3(2540.08, -1304, 33.9877), spawn = Vector3(2541.7, -1304.01, 1024.07), dimension = 0, interior = 2, rotation = 90},
    {enter = Vector3(1659.42, 2249.69, 10.0664), spawn = Vector3(1133.07, -12.77, 999.75), dimension = 0, interior = 12, rotation = 0},
    --{enter = Vector3(1456.77, -1138.02, 23.2872), spawn = Vector3(161.39, -96.69, 1000.81), dimension = 0, interior = 18, rotation = -141}, -- Skin Shop
    {enter = Vector3(-1883.2, 865.473, 34.2601), spawn = Vector3(161.39, -96.69, 1000.81), dimension = 1, interior = 18, rotation = 129},
    {enter = Vector3(2572.07, 1904.83, 10.0231), spawn = Vector3(161.39, -96.69, 1000.81), dimension = 2, interior = 18, rotation = 180},
    {enter = Vector3(2090.58, 2224.2, 10.0579), spawn = Vector3(161.39, -96.69, 1000.81), dimension = 3, interior = 18, rotation = 180},
    --{enter = Vector3(2244.47, -1665.36, 14.4839), spawn = Vector3(207.74, -111.42, 1004.27), dimension = 0, interior = 15, rotation = -363}, -- binco grove street
    {enter = Vector3(-2375.32, 910.293, 44.4578), spawn = Vector3(207.74, -111.42, 1004.27), dimension = 1, interior = 15, rotation = 5507.58},
    {enter = Vector3(1657.01, 1733.33, 10.0209), spawn = Vector3(207.74, -111.42, 1004.27), dimension = 2, interior = 15, rotation = 90},
    {enter = Vector3(2102.69, 2257.49, 10.0579), spawn = Vector3(207.74, -111.42, 1004.27), dimension = 3, interior = 15, rotation = 270},
    {enter = Vector3(461.158, -1499.98, 30.1742), spawn = Vector3(227.29, -7.43, 1001.26), dimension = 0, interior = 5, rotation = 100},
    {enter = Vector3(-1694.76, 951.599, 24.2706), spawn = Vector3(227.29, -7.43, 1001.26), dimension = 1, interior = 5, rotation = 92},
    {enter = Vector3(2802.34, 2430.6, 10.061), spawn = Vector3(227.29, -7.43, 1001.26), dimension = 2, interior = 5, rotation = 125},
    {enter = Vector3(453.868, -1478.07, 29.9609), spawn = Vector3(204.33, -168.7, 999.58), dimension = 0, interior = 14, rotation = 129},
    {enter = Vector3(499.637, -1360.4, 15.4261), spawn = Vector3(207.06, -139.81, 1002.52), dimension = 0, interior = 3, rotation = -45},
    {enter = Vector3(2825.74, 2407.44, 10.061), spawn = Vector3(207.06, -139.81, 1002.52), dimension = 1, interior = 3, rotation = 125},
    {enter = Vector3(-594.874, 2018.21, 59.6792), spawn = Vector3(-959.671, 1955.55, 8.08044), dimension = 0, interior = 17, rotation = 270},
    {enter = Vector3(423.99, 2536.49, 15.19), spawn = Vector3(422.16, 2536.52, 9.01), dimension = 0, interior = 10, rotation = 270},
    -- Diners are commented out due to their poor collisions
    --[[{enter = Vector3(-1941.72, 2379.54, 48.7008), spawn = Vector3(460.1, -88.43, 998.62), dimension = 0, interior = 4, rotation = 292},
    {enter = Vector3(386.918, -1817.79, 6.90008), spawn = Vector3(460.1, -88.43, 998.62), dimension = 1, interior = 4, rotation = 90},
    {enter = Vector3(1376.89, 2327.79, 9.82222), spawn = Vector3(460.1, -88.43, 998.62), dimension = 2, interior = 4, rotation = 270},
    {enter = Vector3(-206, 1062.21, 18.8298), spawn = Vector3(459.35, -111.01, 998.72), dimension = 0, interior = 5, rotation = 308.648},
    {enter = Vector3(-53.87, 1189.17, 18.4108), spawn = Vector3(459.35, -111.01, 998.72), dimension = 1, interior = 5, rotation = 308.648},
    {enter = Vector3(291.974, -195.463, 0.852), spawn = Vector3(459.35, -111.01, 998.72), dimension = 2, interior = 5, rotation = -269.903},
    {enter = Vector3(2863.23, -1439.44, 10.0083), spawn = Vector3(459.35, -111.01, 998.72), dimension = 3, interior = 5, rotation = 270},
    {enter = Vector3(-1700.01, 1380.49, 6.20434), spawn = Vector3(459.35, -111.01, 998.72), dimension = 4, interior = 5, rotation = 3729.57},
    {enter = Vector3(-2524.11, 1216.16, 36.4496), spawn = Vector3(459.35, -111.01, 998.72), dimension = 5, interior = 5, rotation = -90},
    {enter = Vector3(2368.06, 1983.19, 10.003), spawn = Vector3(459.35, -111.01, 998.72), dimension = 6, interior = 5, rotation = 125},]]
    --{enter = Vector3(-2029.72, -120.926, 34.1691), spawn = Vector3(-2029.72, -119.55, 1034.17), dimension = 0, interior = 3, rotation = 180}, -- driving school
    --{enter = Vector3(-2026.92, -101.459, 34.259), spawn = Vector3(-2026.92, -103.48, 1034.27), dimension = 0, interior = 3, rotation = 0}, -- driving school
    {enter = Vector3(2351.97, -1169.86, 27.0309), spawn = Vector3(2352.34, -1181.25, 1027), dimension = 0, interior = 5, rotation = 0},
    {enter = Vector3(1288.8, 271.002, 18.5554), spawn = Vector3(834.82, 7.42, 1003.18), dimension = 0, interior = 3, rotation = -2285.19},
    {enter = Vector3(1631.86, -1172.57, 23.1349), spawn = Vector3(834.82, 7.42, 1003.18), dimension = 1, interior = 3, rotation = -3240.3},
    {enter = Vector3(2402.52, -1715.28, 14.13), spawn = Vector3(243.75, 304.82, 999.14), dimension = 0, interior = 1, rotation = 270},
    {enter = Vector3(-2574.04, 1152.31, 55.72), spawn = Vector3(266.56, 304.95, 999.14), dimension = 0, interior = 2, rotation = 270},
    {enter = Vector3(-382.67, -1438.83, 26.12), spawn = Vector3(292.89, 309.90, 999.15), dimension = 0, interior = 3, rotation = 90},
    {enter = Vector3(-1800.21, 1200.576, 25.119), spawn = Vector3(300.239, 300.584, 999.15), dimension = 0, interior = 4, rotation = 0},
    {enter = Vector3(-1390.186, 2638.72, 55.98), spawn = Vector3(322.25, 302.42, 999.15), dimension = 0, interior = 5, rotation = 0},
    {enter = Vector3(2037.22, 2721.81, 11.29), spawn = Vector3(343.74, 305.0347, 999.15), dimension = 0, interior = 6, rotation = 180},
    {enter = Vector3(2229.63, -1721.63, 12.6529), spawn = Vector3(772.11, -5, 999.69), dimension = 0, interior = 5, rotation = 497},
    {enter = Vector3(-2270.46, -155.957, 34.3573), spawn = Vector3(774.21, -50.02, 999.69), dimension = 0, interior = 6, rotation = 270},
    {enter = Vector3(1968.7, 2295.3, 15.4955), spawn = Vector3(773.58, -78.2, 999.69), dimension = 0, interior = 7, rotation = 180},
    {enter = Vector3(2268.07, 1619.59, 93.9124), spawn = Vector3(2264.49, 1619.58, 1089.5), dimension = 0, interior = 1, rotation = 270},
    {enter = Vector3(2268.14, 1675.89, 93.9124), spawn = Vector3(2264.48, 1675.93, 1089.5), dimension = 0, interior = 1, rotation = 270},
    {enter = Vector3(2166.2, -1671.47, 14.1977), spawn = Vector3(318.57, 1115.21, 1082.98), dimension = 0, interior = 5, rotation = 220},
    {enter = Vector3(2112.73, -1211.7, 22.9614), spawn = Vector3(203.78, -49.89, 1000.8), dimension = 0, interior = 1, rotation = 180},
    {enter = Vector3(-2491.98, -29.1065, 24.817), spawn = Vector3(203.78, -49.89, 1000.8), dimension = 1, interior = 1, rotation = 90},
    {enter = Vector3(2779.12, 2453.54, 10.061), spawn = Vector3(203.78, -49.89, 1000.8), dimension = 2, interior = 1, rotation = 125},
    {enter = Vector3(-2058.97, 889.859, 60.9137), spawn = Vector3(223.04, 1287.26, 1081.2), dimension = 0, interior = 1, rotation = 362},
    {enter = Vector3(-2139.85, 1189.84, 54.7634), spawn = Vector3(260.98, 1284.55, 1079.3), dimension = 0, interior = 4, rotation = 179},
    {enter = Vector3(-2152.4, 1250.16, 24.9503), spawn = Vector3(260.98, 1284.55, 1079.3), dimension = 1, interior = 4, rotation = 362},
    {enter = Vector3(-1955.25, 1190.6, 44.4531), spawn = Vector3(260.98, 1284.55, 1079.3), dimension = 2, interior = 4, rotation = 180},
    {enter = Vector3(2421.52, -1220.65, 24.6085), spawn = Vector3(1204.81, -12.79, 1000.09), dimension = 0, interior = 2, rotation = -180},
    {enter = Vector3(2506.74, 2120.39, 9.8472), spawn = Vector3(1204.81, -12.79, 1000.09), dimension = 1, interior = 2, rotation = 0},
    {enter = Vector3(1259.39, -785.332, 91.042), spawn = Vector3(1260.58, -785.31, 1090.96), dimension = 0, interior = 5, rotation = 90},
    {enter = Vector3(1567.93, -1898.01, 13.56), spawn = Vector3(460.16, -88.62, 999.55), dimension = 0, interior = 4, rotation = 90}, -- AFK-Cafe


    --{enter = Vector3(2196.92, 1676.52, 11.368), spawn = Vector3(2233.91, 1714.73, 1011.38), dimension = 0, interior = 1, rotation = 90}, CASINO
    {enter = Vector3(1298.34, -797.968, 83.1574), spawn = Vector3(1299.08, -796.83, 1083.03), dimension = 0, interior = 5, rotation = 200},
    {enter = Vector3(2232.87, -1159.71, 24.9416), spawn = Vector3(2214.34, -1150.51, 1024.8), dimension = 0, interior = 15, rotation = 90},
    {enter = Vector3(2412.6, 1123.81, 9.8529), spawn = Vector3(390.87, 173.81, 1007.39), dimension = 0, interior = 3, rotation = 270},
    {enter = Vector3(-2661.35, 1424.39, 23.0043), spawn = Vector3(-2661.01, 1417.74, 921.31), dimension = 0, interior = 3, rotation = 15},
    {enter = Vector3(-2625.33, 1412.62, 6.13148), spawn = Vector3(-2637.45, 1402.24, 905.46), dimension = 0, interior = 3, rotation = 0},
    -- Police departments
    --[[{enter = Vector3(627.642, -571.789, 16.907), spawn = Vector3(246.78, 62.2, 1002.64), dimension = 0, interior = 6, rotation = -85.9025},
    {enter = Vector3(1554.95, -1674.99, 15.3283), spawn = Vector3(246.78, 62.2, 1002.64), dimension = 1, interior = 6, rotation = 90},
    {enter = Vector3(2337.1, 2459.05, 14.0417), spawn = Vector3(288.75, 167.65, 1006.18), dimension = 0, interior = 3, rotation = 180},
    {enter = Vector3(2286.96, 2432.21, 9.9369), spawn = Vector3(238.66, 139.35, 1002.05), dimension = 0, interior = 3, rotation = 180},]]
    {enter = Vector3(-2242.01, 128.521, 34.4174), spawn = Vector3(-2241.07, 128.52, 1034.42), dimension = 0, interior = 6, rotation = 270},
    {enter = Vector3(-857.938, 1535.56, 21.6348), spawn = Vector3(441.98, -49.92, 998.69), dimension = 0, interior = 6, rotation = 323},
    {enter = Vector3(-1887.43, 749.592, 44.4658), spawn = Vector3(441.98, -49.92, 998.69), dimension = 1, interior = 6, rotation = 3691.82},
    {enter = Vector3(2086.42, 2074.48, 10.2043), spawn = Vector3(-100.33, -24.92, 999.74), dimension = 0, interior = 3, rotation = 270},
    {enter = Vector3(-2627.09, 2309.93, 7.35039), spawn = Vector3(140.18, 1366.58, 1082.97), dimension = 0, interior = 5, rotation = -90},
    {enter = Vector3(-2684.77, 819.657, 49.0326), spawn = Vector3(140.18, 1366.58, 1082.97), dimension = 1, interior = 5, rotation = 186},
    {enter = Vector3(-2569.1, 795.796, 48.9819), spawn = Vector3(82.95, 1322.44, 1082.89), dimension = 0, interior = 9, rotation = 2},
    {enter = Vector3(-2539.92, 767.238, 39.0419), spawn = Vector3(82.95, 1322.44, 1082.89), dimension = 1, interior = 9, rotation = 270},
    {enter = Vector3(-2401.5, 869.344, 43.3889), spawn = Vector3(-283.55, 1470.98, 1083.45), dimension = 0, interior = 15, rotation = 270},
    {enter = Vector3(-2627.09, 2283.33, 7.3178), spawn = Vector3(-260.6, 1456.62, 1083.45), dimension = 0, interior = 4, rotation = 270},
    {enter = Vector3(-2084.21, 1160.33, 49.2421), spawn = Vector3(-42.58, 1405.61, 1083.45), dimension = 0, interior = 8, rotation = 362},
    {enter = Vector3(-1913.32, 1252.89, 18.5367), spawn = Vector3(-42.58, 1405.61, 1083.45), dimension = 1, interior = 8, rotation = 362},
    {enter = Vector3(-1820.62, 1116.27, 45.5432), spawn = Vector3(-42.58, 1405.61, 1083.45), dimension = 2, interior = 8, rotation = 180},
    {enter = Vector3(-1742.78, 1174.34, 24.1582), spawn = Vector3(-42.58, 1405.61, 1083.45), dimension = 3, interior = 8, rotation = 362},
    {enter = Vector3(-2157.2, 889.192, 79.0246), spawn = Vector3(-42.58, 1405.61, 1083.45), dimension = 4, interior = 8, rotation = 274},
    {enter = Vector3(-2234.16, 830.667, 53.5143), spawn = Vector3(-42.58, 1405.61, 1083.45), dimension = 5, interior = 8, rotation = 92},
    {enter = Vector3(-2159.69, 1048.74, 79.03), spawn = Vector3(-42.58, 1405.61, 1083.45), dimension = 6, interior = 8, rotation = 280},
    {enter = Vector3(-2239.22, 962.248, 65.6541), spawn = Vector3(-42.58, 1405.61, 1083.45), dimension = 7, interior = 8, rotation = 89},
    {enter = Vector3(-2112.58, 745.657, 68.582), spawn = Vector3(-42.58, 1405.61, 1083.45), dimension = 8, interior = 8, rotation = 180},
    {enter = Vector3(-2205.27, 743.061, 49.4742), spawn = Vector3(-42.58, 1405.61, 1083.45), dimension = 9, interior = 8, rotation = 185},
    {enter = Vector3(-2636.13, 2351.92, 7.59756), spawn = Vector3(-42.58, 1405.61, 1083.45), dimension = 10, interior = 8, rotation = -90},
    {enter = Vector3(-2591.41, -158.542, 3.36046), spawn = Vector3(-42.58, 1405.61, 1083.45), dimension = 11, interior = 8, rotation = 90},
    {enter = Vector3(-2558.79, -79.623, 10.0789), spawn = Vector3(-42.58, 1405.61, 1083.45), dimension = 12, interior = 8, rotation = 0},
    {enter = Vector3(-2514.04, -170.797, 24.2706), spawn = Vector3(-42.58, 1405.61, 1083.45), dimension = 13, interior = 8, rotation = -90},
    {enter = Vector3(-2447.62, 820.771, 34.256), spawn = Vector3(-42.58, 1405.61, 1083.45), dimension = 14, interior = 8, rotation = -182},
    {enter = Vector3(-2338.61, 579.323, 27.0123), spawn = Vector3(-42.58, 1405.61, 1083.45), dimension = 15, interior = 8, rotation = -182},
    {enter = Vector3(-2321.97, 819.509, 44.3052), spawn = Vector3(-42.58, 1405.61, 1083.45), dimension = 16, interior = 8, rotation = -182},
    {enter = Vector3(-2401.48, 930.783, 44.4973), spawn = Vector3(-42.58, 1405.61, 1083.45), dimension = 17, interior = 8, rotation = -94},
    {enter = Vector3(-2381.23, 1281.01, 22.1852), spawn = Vector3(-42.58, 1405.61, 1083.45), dimension = 18, interior = 8, rotation = 269},
    {enter = Vector3(-2279.5, 1148.84, 61.0751), spawn = Vector3(-42.58, 1405.61, 1083.45), dimension = 19, interior = 8, rotation = 260},
    {enter = Vector3(-2280.55, 916.429, 65.6849), spawn = Vector3(-42.58, 1405.61, 1083.45), dimension = 20, interior = 8, rotation = 260},
    {enter = Vector3(-2626.29, 2359.75, 8.00576), spawn = Vector3(-68.69, 1351.97, 1079.28), dimension = 0, interior = 6, rotation = -90},
    {enter = Vector3(-2591.41, -95.538, 3.44458), spawn = Vector3(-68.69, 1351.97, 1079.28), dimension = 1, interior = 6, rotation = 90},
    {enter = Vector3(-2541.61, -145.321, 14.7826), spawn = Vector3(-68.69, 1351.97, 1079.28), dimension = 2, interior = 6, rotation = 0},
    {enter = Vector3(-2449.72, 921.163, 57.2093), spawn = Vector3(-68.69, 1351.97, 1079.28), dimension = 3, interior = 6, rotation = -182},
    {enter = Vector3(-2372.92, 692.687, 34.138), spawn = Vector3(-68.69, 1351.97, 1079.28), dimension = 4, interior = 6, rotation = -182},
    {enter = Vector3(1100.72, 1597.29, 12.54), spawn = Vector3(-1400.0179, -663.382, 1051.232), dimension = 0, interior = 4, rotation = 85},
    {enter = Vector3(1093.99, 1597.04, 12.54), spawn = Vector3(-1464.942, 1556.091, 1052.53), dimension = 0, interior = 14, rotation = 0},
    {enter = Vector3(2779.80, -1812.735, 11.84), spawn = Vector3(-1407.80, -269.016, 1043.65), dimension = 0, interior = 7, rotation = 343},
    {enter = Vector3(2727.618, -1826.647, 11.8), spawn = Vector3(-1463.46, 941.49, 1036.64), dimension = 0, interior = 15, rotation = 306},
    {enter = Vector3(693.632, 1966.4, 4.56038), spawn = Vector3(1212.02, -25.86, 1000.09), dimension = 0, interior = 3, rotation = 198.385},
    {enter = Vector3(2543.15, 1025.16, 9.82133), spawn = Vector3(1212.02, -25.86, 1000.09), dimension = 1, interior = 3, rotation = -3780.01},
    {enter = Vector3(-369.456, 1169.14, 19.3978), spawn = Vector3(2333.11, -1077.1, 1048.04), dimension = 0, interior = 6, rotation = 230},
    {enter = Vector3(794.884, -506.702, 17.1238), spawn = Vector3(2333.11, -1077.1, 1048.04), dimension = 1, interior = 6, rotation = 180},
    {enter = Vector3(2236.53, 167.997, 27.196), spawn = Vector3(2333.11, -1077.1, 1048.04), dimension = 2, interior = 6, rotation = 180},
    {enter = Vector3(206.802, -112.542, 3.98153), spawn = Vector3(2333.11, -1077.1, 1048.04), dimension = 3, interior = 6, rotation = -350.903},
    {enter = Vector3(-1533.1, 2656.65, 55.275), spawn = Vector3(2333.11, -1077.1, 1048.04), dimension = 4, interior = 6, rotation = 180},
    {enter = Vector3(-1051.47, 1549.76, 32.496), spawn = Vector3(2333.11, -1077.1, 1048.04), dimension = 5, interior = 6, rotation = 300},
    {enter = Vector3(-2075.91, -2312.55, 30.1313), spawn = Vector3(2333.11, -1077.1, 1048.04), dimension = 6, interior = 6, rotation = 50},
    {enter = Vector3(-1438.72, -1544.58, 100.713), spawn = Vector3(2333.11, -1077.1, 1048.04), dimension = 7, interior = 6, rotation = 0},
    {enter = Vector3(-2425.94, 337.87, 35.997), spawn = Vector3(2233.8, -1115.36, 1049.91), dimension = 0, interior = 5, rotation = -118},
    {enter = Vector3(1684.74, -2099, 12.8507), spawn = Vector3(2365.3, -1134.92, 1049.91), dimension = 1, interior = 8, rotation = -180},
    {enter = Vector3(315.684, -1769.81, 3.62877), spawn = Vector3(2365.3, -1134.92, 1049.91), dimension = 2, interior = 8, rotation = 180},
    {enter = Vector3(893.617, -1636.3, 13.9872), spawn = Vector3(2365.3, -1134.92, 1049.91), dimension = 3, interior = 8, rotation = -180},
    {enter = Vector3(2449.17, 689.839, 10.471), spawn = Vector3(2365.3, -1134.92, 1049.91), dimension = 4, interior = 8, rotation = 450},
    {enter = Vector3(1408.05, 1897.08, 10.5873), spawn = Vector3(2365.3, -1134.92, 1049.91), dimension = 5, interior = 8, rotation = 450},
    {enter = Vector3(929.122, 2006.43, 10.4781), spawn = Vector3(2365.3, -1134.92, 1049.91), dimension = 6, interior = 8, rotation = 450},
    {enter = Vector3(2111.23, -1279.71, 24.9546), spawn = Vector3(2282.91, -1140.29, 1049.91), dimension = 0, interior = 11, rotation = 180},
    {enter = Vector3(2483.38, -1996.19, 12.8507), spawn = Vector3(2282.91, -1140.29, 1049.91), dimension = 1, interior = 11, rotation = -180},
    {enter = Vector3(1331.94, -633.096, 108.245), spawn = Vector3(2196.79, -1204.35, 1048.05), dimension = 0, interior = 6, rotation = -1.90253},
    {enter = Vector3(-2099.68, 897.485, 75.9661), spawn = Vector3(2196.79, -1204.35, 1048.05), dimension = 1, interior = 6, rotation = 4374.68},
    {enter = Vector3(-2027.73, -40.5488, 37.8263), spawn = Vector3(2196.79, -1204.35, 1048.05), dimension = 2, interior = 6, rotation = 4139.7},
    {enter = Vector3(-2454.44, -135.879, 25.2223), spawn = Vector3(2270.39, -1210.45, 1046.57), dimension = 0, interior = 10, rotation = 90},
    {enter = Vector3(-2213.54, 720.845, 48.4262), spawn = Vector3(2308.79, -1212.88, 1048.03), dimension = 0, interior = 6, rotation = 36},
    {enter = Vector3(-2700.32, 820.308, 48.999), spawn = Vector3(2308.79, -1212.88, 1048.03), dimension = 1, interior = 6, rotation = -180},
    {enter = Vector3(2818.75, 2140.56, 13.7132), spawn = Vector3(2308.79, -1212.88, 1048.03), dimension = 2, interior = 6, rotation = 360},
    {enter = Vector3(2238.99, 1285.05, 9.82528), spawn = Vector3(2217.54, -1076.29, 1049.52), dimension = 0, interior = 1, rotation = -3870.01},
    {enter = Vector3(2226.03, 1837.92, 9.964), spawn = Vector3(2217.54, -1076.29, 1049.52), dimension = 1, interior = 1, rotation = 90},
    {enter = Vector3(1965.11, 1622.54, 11.879), spawn = Vector3(2237.59, -1080.87, 1048.07), dimension = 0, interior = 2, rotation = 270},
    {enter = Vector3(2374.55, 2167.88, 9.8472), spawn = Vector3(2237.59, -1080.87, 1048.07), dimension = 1, interior = 2, rotation = 125},
    {enter = Vector3(1274.28, 2522.47, 9.99299), spawn = Vector3(2317.82, -1026.75, 1049.21), dimension = 0, interior = 9, rotation = 270},
    {enter = Vector3(-2491.98, -38.9587, 24.817), spawn = Vector3(-204.44, -9.17, 1001.3), dimension = 0, interior = 17, rotation = 90},
    {enter = Vector3(2094.7, 2122.13, 9.82222), spawn = Vector3(-204.44, -44.35, 1001.3), dimension = 0, interior = 3, rotation = 180},
    {enter = Vector3(2068.71, -1779.84, 12.5103), spawn = Vector3(-204.44, -27.15, 1001.3), dimension = 0, interior = 16, rotation = -90},
    {enter = Vector3(1975.79, -2036.65, 12.5753), spawn = Vector3(-204.44, -27.15, 1001.3), dimension = 1, interior = 16, rotation = 90},
    {enter = Vector3(2019.49, 1007.11, 9.82133), spawn = Vector3(2018.95, 1017.09, 995.88), dimension = 0, interior = 10, rotation = -3690.01},
    {enter = Vector3(681.579, -473.419, 15.592), spawn = Vector3(681.58, -473.42, 15.59), dimension = 0, interior = 1, rotation = 180},
    {enter = Vector3(-88.5875, 1378.36, 9.56984), spawn = Vector3(-229.03, 1401.23, 26.77), dimension = 0, interior = 18, rotation = 270},
    {enter = Vector3(-2155.92, 645.38, 52.37), spawn = Vector3(-2158.675, 642.8, 1052.4), dimension = 0, interior = 1, rotation = 134},
    {enter = Vector3(1000.33, -919.924, 41.2368), spawn = Vector3(-27.31, -31.38, 1002.55), dimension = 0, interior = 4, rotation = 97},
}
