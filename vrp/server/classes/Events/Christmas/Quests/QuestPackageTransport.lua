QuestPackageTransport = inherit(Quest)

QuestPackageTransport.Targets = {
	[6] = Vector3(626.15, -601.29, 16),
	--[6] = Vector3(1481.21, -1753.55, 13.55),


}

function QuestPackageTransport:constructor(id)
	Quest.constructor(self, id)
	self.m_Boxes = {}
	self.m_Vehicles = {}
	self.m_Trailers = {}

	self.m_Target = QuestPackageTransport.Targets[id]
	self.m_Marker = createMarker(self.m_Target, "cylinder", 3, 255, 0, 0)
	self.m_Marker:setVisibleTo(root, false)

	self.m_Blips = {}

	self.m_DetachBind = bind(self.detach, self)
	self.m_ExitBind = bind(self.exit, self)
	addEventHandler("onTrailerDetach", getRootElement(), self.m_DetachBind)
	addEventHandler("onPlayerVehicleExit", getRootElement(), self.m_ExitBind)

	addEventHandler("onMarkerHit", self.m_Marker, bind(self.onMarkerHit, self))

end

function QuestPackageTransport:destructor(id)
	Quest.destructor(self)

	removeEventHandler("onPlayerVehicleExit", getRootElement(), self.m_ExitBind)
	removeEventHandler("onTrailerDetach", getRootElement(), self.m_DetachBind)
end

function QuestPackageTransport:addPlayer(player)
	Quest.addPlayer(self, player)
	self.m_Vehicles[player] = TemporaryVehicle.create(485, 1488.35, -1722, 13.20, 270)
	self.m_Vehicles[player].owner = player
	self.m_Vehicles[player].christmas = true
	self.m_Trailers[player] = TemporaryVehicle.create(607, 1480.57, -1722, 13.20, 270)
	self.m_Trailers[player]:setVariant(255, 255)
	self.m_Boxes[player] = {}
	setTimer(function()
		player:warpIntoVehicle(self.m_Vehicles[player])
		self.m_Vehicles[player]:attachTrailer(self.m_Trailers[player])
		for i=1, 3 do
			self.m_Boxes[player][i] = createObject(3878, 1484.88, -1721.95, 14.60)
			self.m_Boxes[player][i]:setScale(0.4)
			self.m_Boxes[player][i]:setCollisionsEnabled(false)
			self.m_Boxes[player][i]:attach(self.m_Trailers[player], 0 ,-2+i, 0)
		end
	end, 500, 1)

	if self.m_Blips[player] then delete(self.m_Blips[player]) end
	self.m_Blips[player] = Blip:new("Marker.png", self.m_Target.x, self.m_Target.y, player, 6000, {255, 0, 0})
	self.m_Marker:setVisibleTo(player, true)
end

function QuestPackageTransport:removePlayer(player)
	Quest.removePlayer(self, player)
	if isElement(self.m_Vehicles[player]) then self.m_Vehicles[player]:destroy() end
	if isElement(self.m_Trailers[player]) then self.m_Trailers[player]:destroy() end
	for i, package in pairs(self.m_Boxes[player]) do
		if isElement(package) then package:destroy() end
	end

	if self.m_Blips[player] then delete(self.m_Blips[player]) end
	self.m_Marker:setVisibleTo(player, false)
end

function QuestPackageTransport:detach(vehicle)
	if vehicle.christmas and vehicle.owner and isElement(vehicle.owner) then
		local player = vehicle.owner
		player:sendError("Du hast die Päckchen verloren! Der Quest wurde beendet!")
		self:removePlayer(player)
	end
end

function QuestPackageTransport:exit(vehicle)
	if vehicle.christmas and vehicle.owner and isElement(vehicle.owner) then
		local player = vehicle.owner
		player:sendError("Du bist ausgestiegen! Der Quest wurde beendet!")
		self:removePlayer(player)
	end
end

function QuestPackageTransport:onMarkerHit(player, dim)
	if player:getType() == "player" and dim then
		if table.find(self:getPlayers(), player) then
			if player.vehicle and self.m_Trailers[player] and player.vehicle.christmas and player.vehicle:getTowedByVehicle() == self.m_Trailers[player] then
				player:sendSuccess("Du hast die Päckchen erfolgreich abgeliefert!")
				self:success(player)
			else
				player:sendError("Du hast den Anhänger nicht mehr dabei!")
			end
		end
	end
end
