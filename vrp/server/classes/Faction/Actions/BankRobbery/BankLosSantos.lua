-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/BankRobbery/BankLosSantos.lua
-- *  PURPOSE:     Bank robbery class
-- *
-- ****************************************************************************

--Info 68 Tresors

BankLosSantos = inherit(BankRobbery)
BankLosSantos.Map = {}
BankLosSantos.FinishMarker = {
	Vector3(2766.84, 84.98, 18.39),
	Vector3(2561.50, -949.89, 81.77),
	Vector3(1935.24, 169.98, 36.28)}

BankLosSantos.BagSpawns = {
	Vector3(2307.25, 17.90, 26),
	Vector3(2306.88, 19.09, 26),
	Vector3(2306.97, 20.38, 26),
	Vector3(2308.34, 20.20, 26),
	Vector3(2308.46, 19.16, 26),
	Vector3(2308.46, 17.92, 26),
	Vector3(2309.82, 17.77, 26),
	Vector3(2310.09, 18.91, 26),
	Vector3(2310.11, 20.13, 26),
	Vector3(2311.48, 20.26, 26),
	Vector3(2311.57, 18.95, 26),
	Vector3(2311.55, 17.89, 26),
	Vector3(2312.69, 17.80, 26),
	Vector3(2312.73, 19.90, 26),
	Vector3(2313.57, 20.89, 26),
	Vector3(2313.59, 17.27, 26),
	Vector3(2312.19, 18.31, 26),
	Vector3(2309.27, 19.14, 26),
}

function BankLosSantos:constructor()
	self:build()
end

function BankLosSantos:destructor()

end

function BankLosSantos:destroyRob()
end

function BankLosSantos:build()
end
function BankLosSantos:createSafes()
	self.m_Safes = {
		createObject(2332, 1437.3, -996.20, 12.7, 0, 0, 0),
		createObject(2332, 1437.3, -996.20, 13.6, 0, 0, 0),
		createObject(2332, 1437.3, -996.20, 14.5, 0, 0, 0),
		createObject(2332, 1436.4, -996.20, 12.7, 0, 0, 0),
		createObject(2332, 1435.5, -996.20, 12.7, 0, 0, 0),
		createObject(2332, 1434.6, -996.20, 12.7, 0, 0, 0),
		createObject(2332, 1433.7, -996.20, 12.7, 0, 0, 0),
		createObject(2332, 1432.8, -996.20, 12.7, 0, 0, 0),
		createObject(2332, 1431.9, -996.20, 12.7, 0, 0, 0),
		createObject(2332, 1431.0, -996.20, 12.7, 0, 0, 0),
		createObject(2332, 1430.1, -996.20, 12.7, 0, 0, 0),
		createObject(2332, 1429.2, -996.20, 12.7, 0, 0, 0),
		createObject(2332, 1428.3, -996.20, 12.7, 0, 0, 0),
		createObject(2332, 1436.4, -996.20, 13.6, 0, 0, 0),
		createObject(2332, 1436.4, -996.20, 14.5, 0, 0, 0),
		createObject(2332, 1435.5, -996.20, 13.6, 0, 0, 0),
		createObject(2332, 1434.6, -996.20, 13.6, 0, 0, 0),
		createObject(2332, 1433.7, -996.20, 13.6, 0, 0, 0),
		createObject(2332, 1432.8, -996.20, 13.6, 0, 0, 0),
		createObject(2332, 1431.9, -996.20, 13.6, 0, 0, 0),
		createObject(2332, 1431.0, -996.20, 13.6, 0, 0, 0),
		createObject(2332, 1430.1, -996.20, 13.6, 0, 0, 0),
		createObject(2332, 1429.2, -996.20, 13.6, 0, 0, 0),
		createObject(2332, 1428.3, -996.20, 13.6, 0, 0, 0),
		createObject(2332, 1435.5, -996.20, 14.5, 0, 0, 0),
		createObject(2332, 1434.6, -996.20, 14.5, 0, 0, 0),
		createObject(2332, 1433.7, -996.20, 14.5, 0, 0, 0),
		createObject(2332, 1432.8, -996.20, 14.5, 0, 0, 0),
		createObject(2332, 1431.9, -996.20, 14.5, 0, 0, 0),
		createObject(2332, 1431.0, -996.20, 14.5, 0, 0, 0),
		createObject(2332, 1430.1, -996.20, 14.5, 0, 0, 0),
		createObject(2332, 1429.2, -996.20, 14.5, 0, 0, 0),
		createObject(2332, 1428.3, -996.20, 14.5, 0, 0, 0),
		createObject(2332, 1437.3, -1006, 12.7, 0, 0, 180),
		createObject(2332, 1436.4, -1006, 12.7, 0, 0, 180),
		createObject(2332, 1435.5, -1006, 12.7, 0, 0, 180),
		createObject(2332, 1434.6, -1006, 12.7, 0, 0, 180),
		createObject(2332, 1433.7, -1006, 12.7, 0, 0, 180),
		createObject(2332, 1432.8, -1006, 12.7, 0, 0, 180),
		createObject(2332, 1431.9, -1006, 12.7, 0, 0, 180),
		createObject(2332, 1431.0, -1006, 12.7, 0, 0, 180),
		createObject(2332, 1430.1, -1006, 12.7, 0, 0, 180),
		createObject(2332, 1429.2, -1006, 12.7, 0, 0, 180),
		createObject(2332, 1428.3, -1006, 12.7, 0, 0, 180),
		createObject(2332, 1437.3, -1006, 13.6, 0, 0, 180),
		createObject(2332, 1436.4, -1006, 13.6, 0, 0, 180),
		createObject(2332, 1435.5, -1006, 13.6, 0, 0, 180),
		createObject(2332, 1434.6, -1006, 13.6, 0, 0, 180),
		createObject(2332, 1433.7, -1006, 13.6, 0, 0, 180),
		createObject(2332, 1432.8, -1006, 13.6, 0, 0, 180),
		createObject(2332, 1431.9, -1006, 13.6, 0, 0, 180),
		createObject(2332, 1431.0, -1006, 13.6, 0, 0, 180),
		createObject(2332, 1430.1, -1006, 13.6, 0, 0, 180),
		createObject(2332, 1429.2, -1006, 13.6, 0, 0, 180),
		createObject(2332, 1428.3, -1006, 13.6, 0, 0, 180),
		createObject(2332, 1428.3, -1006, 14.5, 0, 0, 180),
		createObject(2332, 1429.2, -1006, 14.5, 0, 0, 180),
		createObject(2332, 1430.1, -1006, 14.5, 0, 0, 180),
		createObject(2332, 1431.0, -1006, 14.5, 0, 0, 180),
		createObject(2332, 1431.9, -1006, 14.5, 0, 0, 180),
		createObject(2332, 1432.8, -1006, 14.5, 0, 0, 180),
		createObject(2332, 1433.7, -1006, 14.5, 0, 0, 180),
		createObject(2332, 1434.6, -1006, 14.5, 0, 0, 180),
		createObject(2332, 1435.5, -1006, 14.5, 0, 0, 180),
		createObject(2332, 1436.4, -1006, 14.5, 0, 0, 180),
		createObject(2332, 1437.3, -1006, 14.5, 0, 0, 180)
	}
	for index, safe in pairs(self.m_Safes) do
		safe:setData("clickable", true, true)
		addEventHandler("onElementClicked", safe, self.m_OnSafeClickFunction)
	end
end

function BankLosSantos:startRob()
	BankManager:getSingleton():startRob("LosSantos")
	BankManager:stopRob()
end
