-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Jobs/JobTreasureSeeker.lua
-- *  PURPOSE:     JobTreasureSeeker job
-- *
-- ****************************************************************************
JobTreasureSeeker = inherit(Job)

function JobTreasureSeeker:constructor()
	Job.constructor(self)
	local availableVehicles = {"Reefer"}
	self.m_VehicleSpawner = VehicleSpawner:new(715.41, -1706.50, 1.3, availableVehicles, 135, bind(Job.requireVehicle, self))
	self.m_VehicleSpawner:setSpawnPosition(Vector3(719.79, -1705.18, -0.34), 180)
	self.m_VehicleSpawner:disable()
	self.m_VehicleSpawner.m_Hook:register(bind(self.onVehicleSpawn,self))
	self.m_KeyBind = bind(self.takeUp, self)

	self.m_Treasures = {}
	self.m_Vehicles = {}

	self.m_DeliverMarker = createMarker(725.30, -1692.62, -1, "cylinder", 7, 0, 0, 255, 200)
	addEventHandler("onMarkerHit", self.m_DeliverMarker, bind(self.onDeliveryHit, self))
	setElementVisibleTo(self.m_DeliverMarker, root, false)

	self.m_TreasureTypes = {
		[1208] = {["Name"] = " Waschmaschine", ["Min"] = 100, ["Max"] = 200},
		[2912] = {["Name"] = " Holzkiste", ["Min"] = 400, ["Max"] = 800},
		[1291] = {["Name"] = "n Briefkasten", ["Min"] = 200, ["Max"] = 400},
		[2040] = {["Name"] = " wertvolle Kiste", ["Min"] =1200, ["Max"] = 2000, ["Scale"] = 5.5},
		[2972] = {["Name"] = "n Fracht-Container", ["Min"] = 400, ["Max"] = 800},
		[3015] = {["Name"] = " Waffen Kiste", ["Min"] = 400, ["Max"] = 800, ["Scale"] = 2}
	}
end

function JobTreasureSeeker:start(player)
	self:generateRandomTreasures(player)
	bindKey(player, "space", "down", self.m_KeyBind)
	setElementVisibleTo(self.m_DeliverMarker, player, true)
	self.m_VehicleSpawner:toggleForPlayer(player, true)
end

function JobTreasureSeeker:checkRequirements(player)
	if not (player:getJobLevel() >= JOB_LEVEL_TREASURESEEKER) then
		player:sendError(_("Für diesen Job benötigst du mindestens Joblevel %d", player, JOB_LEVEL_TREASURESEEKER), 255, 0, 0)
		return false
	end
	return true
end

function JobTreasureSeeker:stop(player)
	self:destroyJobVehicle(player)
	self:removeTreasures(player)
	unbindKey(player, "space", "down", self.m_KeyBind)
	setElementVisibleTo(self.m_DeliverMarker, player, false)
	self.m_VehicleSpawner:toggleForPlayer(player, false)
end

function JobTreasureSeeker:onVehicleSpawn(player, vehicleModel, vehicle)
	setVehicleHandling(vehicle, "steeringLock", 70)

	vehicle.Engine = createObject(3013, 0, 0, 0)
	vehicle.Engine:setScale(1.5)
	vehicle.Engine:attach(vehicle, 0, -6.2, 3.5)

	vehicle.Magnet = createObject(1301, 0, 0, 0)
	vehicle.Magnet:setScale(0.5)
	vehicle.Magnet:attach(vehicle, 0, -6.2, 2)

	self:registerJobVehicle(player, vehicle, true, true)

	triggerClientEvent(root, "jobTreasureDrawRope", root, vehicle.Engine, vehicle.Magnet)
end

function JobTreasureSeeker:onDeliveryHit(hitElement, dim)
	if dim and hitElement:getType() == "player" then
		if hitElement:getJob() == self then
			if hitElement:getOccupiedVehicle() and hitElement:getOccupiedVehicle() == hitElement.jobVehicle then
				local veh = hitElement:getOccupiedVehicle()
				if veh.Magnet and isElement(veh.Magnet) then
					if veh.Magnet.Object and isElement(veh.Magnet.Object) then
						local model = veh.Magnet.Object:getModel()
						if not self.m_TreasureTypes[model] then return end
						local loan = math.random(self.m_TreasureTypes[model]["Min"], self.m_TreasureTypes[model]["Max"])
						local bonus = JobManager.getBonusForNewbies( hitElement, loan)
						if not bonus then bonus = 0 end
						hitElement:giveMoney(loan+bonus, "Schatzsucher-Job") --// default loan not loan*2
						hitElement:sendShortMessage(_("Du hast eine%s für %d$ verkauft!", hitElement, self.m_TreasureTypes[model]["Name"], loan))
						hitElement:getOccupiedVehicle().Magnet.Object:destroy()
						hitElement:givePoints(math.floor(5*JOB_EXTRA_POINT_FACTOR))

						self:loadTreasure(hitElement)
					else
						hitElement:sendError(_("Du hast kein Objekt dabei!", hitElement))
					end
				else
					hitElement:sendError(_("Du benutzt ein falsches Boot!", hitElement))
				end
			else
				hitElement:sendError(_("Du bist im falschen Fahrzeug!", hitElement))
			end
		end
	end
