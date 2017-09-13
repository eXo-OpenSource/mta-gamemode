--//
--||  PROJECT:  fireElements
--||  AUTHOR:   MasterM
--||  DATE:     October 2015
--\\


addEvent("fireElements:onFireCreate", true)
addEvent("fireElements:onFireDestroy", true)
addEvent("fireElements:onFireChangeSize", true)

--//
--||  useful
--\\

local function destroyElementIfExists(uElement)
	if isElement(uElement) then
		destroyElement(uElement)
		return true
	end
	return false
end


--//
--||  settings
--\\

local setting_tickNoise = false -- tick sound at extinguishing
local setting_smoke = true -- smoke effect at extinguishing
local setting_smokeRenderDistance = 100 -- until which distance the smoke at extinguishing renders
local setting_fireRenderDistance = 50 -- until which distance a small fire renders (x2 for medium, x3 for large)
local setting_extinguishTime = 10 -- not an actual time, but 1/setting chance of fire extinguishing
local setting_extraEffects = true -- create tiny explosions on fire updates (also controls black spots on the ground)

local tblEffectFromFireSize = { -- effect names for different fire sizes
	[1] = "fire",
	[2] = "fire_med",
	[3] = "fire_large",

}

local tblFires = {} -- all active fires


--//
--||  destroyFireElement (local)
--||  	parameters:
--||  		uElement	= the fire element
--||  	returns: success of the function
--\\

local function destroyFireElement(uElement)
	if tblFires[uElement] then
		destroyElementIfExists(tblFires[uElement].uEffect)
		destroyElementIfExists(tblFires[uElement].uBurningCol)
		local uSmoke = tblFires[uElement].uSmokeEffect
		if isElement(uSmoke) then setTimer(destroyElementIfExists, 5000, 1, uSmoke) end -- allow smoke to disappear
		tblFires[uElement] = nil
		return true
	end
	return false
end


--//
--||  handleSmoke (local)
--||  	parameters:
--||  		uFire		= the fire element
--\\

local function handleSmoke(uFire)
	if setting_smoke then
		local iX, iY, iZ	= getElementPosition(localPlayer)
		local iFX, iFY, iFZ = getElementPosition(uFire)
		if getDistanceBetweenPoints3D(iX, iY, iZ, iFX, iFY, iFZ) < setting_smokeRenderDistance then
			if tblFires[uFire] and not tblFires[uFire].iSmokeEffectTime or getTickCount()-tblFires[uFire].iSmokeEffectTime > 2000 then
				destroyElementIfExists(tblFires[uFire].uSmokeEffect)
				local iX, iY, iZ = getElementPosition(uFire)
				local effect = createEffect("explosion_door", iX, iY, iZ)
					setEffectSpeed(effect, 0.5)
					setEffectDensity(effect, tblFires[uFire].iSize/3*2)
				tblFires[uFire].iSmokeEffectTime = getTickCount()
				tblFires[uFire].uSmokeEffect = effect
			end
		end
	end
end


--//
--||  handlePedDamage (local)
--||  	parameters:
--||  		uAttacker, iWeap	= event parameters
--\\

local function handlePedDamage(uAttacker, iWeap)
	if tblFires[source] then
		if iWeap == 42 then -- extinguisher
			if setting_tickNoise and uAttacker == localPlayer then playSoundFrontEnd(37) end
			handleSmoke(source)
			if getElementHealth(source) <= (50) and uAttacker == localPlayer then
				triggerServerEvent("fireElements:requestFireDeletion", source)
			end
		else
			cancelEvent()
		end
	end
end

--//
--||  handlePedWaterCannon (local)
--||  	parameters:
--||  		uPed		= event parameter
--\\

local function handlePedWaterCannon(uPed)
cancelEvent()
	if tblFires[uPed] then
		if getElementModel(source) == 407 then -- fire truck
		handleSmoke(uPed)
			if setting_tickNoise and getVehicleController(source) == localPlayer then playSoundFrontEnd(37) end
			if math.random(1, setting_extinguishTime) == 1 and getVehicleController(source) == localPlayer then
				triggerServerEvent("fireElements:requestFireDeletion", uPed)
			end
		end
	end
end
addEventHandler("onClientPedHitByWaterCannon", root, handlePedWaterCannon)


--//
--||  burnPlayer (local)
--||  	parameters:
--||  		uHitElement,bDim	= event parameter
--\\

