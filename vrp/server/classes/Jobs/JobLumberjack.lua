-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Jobs/JobLumberjack.lua
-- *  PURPOSE:     Lumberjack job class
-- *
-- ****************************************************************************
JobLumberjack = inherit(Job)

function JobLumberjack:constructor()
	Job.constructor(self)
	
	self.m_LoadUpMarker = createMarker(1038.9, -354.2, 72.9, "corona", 4)
	addEventHandler("onMarkerHit", self.m_LoadUpMarker, bind(JobLumberjack.loadUpHit, self))
	
	self.m_DumpMarker = createMarker(-1969.8, -2432.6, 29.5, "corona", 4)
	addEventHandler("onMarkerHit", self.m_DumpMarker, bind(JobLumberjack.dumpHit, self))
	
	for i = 0, 5 do
		AutomaticVehicleSpawner:new(455, 1089 - i*6, -299.9, 74.5, 0, 0, 180, function(v) setVehicleVariant(v, 255, 255) end, self)
	end
	
	addEvent("lumberjackTreeCut", true)
	addEventHandler("lumberjackTreeCut", root, bind(JobLumberjack.Event_lumberjackTreeCut, self))
end

function JobLumberjack:start(player)
	giveWeapon(player, 9, 1, true)
end

function JobLumberjack:stop(player)
	takeWeapon(player, 9)
end

function JobLumberjack:checkRequirements(player)
	if not (player:getJobLevel() >= 2) then
		player:sendError(_("Für diesen Job benötigst du mindestens Joblevel 2", player), 255, 0, 0)
		return false
	end
	return true
end

function JobLumberjack:loadUpHit(hitElement, matchingDimension)
	if getElementType(hitElement) == "player" and matchingDimension then
		if hitElement:getJob() ~= self then
			hitElement:sendMessage(_("Du musst Holzfäller sein, um Bäume aufladen zu können", hitElement), 255, 0, 0)
			return
		end
		
		local vehicle = getPedOccupiedVehicle(hitElement)
		if not vehicle or getElementModel(vehicle) ~= 455 then
			hitElement:sendMessage(_("Bitte benutze einen Flatbed", hitElement), 255, 0, 0)
			return
		end
		
		for k, v in pairs(getAttachedElements(vehicle)) do
			destroyElement(v)
		end
		
		for i = 1, 4 do
			for j = 1, 6 do
				local x, y, z = getElementPosition(vehicle)
				local object = createObject(837, x, y, z)
				attachElements(object, vehicle, -1 + j * 0.3, -1.5, i * 0.2, 0, 0, 90)
				setElementParent(object, vehicle) -- Deletes the object automatically when the vehicle will be destroyed (e.g. by spawn system)
			end
		end
		
		hitElement:triggerEvent("lumberjackTreesLoadUp", root)
	end
end

function JobLumberjack:dumpHit(hitElement, matchingDimension)
	if getElementType(hitElement) == "player" and matchingDimension then
		local vehicle = getPedOccupiedVehicle(hitElement)
		if not vehicle or getElementModel(vehicle) ~= 455 then
			hitElement:sendMessage(_("Bitte steige in einen Flatbed ein", hitElement))
			return
		end
		if hitElement:getJob() ~= self then
			return
		end
	
		local numTrees = hitElement:getData("lumberjack:Trees")
		if not numTrees or numTrees == 0 then
			hitElement:sendMessage(_("Säge und lade zuerst einige Bäume auf!", hitElement), 255, 0, 0)
			return
		end
		
		hitElement:setData("lumberjack:Trees", 0)
		
		-- Give money and experience points
		hitElement:giveMoney(numTrees * 40)
		hitElement:givePoints(numTrees)
		
		for k, v in pairs(getAttachedElements(vehicle)) do
			destroyElement(v)
		end
	end
end

function JobLumberjack:Event_lumberjackTreeCut()
	if client:getJob() ~= self then
		return
	end

	-- Todo: Check deltaTime (--> security)
	client:setData("lumberjack:Trees", (client:getData("lumberjack:Trees") or 0) + 1)
end
