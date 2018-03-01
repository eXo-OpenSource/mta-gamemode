-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/BankRobbery.lua
-- *  PURPOSE:     Bank robbery class
-- *
-- ****************************************************************************


CasinoHeist = inherit(BankRobbery)
CasinoHeist.SecuricarSpawns = {
    {2300, 1715, 10.94, 0}, --x, y, z, rz
    {2295, 1715, 10.94, 0}, --spawns at garage
    {2290, 1758.9, 10.94, 200}, --spawns at wall
    {2295, 1758.9, 10.94, 200}, 
    {2300, 1758.9, 10.94, 200}, 
}
CasinoHeist.MoneyPerBag = 3000 -- money inside each bag +-RandomMoneyPerBag
CasinoHeist.RandomMoneyPerBag = 500
CasinoHeist.StateMembersPerTruck = 3


local BOMB_TIME = 20*1000

function CasinoHeist:constructor()
	self.ms_FinishMarker = {
		Vector3(969.43, 2059.40, 10), --mafia meat factory
		Vector3(1679.28, 688.10, 10), --boat shop
		Vector3(2648.58, 808.76, 4.7), -- construction site
		Vector3(2879.20, 1598.37, 10), -- rail yards
		Vector3(2919.82, 2117.94, 17), -- water pump east
		Vector3(2200.73, 2793.33, 10), -- north garage near burger shot
	}

	self.ms_BagSpawns = {
		Vector3(2141.81, 1628.31, 992.97),
		Vector3(2142.52, 1629.64, 992.97),
		Vector3(2141.59, 1629.94, 992.97),
		Vector3(2141.55, 1630.82, 992.97),
		Vector3(2142.34, 1631.25, 992.97),
		Vector3(2141.79, 1632.23, 992.97),
		Vector3(2142.31, 1632.73, 992.97),
		Vector3(2141.67, 1633.65, 992.97),
		Vector3(2142.47, 1634.40, 992.97),
		Vector3(2146.70, 1627.94, 992.97),
		Vector3(2145.91, 1628.62, 992.97),
		Vector3(2145.94, 1629.72, 992.97),
		Vector3(2147.06, 1630.03, 992.97),
		Vector3(2146.35, 1630.47, 992.97),
		Vector3(2146.76, 1631.21, 992.97),
		Vector3(2145.66, 1631.03, 992.97),
		Vector3(2146.67, 1632.04, 992.97),
		Vector3(2145.90, 1632.58, 992.97),
		Vector3(2146.90, 1633.70, 992.97),
		Vector3(2146.21, 1634.17, 992.97),
		Vector3(2141.53, 1634.42, 992.97),
	}
	self.ms_BagSpawnInterior = 1
    
    self.m_SecuriCarSaveColshape = createColCuboid(2252.6, 1680.01, 0, 64.6, 83, 18)
    self.m_SecuricarsById = {}

    self.m_CurrentMoney = math.random(2000, 5000)
    self.ms_MoneyPerBag = 3000
    self.m_MaxBagsPerTruck = #VEHICLE_OBJECT_ATTACH_POSITIONS[428].positions
	self:build()
end