local function burnPlayer(uHitElement, bDim)
	if not bDim then return end
	if getElementType(uHitElement) == "player" then
		setPedOnFire(uHitElement, true)
	end
end


--//
--||  changeFireSize (local)
--||  	parameters:
--||  		iSize			= the new size of the fire
--\\

local function changeFireSize(iSize)
	if tblFires[source] then
		tblFires[source].iSize = iSize
		destroyElementIfExists(tblFires[source].uEffect)
		destroyElementIfExists(tblFires[source].uBurningCol)
		local iX, iY, iZ = getElementPosition(source)
		tblFires[source].uEffect = createEffect(tblEffectFromFireSize[iSize], iX, iY, iZ,-90, 0, 0, setting_fireRenderDistance)
		tblFires[source].uBurningCol = createColSphere(iX, iY, iZ + (tblFires[source].iMaterialID and 1 or 0), iSize/4) -- set the col shape higher when correct ground position got determined
		addEventHandler("onClientColShapeHit", tblFires[source].uBurningCol, burnPlayer)
		checkForFireGroundInfo(source)
	end
end


--//
--||  getFireSize
--||  	parameters:
--||  		uFire			= the fire
--\\

function getFireSize(uFire)
	if tblFires[uFire] then
		return tblFires[uFire].iSize
	end
end


--//
--||  checkForFireGroundInfo
--||  	parameters:
--||  		uFire			= the fire
--\\

function checkForFireGroundInfo(uFire)
	if  tblFires[uFire] then
		local iX, iY, iZ = getElementPosition(uFire)
		if setting_extraEffects then
			createExplosion (iX, iY, iZ-2, 12, false, 0, false)
		end
		if not tblFires[uFire].bCorrectPlaced and isElementStreamedIn(uFire) then
			local iNewZ = getGroundPosition(iX, iY, iZ + 100)
			setElementPosition(uFire, iX, iY, iNewZ)
			setElementPosition(tblFires[uFire].uEffect, iX, iY, iNewZ)
			setElementPosition(tblFires[uFire].uBurningCol, iX, iY, iNewZ+1)
			tblFires[uFire].bCorrectPlaced = true
		end
	end
end


--//
--||  createFireElement (local)
--||  	parameters:
--||  		iSize			= the size of the fire
--||  		uPed			= the ped element synced by the server
--\\

local function createFireElement(iSize, uPed)
	if not uPed then uPed = source end
	local iX, iY, iZ = getElementPosition(uPed)
	tblFires[uPed] = {}
	tblFires[uPed].iSize = iSize
	tblFires[uPed].uEffect = createEffect(tblEffectFromFireSize[iSize], iX, iY, iZ,-90, 0, 0, setting_fireRenderDistance)
	tblFires[uPed].uBurningCol = createColSphere(iX, iY, iZ, iSize/4)
	setElementCollidableWith (uPed, localPlayer, false)
	for index,vehicle in ipairs(getElementsByType("vehicle")) do
		setElementCollidableWith(vehicle, uPed, false)
	end
	checkForFireGroundInfo(uPed)
	addEventHandler("onClientPedDamage", uPed, handlePedDamage)
	addEventHandler("onClientColShapeHit", tblFires[uPed].uBurningCol, burnPlayer)
	addEventHandler("onClientElementStreamIn", uPed, function()
		setTimer(function() -- allow the client to let the element fully stream in as this process is apparently asynchronous
			if isElement(uPed) and isElementStreamedIn(uPed) then 
				checkForFireGroundInfo(uPed)
			end
		end, 500, 1)	
	end)
end



--//
--||  events
--\\

addEventHandler("fireElements:onFireCreate", resourceRoot, createFireElement)
addEventHandler("fireElements:onFireDestroy", resourceRoot, destroyFireElement)
addEventHandler("fireElements:onFireChangeSize", resourceRoot, changeFireSize)


--//
--||  sync (get all created fires when client connects to the server)
--\\

addEventHandler("onClientResourceStart", resourceRoot, function()
	addEvent("fireElements:onClientRecieveFires", true)
	addEventHandler("fireElements:onClientRecieveFires", resourceRoot, function(tblFires)
		for i,v in pairs(tblFires) do
			createFireElement(v.iSize, i)
		end
	end)
	triggerServerEvent("fireElements:onClientRequestsFires", root)
end)


--setPedTargetingMarkerEnabled(false) --uncomment this to prevent green aim arrows in fires
--setDevelopmentMode(true) -- debug to show colshapes etc
-- hdug