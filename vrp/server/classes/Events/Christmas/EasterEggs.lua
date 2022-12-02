-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Events/Christmas/EasterEggs.lua
-- *  PURPOSE:     Ghost Ship class
-- *
-- ****************************************************************************

ChristmasEasterEggs = inherit(Singleton)
ChristmasEasterEggs.PresentPositions = {
	Vector3(1858.16, -1852.34, 13.58), Vector3(2030.61, -1900.76, 13.55), Vector3(2202.82, -1965.37, 14.05),
	Vector3(2807.91, -1063.38, 30.59), Vector3(2715.58, -1877.96, 9.52), Vector3(2060.74, -1958.03, 7.98),
	Vector3(2360.18, -2150.92, 13.58), Vector3(1865.23, -2628.92, 13.57), Vector3(1467.07, -2390.93, 13.55),
	Vector3(1001.31, -2243.35, 1.90), Vector3(417.00, -1138.95, 76.28), Vector3(783.88, -840.92, 62.86),
	Vector3(940.30, -1053.22, 31.60), Vector3(895.72, -1297.28, 13.78), Vector3(1030.41, -1432.44, 13.55),
	Vector3(1109.54, -1603.67, 20.56), Vector3(1121.38, -1778.16, 16.59), Vector3(1285.37, -1877.98, 13.55),
	Vector3(1693.27, -1967.80, 8.67), Vector3(2045.37, -2048.91, 13.55), Vector3(2303.25, -2009.04, 13.56),
	Vector3(2549.40, -1729.77, 6.24), Vector3(682.95, -1430.55, 16.25), Vector3(2796.78, -1466.33, 36.09),
	Vector3(2536.56, -1984.59, 13.55), Vector3(2315.75, -1259.08, 27.98), Vector3(2260.82, -1092.27, 41.60),
	Vector3(1988.81, -975.82, 32.13), Vector3(1814.28, -1309.60, 13.70), Vector3(1451.05, -1012.17, 26.84),
	Vector3(1297.00, -1082.17, 25.98), Vector3(559.42, -1568.03, 16.12), Vector3(286.59, -1617.90, 33.06),
	Vector3(320.54, -1504.36, 24.92), Vector3(733.92, -1369.68, 25.69), Vector3(758.47, -1101.20, 21.85),
	Vector3(1353.22, -1890.23, 17.72), Vector3(1463.86, -1906.13, 22.32), Vector3(1654.32, -1839.29, 13.55),
	Vector3(1700.69, -1684.16, 20.21), Vector3(1731.92, -1509.17, 13.42), Vector3(2022.57, -1404.06, 17.18),
	Vector3(2508.26, -1474.12, 24.85), Vector3(2613.96, -1393.99, 34.92), Vector3(1293.60, -769.84, 95.96),
}

function ChristmasEasterEggs:constructor()
    GlobalTimer:getSingleton():registerEvent(function()
        self:startPresentSpawnEasterEgg()
    end, "Christmas Easter Egg Present Spawning", nil, math.random(17, 20), 0)
end

function ChristmasEasterEggs:startPresentSpawnEasterEgg()
    local posTbl = Randomizer:getRandomOf(math.random(10, 15), ChristmasEasterEggs.PresentPositions)
    for i, pos in pairs(posTbl) do
        ItemManager:getSingleton():getInstance("Päckchen"):addObject(sql:lastInsertId(), Vector3(pos.x, pos.y, pos.z - 0.55), Vector3(0, 0, 180), 0, 0)
    end

    for i, player in pairs(PlayerManager:getSingleton():getReadyPlayers()) do
        player:triggerEvent("breakingNews", "Schneit es?", "Weihnachts News")
        player:triggerEvent("breakingNews", "Berichten zufolge soll der Weihnachtsmann in Los Santos Geschenke verloren haben.", "Weihnachts News")
        player:triggerEvent("breakingNews", "Haltet also die Augen auf!", "Weihnachts News")
    end
end