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

	self.m_Blip = Blip:new("Fire.png", self.m_Position.x, self.m_Position.y)

	self.m_DestroyFireFunc = bind(self.destroyFire, self)

	PlayerManager:getSingleton():breakingNews(_(self.m_Message, getElementsByType("player")[1], self.m_PositionName))

	addRemoteEvents{"requestFireDeletion"}

	for index, pos in pairs(self.m_FireTable) do
		self:create(index, pos)
	end

end

function Fire:create(index, pos)
	local ped = createPed(0, pos)
	ped:setFrozen(true)
	ped:setAlpha(0)
	table.insert(self.m_FirePeds, ped)
	triggerClientEvent("createFire", ped)
	addEventHandler("requestFireDeletion", ped, self.m_DestroyFireFunc)
	return ped
end

function Fire:destroyFire(ped, destroyer)
	if self.m_FirePeds[ped] then
		triggerClientEvent("fireDestroy", resourceRoot, ped)
		if isElement(ped) then
			destroyElement(ped)
		end
		table.remove(self.m_FirePeds, table.find(self.m_FirePeds, ped))
		return true
	end
	return false
end
