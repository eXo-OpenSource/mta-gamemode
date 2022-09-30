-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/VehicleRcUpgradeShop.lua
-- *  PURPOSE:     Vehicle rc shop class
-- *
-- ****************************************************************************
VehicleRcUpgradeShop = inherit(Singleton)

addRemoteEvents{"requestOwningRcVehicle", "onRcUpgradeBuy", "requestRcVans"}
function VehicleRcUpgradeShop:constructor()
	InteriorEnterExit:new(Vector3(332.172, -1337.802, 14.408), Vector3(-2240.65, 137.21, 1035.41), 270, 205, 6)

	self.m_UpgradeNPC = Ped.create(306,Vector3(-2238.13, 128.59, 1035.41), 0)
	self.m_UpgradeNPC:setInterior(6)
	ElementInfo:new(self.m_UpgradeNPC, "RC Fahrzeugverkauf", 1.3)
	self.m_UpgradeNPC:setData("NPC:Immortal", true, true)
	self.m_UpgradeNPC:setData("Ped:fakeNameTag", "Zero", true)
	self.m_UpgradeNPC:setData("clickable", true, true)
	self.m_UpgradeNPC:setFrozen(true)

	self.m_Blip = Blip:new("RcShop.png", 332.172, -1337.802, root, 400)
	self.m_Blip:setDisplayText("RC Shop", BLIP_CATEGORY.Shop)
	self.m_Blip:setOptionalColor({37, 78, 108})

	self.m_BankAccountServer = BankServer.get("vehicle.rc_upgrade") or BankServer.create("vehicle.rc_upgrade")

	addEventHandler("onElementClicked", self.m_UpgradeNPC, bind(self.Event_onUpgradeNPCClick, self))
	addEventHandler("requestOwningRcVehicle", root, bind(self.Event_requestOwningRcVehicle, self))
	addEventHandler("onRcUpgradeBuy", root, bind(self.Event_onUpgradeBuy, self))
	addEventHandler("requestRcVans", root, bind(self.Event_requestRcVans, self))
end

function VehicleRcUpgradeShop:Event_onUpgradeNPCClick(button, state, player)
	if button == "left" and state == "down" then
		if getDistanceBetweenPoints3D(player.position, source.position) < 10 then
			self:openUpgradeGUI(player, vehicle)
		end
	end
end

function VehicleRcUpgradeShop:openUpgradeGUI(player, vehicle)
	player:triggerEvent("openVehicleRcUpgradeGUI", self.m_UpgradeNPC)
end

function VehicleRcUpgradeShop:Event_requestRcVans(type)
	local temp = {}
	local allVehicle
	
	if type == "player" then
		allVehicle = client:getVehicles()
	elseif type == "group" then
		if client:getGroup() then
			allVehicle = client:getGroup():getVehicles()
		end
	end

	for i, vehicle in pairs(allVehicle) do
		if vehicle:getModel() == 459 then
			table.insert(temp, vehicle)
		end
	end
	client:triggerEvent("sendOwningRcVans", temp)
end

function VehicleRcUpgradeShop:Event_requestOwningRcVehicle(vehicle)
	client.rcVan = vehicle
	local temp = vehicle.m_Tunings:getTunings()["RcVehicles"] or {}
	client:triggerEvent("sendOwningRcVehicle", temp)
end

function VehicleRcUpgradeShop:Event_onUpgradeBuy(vehicleId)
	if not RC_UPGRADE_VEHICLE[vehicleId] then return client:sendError(_("Internal Error: Invalid Upgrade", client)) end
	
	if client:getBankMoney() < RC_UPGRADE_VEHICLE_PRICE[vehicleId] then
        client:sendError(_("Du hast nicht genügend Geld!", client))
        return
    end
	if instanceof(client.rcVan, GroupVehicle) then
		if client.rcVan:getGroup() ~= client:getGroup() then
			client:sendError(_("Das Fahrzeug gehört nicht deiner Gruppe!", client))
			return
		end
		if not PermissionsManager:getSingleton():hasPlayerPermissionsTo(client, "group", "buyRcVehicles") then
			client:sendError(_("Du bist nicht berechtigt RC Fahrzeuge zu kaufen!", client))
			return
		end
	elseif client.rcVan:isPermanent() then
		if client.rcVan:getOwner() ~= client:getId() then
			client:sendError(_("Das Fahrzeug gehört nicht dir!", client))
			return
		end
	else
		client:sendError(_("Du kannst keine RC Fahrzeuge für dieses Fahrzeug kaufen!", client))
		return
	end
	if table.find(client.rcVan.m_Tunings:getTunings()["RcVehicles"], vehicleId) then
		client:sendError(_("Du besitzt dieses RC Fahrzeug bereits.", client))
		return
	end


    if client:transferBankMoney(self.m_BankAccountServer, RC_UPGRADE_VEHICLE_PRICE[vehicleId], "RcUpgradeShop", "Vehicle", "Tuning") then
		table.insert(client.rcVan.m_Tunings:getTunings()["RcVehicles"], vehicleId)
		client.rcVan:setData("RcVehicles", client.rcVan.m_Tunings:getTunings()["RcVehicles"], true)
		client:triggerEvent("sendOwningRcVehicle", client.rcVan.m_Tunings:getTunings()["RcVehicles"])
		
		RcVanExtensionLastUse[client.rcVan:getId()][vehicleId] = 0
		RcVanExtensionBattery[client.rcVan:getId()][vehicleId] = 900

		client:sendSuccess(_("Upgrade gekauft!", client))
		if instanceof(client.rcVan, PermanentVehicle) then
			client.rcVan:save()
		end
	end
end