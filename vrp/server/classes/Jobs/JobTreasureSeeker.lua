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
	self.m_VehicleSpawner = VehicleSpawner:new(715.41, -1706.50, 1.8, availableVehicles, 135, bind(Job.requireVehicle, self))
	self.m_VehicleSpawner:setSpawnPosition(Vector3(719.79, -1705.18, -0.34), 180)
	self.m_VehicleSpawner.m_Hook:register(bind(self.onVehicleSpawn,self))
	self.m_KeyBind = bind(self.takeUp, self)

	self.m_Treasures = {}

	self.m_TreasureTypes = {
		[1208] = {["Name"] = "Waschmaschine", ["Min"] = 50, ["Max"] = 100},
		[2912] = {["Name"] = "Holzkiste", ["Min"] = 200, ["Max"] = 400},
		[1291] = {["Name"] = "Briefkasten", ["Min"] = 100, ["Max"] = 200},
		[2040] = {["Name"] = "wertvolle Kiste", ["Min"] = 400, ["Max"] = 600},
		[2972] = {["Name"] = "Fracht Container", ["Min"] = 200, ["Max"] = 400},
		[3015] = {["Name"] = "Waffen Kiste", ["Min"] = 200, ["Max"] = 400}
	}
end

function JobTreasureSeeker:start(player)

	self:generateRandomTreasures(player)
	bindKey(player, "space", "down", self.m_KeyBind)
end

function JobTreasureSeeker:stop(player)
	self:removeTreasures()
	unbindKey(player, "space", "down", self.m_KeyBind)
end

function JobTreasureSeeker:onVehicleSpawn(player, vehicleModel, vehicle)
	vehicle.Engine = createObject(3013, 0, 0, 0)
	vehicle.Engine:setScale(1.5)
	vehicle.Engine:attach(vehicle, 0, -6.2, 3.5)

	vehicle.Magnet = createObject(1301, 0, 0, 0)
	vehicle.Magnet:setScale(0.5)
	vehicle.Magnet:attach(vehicle, 0, -6.2, 2)

	triggerClientEvent(root, "jobTreasureDrawRope", root, vehicle.Engine, vehicle.Magnet)
end

function JobTreasureSeeker:generateRandomTreasures(player)
	if self.m_Treasures[player] then
		self:removeTreasures(player)
	else
		self.m_Treasures[player] = {}
	end
	local rnd
	for i=1, 5 do
		self:loadTreasure(player)
	end
end

function JobTreasureSeeker:takeUp(player, key, keyState)
	if player:getOccupiedVehicle() and player:getOccupiedVehicle():getModel() == 453 then
		for index, col in pairs(self.m_Treasures[player]) do
			if player:isWithinColShape(col) then
				player:sendInfo(_("Das gefundene Objekt wird angehoben!", player))
				local veh = player:getOccupiedVehicle()
				veh:setFrozen(true)
				veh.Magnet:detach(veh)
				local x, y, z = getElementPosition(veh.Magnet)

				veh.Magnet:move(15000, x, y, z-15)

				setTimer(function()
					x, y, z = getElementPosition(veh.Magnet)
					veh.Magnet.Object = createObject(1208, 0, 0, 0)
					veh.Magnet.Object:attach(veh.Magnet, 0, 0, -0.9)
					veh.Magnet:move(15000, x, y, z+15)
				end, 15000, 1)

				setTimer(function()
					veh.Magnet:attach(veh, 0, -6.2, 2)
					player:sendInfo(_("Glückwunsch du hast eine Waschmaschine gefunden!", player))
					veh:setFrozen(false)
				end, 30000, 1)
				return
			end
		end
	end
	player:sendError(_("Hier ist kein Objekt!", player))
end

function JobTreasureSeeker:loadTreasure(player)
	local rnd = math.random(1, #JobTreasureSeeker.Positions)
	if self.m_Treasures[player][rnd] then
		self:loadTreasure(player)
	else
		local x, y = unpack(JobTreasureSeeker.Positions[rnd])
		Blip:new("Waypoint.png", x, y) -- Dev
		self.m_Treasures[player][rnd] = createColCircle(x, y, 12)
		self.m_Treasures[player][rnd].DummyObject = createObject(1337, x, y, -200)
		self.m_Treasures[player][rnd].Player = player
		setElementData(self.m_Treasures[player][rnd].DummyObject, "Treasure", true)
		addEventHandler("onColShapeHit", self.m_Treasures[player][rnd], bind(self.onTreasureHit, self))
	end
end

function JobTreasureSeeker:removeTreasures(player)
	if not self.m_Treasures[player] then return end
	for index, col in pairs(self.m_Treasures[player]) do
		if col.DummyObject and isElement(col.DummyObject) then col.DummyObject:destroy() end
		col:destroy()
		table.remove(self.m_Treasures, index)
	end
end

function JobTreasureSeeker:onTreasureHit(hitElement, dim)
	if dim and hitElement == source.Player then
		hitElement:sendInfo(_("Du bist über einen Schatz! Drücke Leertaste um ihn hochzuheben!", hitElement))
	end
end

JobTreasureSeeker.Positions = {
{704.25, -2086.15},
{755.26, -2154.51},
{749.63, -2241.94},
{744.62, -2387.58},
{774.53, -2578.14},
{591.42, -2620.96},
{452.14, -2563.62},
{459.06, -2429.85},
{779.61, -2429.75},
{828.55, -2652.89},
{817.14, -2764.52},
{839.84, -2874.39},
{924.68, -2970.34},
{480.00, -2176.58},
{381.62, -2208.21},
{271.31, -2292.53},
{316.23, -2436.88},
{440.58, -2503.98},
{631.95, -2421.31},
{753.67, -2532.05},
{785.35, -2634.72},
{788.39, -2758.76},
{836.83, -2857.83}
}