function CasinoHeist:build()
	self.m_HackableComputer = createObject(2008, 2168.38, 1603.80, 998.97, 0, 0, 90.00)
	self.m_HackableComputer:setInterior(1)
	self.m_HackableComputer:setData("clickable", true, true)
	self.m_HackableComputer:setData("bankPC", true, true)


	self.m_SafeDoor = createObject(2634, 2144.19, 1627.13, 994.3, 0, 0, 180)
	self.m_SafeDoor.m_Open = false
	self.m_SafeDoor:setInterior(1)
	self.m_BankDoor = createObject(3089, 2147.06, 1604.70, 1006.49)
	self.m_BankDoor:setInterior(1)


	self.m_SecurityRoomShape = createColCuboid(2140.20, 1626.9, 992, 8, 17, 6)
	self.m_SecurityRoomShape:setInterior(1)
	self.m_Timer = false
    self.m_ColShape = createColSphere(2283.52, 1710.49, 11.05, 60)
    
	--self:spawnGuards()
	self:createSafes()

    self.m_TruckLeaveColBind = bind(CasinoHeist.Event_OnTruckLeaveCol, self)
    addEventHandler("onColShapeLeave", self.m_SecuriCarSaveColshape, self.m_TruckLeaveColBind)

    self:spawnPed(295, Vector3(2151.26, 1605.34, 1006.18), 0) --ped inside security room
	self.m_Ped:setInterior(1)

    --roof access question markers
    --self.m_RightMarker = createMarker
    InteriorEnterExit:new(Vector3(2268.31, 1619.54, 94.92), Vector3(2265.02, 1619.56, 1090.45), 270, 270, 1) --right 
    InteriorEnterExit:new(Vector3(2268.41, 1675.68, 94.92), Vector3(2265.05, 1675.85, 1090.45), 270, 270, 1) --left
    local elevInside = Elevator:new()
    elevInside:addStation("Dach", Vector3(2266.42, 1647.51, 1084.23), 270, 1, 0)
    elevInside:addStation("Casino", Vector3(2136.40, 1599.46, 1008.36), 270, 1, 0)
    elevInside:addStation("Verwaltung", Vector3(2155.91, 1598.01, 999.97), 270, 1, 0)
end

function CasinoHeist:updateMoneyAmount()
    
    self:updateVehicles()
end

function CasinoHeist:getDifficulty() -- 0-5, 0 = no heist available, 5 = 5 securicars are there
    local moneyPerTruck = self.ms_MoneyPerBag * self.m_MaxBagsPerTruck
    local min_money = moneyPerTruck/2
    local difficulty =  math.ceil((self.m_CurrentMoney) / moneyPerTruck)
    --TODO recalculate with the online state members
    return math.min((self.m_CurrentMoney > min_money) and difficulty or 0, 5)
end

