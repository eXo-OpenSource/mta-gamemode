-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Factions/Actions/Fire.lua
-- *  PURPOSE:     Fire class
-- *
-- ****************************************************************************
Fire = inherit(Object)
Fire.Map = {}
Fire.PedMap = {}
Fire.PlayerMap = {}
Fire.Settings = {
	["DecayTime"] = 10000
}

function Fire:constructor(iX, iY, iZ, iSize, bDecaying, uFireRoot, iRoot_i, iRoot_v)
	if tonumber(iX) and tonumber(iY) and tonumber(iZ) and tonumber(iSize) and iSize >= 1 and iSize <= 3 then
		self.m_Ped = createPed(0, iX, iY, iZ, 0, false)
			setElementFrozen(self.m_Ped, true)
			setElementAlpha(self.m_Ped, 0)
		self.m_iSize = iSize
		self.m_uFireRoot = uFireRoot
		self.m_iRoot_i = iRoot_i
		self.m_iRoot_v = iRoot_v
		self:setFireDecaying(bDecaying)
		triggerClientEvent("fireElements:onFireCreate", self.m_Ped, iSize)

		addEventHandler("fireElements:requestFireDeletion", self.m_Ped, function() delete(self) end)
		Fire.Map[self.m_Ped] = self
		return self
	end
	return false
end

function Fire:destructor()
	triggerClientEvent("fireElements:onFireDestroy", resourceRoot, self.m_Ped) -- uElement cannot be the triggered source element because it's destroyed lol
	if self.uFireRoot then
		self.m_uFireRoot:updateFire(self.m_iRoot_i, self.m_iRoot_v, 0, true)
	end
	if isElement(self.m_Ped) then
		triggerEvent("fireElements:onFireExtinguish", self.m_Ped, self.m_Extinguisher, self.m_iSize)
		destroyElement(self.m_Ped)
	end
	if isTimer(self.m_uDecayTimer) then
		killTimer(self.m_uDecayTimer)
	end

	return true
end

function Fire:decreaseFireSize()
	if self.m_iSize > 1 then
		self.m_iSize = self.m_iSize -1
		setElementHealth(self.m_Ped, 100) -- renew fire
		triggerClientEvent("fireElements:onFireChangeSize", self.m_Ped, self.m_iSize)
		if self.m_uFireRoot then
			self.m_uFireRoot:updateFire(self.m_.iRoot_i, self.m_.iRoot_v, self.m_.iSize, true)
		end
		return true
	end
	return false
end

function Fire:setFireSize(iSize)
	if self.m_Ped and isElement(self.m_Ped) then
		self.m_iSize = iSize
		setElementHealth(self.m_Ped, 100) -- renew fire
		triggerClientEvent("fireElements:onFireChangeSize", self.m_Ped, iSize)
		--dont update the fire root because this may cause an endless loop
		return true
	end
	return false
end

function Fire:setFireDecaying(bDecaying)
	if isTimer(self.m_uDecayTimer) then
		killTimer(self.m_uDecayTimer)
	end

	if bDecaying then
		self.m_uDecayTimer = setTimer(function()
			if self.iSize > 1 then
				self:decreaseFireSize()
			else
				self:destroyFireElement()
			end
		end, Fire.Settings["DecayTime"]+math.random(-500,500), self.m_iSize)
	end
	return true
end

function Fire:setExtinguisher(player)
	self.m_Extinguisher = player
end

addEvent("fireElements:requestFireDeletion", true)
addEvent("fireElements:onFireExtinguish")

addEventHandler("fireElements:requestFireDeletion", resourceRoot, function()
	local iCx, iCy, iCz = getElementPosition(client)
	local iCx, iCy, iCz = getElementPosition(source)
	local iDist = 5
	if isPedInVehicle(client) then iDist = 10 end
	if getDistanceBetweenPoints3D(iCx, iCy, iCz, iCx, iCy, iCz) <= iDist then
		if not Fire.PlayerMap[client] or getTickCount()-Fire.PlayerMap[client] > 50 then
			if Fire.Map[self.m_Ped].iSize > 1 then
				Fire.Map[self.m_Ped]:decreaseFireSize()
			else
				Fire.Map[self.m_Ped]:setExtinguisher(client)
				delete(Fire.Map[self.m_Ped])
			end
			Fire.PlayerMap[client] = getTickCount()
		end
	end
end)

addEvent("fireElements:onClientRequestsFires", true)
addEventHandler("fireElements:onClientRequestsFires", resourceRoot, function()
	local fires = {}
	for ped, fire in pairs(Fire.Map) do
		fires[ped] = fire.m_iSize
	end
	triggerClientEvent(client, "fireElements:onClientRecieveFires", resourceRoot, fires)
end)
