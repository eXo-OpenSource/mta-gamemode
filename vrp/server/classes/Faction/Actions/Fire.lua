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
		self.m_Size = iSize
		self.m_FireRoot = uFireRoot
		self.m_Root_i = iRoot_i
		self.m_Root_v = iRoot_v
		self:setFireDecaying(bDecaying)
		self.m_ExtinguishCallbackMap = {}
		triggerClientEvent("fireElements:onFireCreate", self.m_Ped, iSize)
		Fire.Map[self.m_Ped] = self
		return self
	end
	return false
end

function Fire:destructor()
	triggerClientEvent("fireElements:onFireDestroy", resourceRoot, self.m_Ped) -- uElement cannot be the triggered source element because it's destroyed lol
	if isElement(self.m_Ped) then
		for i,v in pairs(self.m_ExtinguishCallbackMap) do
			if type(v) == "function" then
				v(self.m_Extinguisher, self.m_Size)
			end
		end
		destroyElement(self.m_Ped)
	end
	if isTimer(self.m_DecayTimer) then
		killTimer(self.m_DecayTimer)
	end

	return true
end

function Fire:addExtinguishCallback(func)
	table.insert(self.m_ExtinguishCallbackMap, func)
end

function Fire:decreaseFireSize()
	if self.m_Size > 1 then
		self.m_Size = self.m_Size -1
		setElementHealth(self.m_Ped, 100) -- renew fire
		triggerClientEvent("fireElements:onFireChangeSize", self.m_Ped, self.m_Size)
		if self.m_FireRoot then
			self.m_FireRoot:updateFire(self.m_Root_i, self.m_Root_v, self.m_Size, true)
		end
		return true
	end
	return false
end

function Fire:setFireSize(iSize)
	if self.m_Ped and isElement(self.m_Ped) then
		self.m_Size = iSize
		setElementHealth(self.m_Ped, 100) -- renew fire
		triggerClientEvent("fireElements:onFireChangeSize", self.m_Ped, iSize)
		--dont update the fire root because this may cause an endless loop
		return true
	end
	return false
end

function Fire:setFireDecaying(bDecaying)
	if isTimer(self.m_DecayTimer) then
		killTimer(self.m_DecayTimer)
	end

	if bDecaying then
		self.m_DecayTimer = setTimer(function()
			if self.m_Size > 1 then
				self:decreaseFireSize()
			else
				self:destroyFireElement()
			end
		end, Fire.Settings["DecayTime"]+math.random(-500,500), self.m_Size)
	end
	return true
end

function Fire:setExtinguisher(player)
	self.m_Extinguisher = player
end

addEvent("fireElements:requestFireDeletion", true)

addEventHandler("fireElements:requestFireDeletion", resourceRoot, function()
	local iCx, iCy, iCz = getElementPosition(client)
	local iCx, iCy, iCz = getElementPosition(source)
	local iDist = 5
	if isPedInVehicle(client) then iDist = 10 end
	if getDistanceBetweenPoints3D(iCx, iCy, iCz, iCx, iCy, iCz) <= iDist then
		if not Fire.PlayerMap[client] or getTickCount()-Fire.PlayerMap[client] > 50 then
			if Fire.Map[source].m_Size > 1 then
				Fire.Map[source]:decreaseFireSize()
			else
				Fire.Map[source]:setExtinguisher(client)
				delete(Fire.Map[source])
			end
			Fire.PlayerMap[client] = getTickCount()
		end
	end
end)

addEvent("fireElements:onClientRequestsFires", true)
addEventHandler("fireElements:onClientRequestsFires", resourceRoot, function()
	local fires = {}
	for ped, fire in pairs(Fire.Map) do
		fires[ped] = fire.m_Size
	end
	triggerClientEvent(client, "fireElements:onClientRecieveFires", resourceRoot, fires)
end)
