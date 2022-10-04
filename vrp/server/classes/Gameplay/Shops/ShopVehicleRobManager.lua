-- ****************************************************************************
-- *
-- *  PROJECT:    vRoleplay
-- *  FILE:       server/classes/Vehicle/ShopVehicleRobManager.lua
-- *  PURPOSE:    Shop vehicle rob manager class
-- *
-- ****************************************************************************
ShopVehicleRobManager = inherit(Singleton)

SHOP_VEHICLE_ROB_PAUSE = DEBUG and 0 or 30*60 -- in sec
SHOP_VEHICLE_ROB_PAUSE_SAME_SHOP = DEBUG and 0 or 2*60*60 -- in sec
SHOP_VEHICLE_ROB_MIN_MEMBERS = DEBUG and 0 or 3
SHOP_VEHICLE_ROB_LAST_ROB = 0
SHOP_VEHICLE_ROB_MAX_TIME = 20*60 -- in sec
SHOP_VEHICLE_ROB_IS_STARTABLE = true

ShopVehicleRobManager.InsiderInfoPeds = {
	{["pos"] = Vector3(267.64, 2895.94, 10.24), ["rot"] = 304, ["dim"] = 0},
	{["pos"] = Vector3(-2455.51, -163.62, 26.10), ["rot"] = 45.95, ["dim"] = 0},
	{["pos"] = Vector3(-1422.02, -41.14, 6.00), ["rot"] = 90.31, ["dim"] = 0},
	{["pos"] = Vector3(1475.42, -1637.32, -41.27), ["rot"] = 318.04, ["dim"] = 3},

}

function ShopVehicleRobManager:constructor()
    addRemoteEvents{"ShopVehicleRob:onTryingSteal", "ShopVehicleRob:onCancelPickingLock", "ShopVehicleRob:continuePickingLock", "ShopVehicleRob:onPoliceUnlockVehicle"}
    
	self.m_BankAccountServer = BankServer.get("gameplay.SHOP_VEHICLE_ROB") or BankServer:create("gameplay.SHOP_VEHICLE_ROB")
	
	addEventHandler("ShopVehicleRob:onTryingSteal", root, bind(self.Event_onVehicleSteal, self))
    addEventHandler("ShopVehicleRob:onCancelPickingLock", root, bind(self.Event_onCancelPickingLock, self))
    addEventHandler("ShopVehicleRob:continuePickingLock", root, bind(self.Event_continuePickingLock, self))
    addEventHandler("ShopVehicleRob:onPoliceUnlockVehicle", root, bind(self.Event_onPoliceUnlockVehicle, self))

	self:createInsiderPed()

	Player.getQuitHook():register(
		function(player)
			if player.shopVehicleRob then
				killTimer(player.shopVehicleRob.m_LockPickingTimer)
			end
		end
	)
end

function ShopVehicleRobManager:createInsiderPed()
	self.m_DemandedVehicle = ShopManager.ShopVehicle[math.random(1, #ShopManager.ShopVehicle)]
	local data = ShopVehicleRobManager.InsiderInfoPeds[math.random(1, # ShopVehicleRobManager.InsiderInfoPeds)]
	self.m_InsiderPed = createPed(182, data["pos"], data["rot"])
	self.m_InsiderPed:setDimension(data["dim"])
	self.m_InsiderPed:setData("NPC:Immortal", true, true)
	self.m_InsiderPed:setData("clickable", true, true)
	self.m_InsiderPed:setData("Ped:Name", "Carlos Voiture", true, true)
	self.m_InsiderPed:setData("Ped:fakeNameTag", "Carlos Voiture", true, true)
	self.m_InsiderPed:setFrozen(true)
	addEventHandler("onElementClicked", self.m_InsiderPed, function(button, state, player)
        if button == "left" and state == "down" then
            player:sendPedChatMessage(self.m_InsiderPed:getData("Ped:Name"), _("Jo, was geht? Habe gehört, dass das Fahrzeug %s sehr gefragt ist und gute Preise gezahlt werden.", player, getVehicleNameFromModel(self.m_DemandedVehicle)))
        end
    end)
end

function ShopVehicleRobManager:Event_onVehicleSteal()
    if client:getGroup() then
		if client:getGroup():getType() == "Gang" then
			if not (client:getFaction() and client:getFaction():isStateFaction()) then
				if not client:isFactionDuty() then
					if not timestampCoolDown(SHOP_VEHICLE_ROB_LAST_ROB, SHOP_VEHICLE_ROB_PAUSE) then
						client:sendError(_("Der nächste Autohaus-Überfall ist am/um möglich: %s!", client, getOpticalTimestamp(SHOP_VEHICLE_ROB_LAST_ROB+SHOP_VEHICLE_ROB_PAUSE)))
						return false
					end
					if not timestampCoolDown(ShopManager.VehicleShopsMap[source:getData("ShopId")].m_LastRob, SHOP_VEHICLE_ROB_PAUSE_SAME_SHOP) then
						client:sendError(_("Dieser Shop kann erst am/um überfallen werden: %s!", client, getOpticalTimestamp(ShopManager.VehicleShopsMap[source:getData("ShopId")].m_LastRob+SHOP_VEHICLE_ROB_PAUSE_SAME_SHOP)))
						return false
					end
					if  not SHOP_VEHICLE_ROB_IS_STARTABLE then
						client:sendError(_("Es läuft bereits ein Autohaus-Überfall!", client))
						return false
					end
					if FactionState:getSingleton():countPlayers(true, false) < SHOP_VEHICLE_ROB_MIN_MEMBERS then
						client:sendError(_("Es müssen mindestens %d aktive Staatsfraktionisten online sein!",client, SHOP_VEHICLE_ROB_MIN_MEMBERS))
						return false
					end
					self.m_CurrentRob = ShopVehicleRob:new(client, source)
					SHOP_VEHICLE_ROB_IS_STARTABLE = false
				else
					client:sendError(_("Du bist im Dienst, du darfst keinen Überfall machen!", client))
				end
			else
				client:sendError(_("Du bist Polizist, du darfst keinen Überfall machen!", client))
			end
		else
			client:sendError(_("Du bist Mitglied einer privaten Firma! Nur Gangs können überfallen!", client))
		end
	else
		client:sendError(_("Du bist kein Mitglied einer privaten Gang!", client))
	end
end

function ShopVehicleRobManager:Event_onCancelPickingLock()
	self.m_CurrentRob:stopPickingLock(client)
end

function ShopVehicleRobManager:Event_continuePickingLock()
	if self.m_CurrentRob.m_Gang == client:getGroup() then
		self.m_CurrentRob:startPickingLock(client)
	else
		client:sendError(_("Du bist nicht in der am Überfall beteiligten Gang.", client))
	end
end

function ShopVehicleRobManager:Event_onPoliceUnlockVehicle()
	self.m_CurrentRob:finishPickingLock(client)
	client:sendSuccess(_("Fahrzeug aufgesperrt", client))
	FactionState:getSingleton():sendShortMessage(("%s hat das Schloss vom Fahrzeug geöffnet."):format(client:getName()), 20000)
	FactionState:getSingleton():addLog(client, "Fraktion", ("hat ein gestohlenes Shopfahrzeug (%s) aufgeschlossen."):format(self.m_CurrentRob.m_Vehicle:getName()))
end