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

function BankLosSantos:startRob()
	BankManager:getSingleton():startRob("LosSantos")
end


