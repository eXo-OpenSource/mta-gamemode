Fire = inherit(Singleton)
Fire.Settings = {
	["tickNoise"] = false,
	["smoke"] = true,
	["smokeRenderDistance"] = 100,
	["fireRenderDistance"] = 50,
	["extinguishTime"] = 1,
	["extraEffects"] = true,
}

Fire.EffectFromFireSize = {
	[1] = "fire",
	[2] = "fire_med",
	[3] = "fire_large",
}

function Fire:constructor()
	self.m_Fires = {}
	self.m_LoadingQueue = AutomaticQueue:new()
	self.m_FiresWaitingForColUpdate = {}

	addRemoteEvents{"fireElements:onClientRecieveFires", "fireElements:onFireCreate", "fireElements:onFireDestroy", "fireElements:onFireChangeSize", "refreshFireStatistics"}

	addEventHandler("fireElements:onFireCreate", resourceRoot, bind(self.createFireElement, self))
	addEventHandler("fireElements:onFireDestroy", resourceRoot, bind(self.destroyFireElement, self))
	addEventHandler("fireElements:onFireChangeSize", resourceRoot, bind(self.changeFireSize, self))
	addEventHandler("onClientPedHitByWaterCannon", root, bind(self.handlePedWaterCannon, self))
	addEventHandler("refreshFireStatistics", root, bind(self.updateStatistics, self))


	addEventHandler("fireElements:onClientRecieveFires", resourceRoot, function(fireTable)
		self.m_LoadingQueue:clear()

		local trigger = self.m_LoadingQueue:prepare(THREAD_PIORITY_HIGHEST)
		for ped, size in pairs(fireTable) do
			self:createFireElement(size, ped, true)
		end
		trigger()
	end)
	triggerServerEvent("fireElements:onClientRequestsFires", root)
end

function Fire:destroyElementIfExists(uElement)
	if isElement(uElement) then
		destroyElement(uElement)
		return true
	end
	return false
end

function Fire:addToQueue(element)
	self.m_LoadingQueue:push(element)
end

--//
--||  destroyFireElement (local)
--||  	parameters:
--||  		uElement	= the fire element
--||  	returns: success of the function
--\\

function Fire:destroyFireElement(uElement)
	if self.m_Fires[uElement] then
		self:destroyElementIfExists(self.m_Fires[uElement].uEffect)
		self:destroyElementIfExists(self.m_Fires[uElement].uBurningCol)
		local uSmoke = self.m_Fires[uElement].uSmokeEffect
		if isElement(uSmoke) then setTimer(bind(self.destroyElementIfExists, self), 5000, 1, uSmoke) end -- allow smoke to disappear
		self.m_Fires[uElement] = nil
		return true
	end
	return false
end


--//
--||  handleSmoke (local)
--||  	parameters:
--||  		uFire		= the fire element
--\\

function Fire:handleSmoke(uFire)
	if Fire.Settings["smoke"] then
		local iX, iY, iZ	= getElementPosition(localPlayer)
		local iFX, iFY, iFZ = getElementPosition(uFire)
		if getDistanceBetweenPoints3D(iX, iY, iZ, iFX, iFY, iFZ) < Fire.Settings["smokeRenderDistance"] then
			if self.m_Fires[uFire] and not self.m_Fires[uFire].iSmokeEffectTime or getTickCount()-self.m_Fires[uFire].iSmokeEffectTime > 2000 then
				self:destroyElementIfExists(self.m_Fires[uFire].uSmokeEffect)
				local iX, iY, iZ = getElementPosition(uFire)
				local effect = createEffect("explosion_door", iX, iY, iZ)
					setEffectSpeed(effect, 0.5)
					setEffectDensity(effect, self.m_Fires[uFire].iSize/3*2)
				self.m_Fires[uFire].iSmokeEffectTime = getTickCount()
				self.m_Fires[uFire].uSmokeEffect = effect
			end
		end
	end
end


--//
--||  handlePedDamage (local)
--||  	parameters:
--||  		uAttacker, iWeap	= event parameters
--\\

function Fire:handlePedDamage(uAttacker, iWeap)
	if self.m_Fires[source] then
		if iWeap == 42 then -- extinguisher
			if Fire.Settings["tickNoise"] and uAttacker == localPlayer then playSoundFrontEnd(37) end
			self:handleSmoke(source)
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

function Fire:handlePedWaterCannon(uPed)
cancelEvent()
	if self.m_Fires[uPed] then
		if getElementModel(source) == 407 then -- fire truck
		self:handleSmoke(uPed)
			if Fire.Settings["tickNoise"] and getVehicleController(source) == localPlayer then playSoundFrontEnd(37) end
			if math.random(1, Fire.Settings["extinguishTime"]) == 1 and getVehicleController(source) == localPlayer then
				triggerServerEvent("fireElements:requestFireDeletion", uPed)
			end
		end
	end
end


--//
--||  burnPlayer (local)
--||  	parameters:
--||  		uHitElement,bDim	= event parameter
--\\

function Fire:burnPlayer(uHitElement, bDim)
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

