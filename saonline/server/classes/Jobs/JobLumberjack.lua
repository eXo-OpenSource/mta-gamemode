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
	
	self.m_LoadUpMarker = createMarker(1903.65, -1241.9, 15, "corona", 4)
	addEventHandler("onMarkerHit", self.m_LoadUpMarker, bind(JobLumberjack.loadUpHit, self))
	
	self.m_DumpMarker = createMarker(672.95, -1239.7, 14.8, "corona", 4)
	addEventHandler("onMarkerHit", self.m_DumpMarker, bind(JobLumberjack.dumpHit, self))
	
	createVehicle(455, 1868.5, -1253.8, 14.6, 0, 0, 90, "Lumber", false, 255, 255)
	createVehicle(455, 1893.5, -1253.8, 14.6, 0, 0, 90, "Lumber", false, 255, 255)
	
	addEvent("lumberjackTreeCut", true)
	addEventHandler("lumberjackTreeCut", root, bind(JobLumberjack.Event_lumberjackTreeCut, self))
end

function JobLumberjack:start(player)
	giveWeapon(player, 9, 1, true)
end

function JobLumberjack:stop(player)
	takeWeapon(player, 9)
end

function JobLumberjack:loadUpHit(hitElement, matchingDimension)
	if getElementType(hitElement) == "player" and matchingDimension then
		if hitElement:getJob() ~= self then
			hitElement:sendMessage(_("You have to be a lumberjack to perform this action", hitElement), 255, 0, 0)
			return
		end
		
		local vehicle = getPedOccupiedVehicle(hitElement)
		if not vehicle or getElementModel(vehicle) ~= 455 then
			hitElement:sendMessage(_("Please enter a Flatbed", hitElement), 255, 0, 0)
			return
		end
		
		for k, v in ipairs(getAttachedElements(vehicle)) do
			destroyElement(v)
		end
		
		for i = 1, 4 do
			for j = 1, 6 do
				local x, y, z = getElementPosition(vehicle)
				local object = createObject(837, x, y, z)
				attachElements(object, vehicle, -1 + j * 0.3, -1.5, i * 0.2, 0, 0, 90)
			end
		end
		
		hitElement:triggerEvent("lumberjackTreesLoadUp", root)
	end
end

function JobLumberjack:dumpHit(hitElement, matchingDimension)
	if getElementType(hitElement) == "player" and matchingDimension then
		local vehicle = getPedOccupiedVehicle(hitElement)
		if not vehicle or getElementModel(vehicle) ~= 455 then
			hitElement:sendMessage(_("Please enter a Flatbed", hitElement))
			return
		end
	
		local numTrees = hitElement:getData("lumberjack:Trees")
		if not numTrees or numTrees == 0 then
			hitElement:sendMessage(_("Please saw and load up some trees first", hitElement), 255, 0, 0)
			return
		end
		
		givePlayerMoney(hitElement, numTrees * 50)
		
		for k, v in ipairs(getAttachedElements(vehicle)) do
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
