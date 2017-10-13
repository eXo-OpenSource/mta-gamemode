--//
--||  PROJECT:  fireElements
--||  AUTHOR:   MasterM
--||  DATE:     October 2015
--\\


--//
--||  settings
--\\

local setting_decayTime = 10000 -- duration in ms to decrease the fire size (only when decaying is set to true)


--//
--||  script
--\\

local tblFires = {}
local tblLastFireOfPlayer = {} -- spam protection
addEvent("fireElements:requestFireDeletion", true)
addEvent("fireElements:onFireExtinguish")


--//
--||  destroyFireElement
--||  	parameters:
--||  		uElement	= the fire element
--||  		uDestroyer	= the player who should destroy (extinguish) the fire, otherwise false
--||  	returns: success of the function
--\\

function destroyFireElement(uElement, uDestroyer)
	if tblFires[uElement] then
		triggerClientEvent("fireElements:onFireDestroy", resourceRoot, uElement) -- uElement cannot be the triggered source element because it's destroyed lol
		if isElement(tblFires[uElement].uFireRoot) then 
			updateFireInRoot(tblFires[uElement].uFireRoot, tblFires[uElement].iRoot_i, tblFires[uElement].iRoot_v, 0, true)
		end
		if isElement(uElement) then
			triggerEvent("fireElements:onFireExtinguish", uElement, uDestroyer, tblFires[uElement].iSize)
			destroyElement(uElement)
		end
		if isTimer(tblFires[uElement].uDecayTimer) then
			killTimer(tblFires[uElement].uDecayTimer)
		end
		tblFires[uElement] = nil
		return true
	end
	return false
end


--//
--||  decreaseFireSize (local)
--||  	parameters:
--||  		uFire		= the fire element
--\\

local function decreaseFireSize(uFire)
	if tblFires[uFire] and tblFires[uFire].iSize > 1 then
		tblFires[uFire].iSize = tblFires[uFire].iSize - 1
		setElementHealth(uFire, 100) -- renew fire
		triggerClientEvent("fireElements:onFireChangeSize", uFire, tblFires[uFire].iSize)
		if isElement(tblFires[uFire].uFireRoot) then 
			updateFireInRoot(tblFires[uFire].uFireRoot, tblFires[uFire].iRoot_i, tblFires[uFire].iRoot_v, tblFires[uFire].iSize, true)
		end
		return true
	end
	return false
end


--//
--||  setFireSize
--||  	parameters:
--||  		uFire		= the fire element
--||  		iSize		= the new size
--\\

function setFireSize(uFire, iSize)
	if tblFires[uFire] then
		tblFires[uFire].iSize = iSize
		setElementHealth(uFire, 100) -- renew fire
		triggerClientEvent("fireElements:onFireChangeSize", uFire, iSize)
		--dont update the fire root because this may cause an endless loop
		return true
	end
	return false
end


--//
--||  setFireDecaying
--||  	parameters:
--||  		uFire		= the fire element
--||  		bDecaying	= should the fire extinguish itself?
--\\


function setFireDecaying(uFire, bDecaying)
	if isTimer(tblFires[uFire].uDecayTimer) then
		killTimer(tblFires[uFire].uDecayTimer)
	end

	if bDecaying then
		tblFires[uFire].uDecayTimer = setTimer(function()
			if tblFires[uFire].iSize > 1 then
				decreaseFireSize(uFire)
			else
				destroyFireElement(uFire)
			end
		end, setting_decayTime+math.random(-500,500), tblFires[uFire].iSize)
	end
	return true
end


--//
--||  createFireElement
--||  	parameters:
--||  		iX, iY, iZ	= coordinates of the new fire
--||  		iSize		= the size between 1-3, where 1 equals small
--||  		bDecaying	= should the fire extinguish itself?
--||  	returns: the fire element (a ped)
--\\

function createFireElement(iX, iY, iZ, iSize, bDecaying, uFireRoot, iRoot_i, iRoot_v)
	if tonumber(iX) and tonumber(iY) and tonumber(iZ) and tonumber(iSize) and iSize >= 1 and iSize <= 3 then
		local uPed = createPed(0, iX, iY, iZ, 0, false)
			setElementFrozen(uPed, true)
			setElementAlpha(uPed, 0)
		tblFires[uPed] = {}
		tblFires[uPed].iSize = iSize
		tblFires[uPed].uFireRoot = uFireRoot
		tblFires[uPed].iRoot_i = iRoot_i
		tblFires[uPed].iRoot_v = iRoot_v
		setFireDecaying(uPed, bDecaying)
		triggerClientEvent("fireElements:onFireCreate", uPed, iSize)

		addEventHandler("fireElements:requestFireDeletion", uPed, destroyFireElement)
		return uPed
	end
	return false
end


--//
--||  events
--\\

addEventHandler("fireElements:requestFireDeletion", resourceRoot, function()
	local iCx, iCy, iCz = getElementPosition(client)
	local iCx, iCy, iCz = getElementPosition(source)
	local iDist = 5
	if isPedInVehicle(client) then iDist = 10 end
	if getDistanceBetweenPoints3D(iCx, iCy, iCz, iCx, iCy, iCz) <= iDist then
		if not tblLastFireOfPlayer[client] or getTickCount()-tblLastFireOfPlayer[client] > 50 then
			if tblFires[source].iSize > 1 then
				decreaseFireSize(source)
			else
				destroyFireElement(source, client)
			end
			tblLastFireOfPlayer[client] = getTickCount()
		end
	end
end)


--//
--||  sync
--\\

addEvent("fireElements:onClientRequestsFires", true)
addEventHandler("fireElements:onClientRequestsFires", resourceRoot, function()
	triggerClientEvent(client, "fireElements:onClientRecieveFires", resourceRoot, tblFires)
end)


--[[--test section
addEventHandler("onResourceStart", resourceRoot, function()
	local tblCurrentFires = {}
	addEventHandler("onVehicleExplode", root, function()
		if isElement(source) then --FIX to prevent errors when vehicle gets deleted on explosion
			local iX, iY, iZ = getElementPosition(source)
			tblCurrentFires[source] = {}
			local blip = createBlip(iX, iY, iZ)
			local max = math.random(2,7)
			local cur = 0
			for i=1, max do
				tblCurrentFires[source][i] = createFireElement(iX+math.random(-1.5, 1.5), iY+math.random(-1.5, 1.5), iZ+math.random(-0.5, 0.5), math.random(1,3))
				addEventHandler("fireElements:onFireExtinguish", tblCurrentFires[source][i], function(player)
					cur = cur + 1
					if cur == max then
						destroyElement(blip)
					end
				end)
			end
		end
	end)

	setTimer(function()
		createFireElement(0, 0, 3, 1)
		createFireElement(0, 3, 3, 2)
		createFireElement(0, 6, 3, 3)
	end,500,1)
end)]]

setTimer(function()
    --local uRoot = createFireRoot(-33, 50, 30, 22)
    local uRoot = createFireRoot(2056, -1738, 15, 15)
	local uBlip = createBlip(-33, 50, 0, 20)
    addEventHandler("fireElementKI:onFireRootDestroyed", uRoot, function(tblStatistics)
        outputDebugString("fire root "..inspect(uRoot).." has been extinguished completely. Statistics:")
        iprint(tblStatistics)
		destroyElement(uBlip)
    end)
    setTimer(destroyFireRoot, 15 * 60000, 1, uRoot)
end, 50, 1)