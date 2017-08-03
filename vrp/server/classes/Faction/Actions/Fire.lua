-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Factions/Actions/Fire.lua
-- *  PURPOSE:     Fire class
-- *
-- ****************************************************************************
Fire = inherit(Singleton)

function Fire:constructor(fireTable)
	self.m_Position = fireTable["position"]
	self.m_PositionName = getZoneName(self.m_Position).."/"..getZoneName(self.m_Position,true)
	self.m_FirePeds = {}
	self.m_FireTable = fireTable["table"]
	self.m_Message = fireTable["message"]

	self.m_Blip = Blip:new("Fire.png", self.m_Position.x, self.m_Position.y, root, 400)
	self.m_Blip:setOptionalColor(BLIP_COLOR_CONSTANTS.Orange)
	self.m_Blip:setDisplayText("Verkehrsbehinderung")

	self.m_DestroyFireFunc = bind(self.destroyFire, self)

	PlayerManager:getSingleton():breakingNews(self.m_Message, self.m_PositionName)
	FactionRescue:getSingleton():sendWarning(self.m_Message, "Brand-Meldung", true, self.m_Position, self.m_PositionName)
	FactionState:getSingleton():sendWarning(self.m_Message, "Absperrung erforderlich", false, self.m_Position, self.m_PositionName)

	addRemoteEvents{"requestFireDeletion"}
	addEventHandler("requestFireDeletion", root, self.m_DestroyFireFunc)

	for index, pos in pairs(self.m_FireTable) do
		self:create(pos)
	end
end

function Fire:destructor()
	for ped, bool in pairs(self.m_FirePeds) do
		if bool == true and isElement(ped) then
			self:destroyFire(ped)
		end
	end
	delete(self.m_Blip)
end


function Fire:create(pos)
	local ped = createPed(0, pos)
	ped:setFrozen(true)
	ped:setAlpha(0)
	self.m_FirePeds[ped] = true
	triggerClientEvent("createFire", ped)
end

function Fire:getRemainingAmount()
	local count = 0
	for ped, bool in pairs(self.m_FirePeds) do
		if bool == true and isElement(ped) then count = count + 1 end
	end
	return count
end

function Fire:syncFires(player)
	for ped, bool in pairs(self.m_FirePeds) do
		if bool == true and isElement(ped) then
			triggerClientEvent(player, "createFire", ped)
		end
	end
end

function Fire:destroyFire(ped)
	if self.m_FirePeds[ped] then
		triggerClientEvent("destroyFire", resourceRoot, ped)
		if isElement(ped) then
			destroyElement(ped)
		end
		table.remove(self.m_FirePeds, table.find(self.m_FirePeds, ped))
		local remainingFires = self:getRemainingAmount()
		if client then
			client:sendShortMessage(_("Flamme gelöscht! %d übrig!", client, remainingFires))
		end
		if remainingFires <= 0 then
			if client then
				PlayerManager:getSingleton():breakingNews("Das Rescue Team hat den Brand bei %s erfolgreich gelöscht!", self.m_PositionName)
				FactionRescue:getSingleton().m_Faction:giveMoney(#self.m_FireTable * 100, "Brand gelöscht")
			end

			delete(self)
		end
		return true
	end
	return false
end