end

function JobTreasureSeeker:generateRandomTreasures(player)
	if not self.m_Treasures[player] then
		self.m_Treasures[player] = {}
	end

	for i = 1, 5 do
		self:loadTreasure(player)
	end
end

function JobTreasureSeeker:takeUp(player, key, keyState)
	if player:getOccupiedVehicle() and player:getOccupiedVehicle() == player.jobVehicle then
		for index, col in pairs(self.m_Treasures[player]) do
			if col and isElement(col) and player:isWithinColShape(col) then
				local veh = player:getOccupiedVehicle()
				if veh.Magnet and veh.Magnet.Object and isElement(veh.Magnet.Object) then
					player:sendError(_("Du hast bereits ein Objekt am Schiff!\nLade es erst am Startpunkt ab!", player))
					return
				end
				player:sendShortMessage(_("Das gefundene Objekt wird angehoben! Bitte warten!", player))
				local objectModel = self:getRandomTreasureModel()
				veh:setFrozen(true)
				veh.Magnet:detach(veh)

				local matrix = veh.matrix
				local newPos = matrix:transformPosition(Vector3(0, -6.2, 2))
				veh.Magnet:setPosition(newPos)
				veh.Magnet:move(15000, newPos.x, newPos.y, newPos.z-15)

				veh.Magnet.Object = createObject(objectModel, newPos.x, newPos.y, newPos.z-100)
				if self.m_TreasureTypes[objectModel]["Scale"] then veh.Magnet.Object:setScale(self.m_TreasureTypes[objectModel]["Scale"]) end

				setTimer(function()
					x, y, z = getElementPosition(veh.Magnet)
					veh.Magnet.Object:attach(veh.Magnet, 0, 0, -0.9)
					veh.Magnet:move(15000, x, y, z+15)
				end, 15000, 1)

				setTimer(function()
					veh.Magnet:attach(veh, 0, -6.2, 2)
					player:sendShortMessage(_("Glückwunsch du hast eine%s gefunden!\nBringe das Fundstück zum Startpunkt!", player, self.m_TreasureTypes[objectModel]["Name"]), _("Schatzsucher-Job", player))
					veh:setFrozen(false)
				end, 30000, 1)

				if col.DummyObject and isElement(col.DummyObject) then col.DummyObject:destroy() end
				if isElement(col) then col:destroy() end
				table.remove(self.m_Treasures[player], index)
				return
			end
		end
		player:sendError(_("Hier ist kein Objekt!", player))
	end
end

function JobTreasureSeeker:loadTreasure(player)
	local x, y = math.random(JobTreasureSeeker.Positions[1][1], JobTreasureSeeker.Positions[2][1]), math.random(JobTreasureSeeker.Positions[1][2], JobTreasureSeeker.Positions[2][2])

	local colShape = createColCircle(x, y, 25)
	colShape.DummyObject = createObject(1337, x, y, -20)
	colShape.Player = player

	table.insert(self.m_Treasures[player], colShape)
	setElementData(colShape.DummyObject, "Treasure", player)
	addEventHandler("onColShapeHit", colShape, bind(self.onTreasureHit, self))
end

function JobTreasureSeeker:getRandomTreasureModel()
	local models = {}
	for modelId, key in pairs(self.m_TreasureTypes) do
		table.insert(models, modelId)
	end
	return models[math.random(1, #models)]
end

function JobTreasureSeeker:removeTreasures(player)
	if not self.m_Treasures[player] then return end
	for i, col in ipairs(self.m_Treasures[player]) do
		if col.DummyObject and isElement(col.DummyObject) then col.DummyObject:destroy() end
		if isElement(col) then col:destroy() end
	end

	self.m_Treasures[player] = nil
end

function JobTreasureSeeker:onTreasureHit(hitElement, dim)
	if dim and hitElement == source.Player then
		if hitElement:getOccupiedVehicle() and hitElement:getOccupiedVehicle() == hitElement.jobVehicle then
			hitElement:sendInfo(_("Der Radar registriert ein Objekt unter dir!\nDrücke Leertaste um es hochzuheben!", hitElement))
		end
	end
end

JobTreasureSeeker.Positions = {
	{450, -2552},
	{877, -2111},
}