function Fire:changeFireSize(iSize)
	if self.m_Fires[source] then
		self.m_Fires[source].iSize = iSize
		self:destroyElementIfExists(self.m_Fires[source].uEffect)
		self:destroyElementIfExists(self.m_Fires[source].uBurningCol)
		local iX, iY, iZ = getElementPosition(source)
		self.m_Fires[source].uEffect = createEffect(Fire.EffectFromFireSize[iSize], iX, iY, iZ,-90, 0, 0, Fire.Settings["fireRenderDistance"])
		self.m_Fires[source].uBurningCol = createColSphere(iX, iY, iZ + (self.m_Fires[source].iMaterialID and 1 or 0), iSize/4) -- set the col shape higher when correct ground position got determined
		addEventHandler("onClientColShapeHit", self.m_Fires[source].uBurningCol, bind(self.burnPlayer, self))
		self:checkForFireGroundInfo(source)
	end
end


--//
--||  getFireSize
--||  	parameters:
--||  		uFire			= the fire
--\\

function Fire:getFireSize(uFire)
	if self.m_Fires[uFire] then
		return self.m_Fires[uFire].iSize
	end
end


--//
--||  checkForFireGroundInfo
--||  	parameters:
--||  		uFire			= the fire
--\\

function Fire:checkForFireGroundInfo(uFire)
	if self.m_Fires[uFire] then
		local iX, iY, iZ = getElementPosition(uFire)
		if Fire.Settings["extraEffects"] then
			createExplosion (iX, iY, iZ-2, 12, false, 0, false)
		end
		if not self.m_Fires[uFire].bCorrectPlaced and isElementStreamedIn(uFire) then
			local iNewZ = getGroundPosition(iX, iY, iZ + 100)
			setElementPosition(uFire, iX, iY, iNewZ+(self.m_Fires[uFire].iSize/3))
			setElementPosition(self.m_Fires[uFire].uEffect, iX, iY, iNewZ)
			setElementPosition(self.m_Fires[uFire].uBurningCol, iX, iY, iNewZ+1)
			self.m_Fires[uFire].bCorrectPlaced = true

			setElementCollisionsEnabled(uFire, true)
			setElementCollidableWith (uFire, localPlayer, false)
			for index, vehicle in pairs(getElementsByType("vehicle", root, true)) do
				if uFire and isElement(uFire) and vehicle and isElement(vehicle) then
					setElementCollidableWith(vehicle, uFire, false)
				end
			end
		end
	end
end

--//
--||  createFireElement (local)
--||  	parameters:
--||  		iSize			= the size of the fire
--||  		uPed			= the ped element synced by the server
--\\

function Fire:createFireElement(iSize, uPed, inThread)
	if not uPed then uPed = source end
	local iX, iY, iZ = getElementPosition(uPed)
	self.m_Fires[uPed] = {}
	self.m_Fires[uPed].iSize = iSize
	self.m_Fires[uPed].uEffect = createEffect(Fire.EffectFromFireSize[iSize], iX, iY, iZ-5,-90, 0, 0, Fire.Settings["fireRenderDistance"])
	self.m_Fires[uPed].uBurningCol = createColSphere(iX, iY, iZ, iSize/4)
	setElementCollisionsEnabled(uPed, false) --temporary until stream in
	self:checkForFireGroundInfo(uPed)
	addEventHandler("onClientPedDamage", uPed, bind(self.handlePedDamage, self))
	addEventHandler("onClientColShapeHit", self.m_Fires[uPed].uBurningCol, bind(self.burnPlayer, self))
	addEventHandler("onClientElementStreamIn", uPed, function()
		setTimer(function() -- allow the client to let the element fully stream in as this process is apparently asynchronous
			if isElement(uPed) and isElementStreamedIn(uPed) then
				self:checkForFireGroundInfo(uPed)
			end
		end, 500, 1)
	end)
end

function Fire:updateStatistics(tblStats, serverTick, w, h)
	if not self.m_ShortmessageLoaded then
		self.m_ShortmessageLoaded = true
		self.m_StatisticShortMessage = ShortMessage:new("", "Brand-Übersicht", Color.Orange, 6000, nil, function()
			self.m_ShortmessageLoaded = false
		end)
	end
	--[[
		startTime = getTickCount(),
		firesByPlayer = {},
		firesDecayed = 0,
		firesActive = 0,
		firesTotal = 0,
	]]
	local t = ("Zeit seit Ausbruch: %s\nFlammen: %s aktiv, %s seit Ausbruch\n\nbeteiligte Einsatzkräfte:"):format(string.duration((serverTick - tblStats.startTime)/1000), tblStats.firesActive, tblStats.firesTotal)

	for i, v in pairs(tblStats.pointsByPlayer) do
		t = t.. ("\n %s - %s Punkte (%s Feuer gelöscht)"):format(i:getName(), v, tblStats.firesByPlayer[i] or 0)
	end
	t = t.. ("\n\n~~~DEBUG~~~\nDimension (w,h): %s, %s\ngeschätzte Lösch-Zeit (min): %s"):format(w, h, math.sqrt(w*h)/4)
	self.m_StatisticShortMessage:setText(t)
	self.m_StatisticShortMessage:resetTimeout()
end