function CasinoHeist:updateVehicles()
    --if difficulty got higher
    if #self.m_SecuricarsById < self:getDifficulty() then
        for i = (#self.m_SecuricarsById)+1, self:getDifficulty() do
            outputDebug(i, self:getDifficulty())
            local truck = self:createTruck(unpack(CasinoHeist.SecuricarSpawns[i]))
            self:setTruckActive(truck, true)
            table.insert(self.m_SecuricarsById, truck)
        end
    else
        for i = #self.m_SecuricarsById, self:getDifficulty()+1, -1 do
            local truck = table.remove(self.m_SecuricarsById, i)
            truck:destroy()
        end
    end
end

function CasinoHeist:startRob(player)
	self:startRobGeneral(player)

	PlayerManager:getSingleton():breakingNews("Eine derzeit unbekannte Fraktion überfällt die Palomino-Creek Bank!")
	Discord:getSingleton():outputBreakingNews("Eine derzeit unbekannte Fraktion überfällt die Palomino-Creek Bank!")
	FactionState:getSingleton():sendWarning("Die Bank von Palomino Creek wird überfallen!", "Neuer Einsatz", true, {2318.43, 11.37, 26.48})

	local pos = self.m_BankDoor:getPosition()
	self.m_BankDoor:move(1500, pos.x, pos.y, pos.z, 0, 0, -120, "InOutQuad")

	triggerClientEvent("bankAlarm", root, 2282.03, 1726.15, 11.04) --back
    triggerClientEvent("bankAlarm", root, 2193.39, 1677.15, 12.37) --front
	
	--addEventHandler("onVehicleStartEnter", self.m_Truck, bind(self.Event_OnTruckStartEnter, self))

    self.m_HackMarker = createMarker(self.m_HackableComputer.position + Vector3(0, 0, 3), "arrow", 0.8, 255, 255, 0)
    self.m_HackMarker:setInterior(1)
    
end

function CasinoHeist:spawnGuards()
	--[[self.m_GuardPed1 = GuardActor:new(Vector3(2315.25, 20.34, 26.53))
	self.m_GuardPed1:setRotation(270, 0, 270, "default", true)
	self.m_GuardPed1:setFrozen(true)
	self.m_GuardPed1.Colshape = createColCuboid(2314.4 ,1.15 ,25 ,2.5 ,21.45 , 4)
	addEventHandler("onColShapeHit", self.m_GuardPed1.Colshape, function(hitElement, dim)
		if dim and hitElement.type == "player" then
			if hitElement:getFaction() and hitElement:getFaction():isEvilFaction() then
				self.m_GuardPed1:startShooting(hitElement)
			end
		end

	end)]]
end

function CasinoHeist:onRoofMarkerHit(hitEle, dim)
    if isElement(hitEle) and dim then

    end
end


function CasinoHeist:openSafeDoor()
	local pos = self.m_SafeDoor:getPosition()
	self.m_SafeDoor:move(3000, 2145.44, 1626.16, pos.z, 0, 0, 100, "InOutQuad")
	self.m_SafeDoor.m_Open = true
end

function CasinoHeist:createSafes()

	self.m_Safes = {} --72
	--left side
	--[[
		2140.99, 1635.64, 993.04
Rotation: 0, 0, 90.00
Vector3(2147.37, 1635.64, 993.04
Rotation: 0, 0, 270.00
	]]
	for w = 0, 8 do
		for h = 0, 4 do 
			local safe = createObject(2332, 2140.99, 1635.64 + w * 0.86, 993.04 + h * 0.88, 0, 0, 90)
			table.insert(self.m_Safes, safe)
			safe:setCollisionsEnabled(true)
			safe:setInterior(1)
			safe:setData("clickable", true, true)
			addEventHandler( "onElementClicked", safe, self.m_OnSafeClickFunction)
		end
	end
	--right side
	for w = 0, 8 do
		for h = 0, 4 do 
			local safe = createObject(2332, 2147.37, 1635.64 + w * 0.86, 993.04 + h * 0.88, 0, 0, 270)
			table.insert(self.m_Safes, safe)
			safe:setCollisionsEnabled(true)
			safe:setInterior(1)
			safe:setData("clickable", true, true)
			addEventHandler( "onElementClicked", safe, self.m_OnSafeClickFunction)
		end
	end
end

function CasinoHeist:Event_OnTruckLeaveCol(hitEle, dim)
    if not hitEle:getData("BankRobberyTruck") then return end
    if not dim then return end
    if hitEle:getController() then
        outputDebug(hitEle:getController():getName(), "klaut ein Securicar")
    else
        hitEle:respawn()
    end
end

function CasinoHeist:BombArea_Place(bombArea, player)
	--[[if not player:getFaction() then
		player:sendError(_("Banken kannst du nur ausrauben wenn du Mitglied einer bösen Fraktion bist", player))
		return false
	end

	if not ActionsCheck:getSingleton():isActionAllowed(player) then	return false end

	if not DEBUG and FactionState:getSingleton():countPlayers() < 5 then
		player:sendError(_("Um den Überfall starten zu können müssen mindestens 5 Staats-Fraktionisten online sein!", player))
		return false
	end

	for k, player in pairs(getElementsWithinColShape(self.m_BombColShape, "player")) do
		player:triggerEvent("Countdown", BOMB_TIME/1000, "Bombe zündet")

		local faction = player:getFaction()
		if faction and faction:isEvilFaction() then
			player:reportCrime(Crime.BankRobbery)

		end
	end
	return true]]
end

function CasinoHeist:BombArea_Explode(bombArea, player)
	--[[self:startRob(player)
	for index, brick in pairs(self.m_BombableBricks) do
		brick:destroy()
	end]]
end
