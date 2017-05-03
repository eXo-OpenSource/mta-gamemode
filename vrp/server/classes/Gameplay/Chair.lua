-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        TODO
-- *  PURPOSE:     TODO
-- *
-- ****************************************************************************
Chair = inherit(Singleton)
addRemoteEvents{"onPlayerChairSitDown"}

Chair.Map = {
	[2290] = {seats = 3, offsetPosition = Vector3(.3, -.7), seatMultiplier = Vector3(.8)},
	[1768] = {},
	[1766] = {},
	[1764] = {},
	[1763] = {},
	[1761] = {},
	[1760] = {},
	[1757] = {},
	[1757] = {},
	[1756] = {seats = 2, offsetPosition = Vector3(.4, -.6), seatMultiplier = Vector3(1.1)},
	[1753] = {seats = 3, offsetPosition = Vector3(.3, -.7), seatMultiplier = Vector3(.8)},
	[1713] = {seats = 2, offsetPosition = Vector3(.3, -.7)},
	[1712] = {seats = 2, offsetPosition = Vector3(.2, -.7), seatMultiplier = Vector3(1.1)},
	[1710] =  {seats = 4, offsetPosition = Vector3(.2, -.7), seatMultiplier = Vector3(1.1)},
	[1706] = {seats = 2, offsetPosition = Vector3(0, -.6)},
	[1703] = {seats = 2, offsetPosition = Vector3(.6, -.6), seatMultiplier = Vector3(.8)},
	[1702] = {seats = 2, offsetPosition = Vector3(.6, -.6), seatMultiplier = Vector3(.8)},
}

function Chair:constructor()
	addEventHandler("onPlayerChairSitDown", root, bind(Chair.trySitDown, self))

	if DEBUG then
		createObject(1702, 1517.51, -1660.52, 12.53)
	end

	self.m_Chairs = {}
end

function Chair:removePlayer(object, player)
	for i, sittingPlayer in pairs(self.m_Chairs[object]) do
		if sittingPlayer == player then
			self.m_Chairs[object][i] = nil
			return
		end
	end
end

function Chair:addPlayer(object, player)
	local seats = Chair.Map[object:getModel()].seats

	if not self.m_Chairs[object] then
		self.m_Chairs[object] = {}
	end

	for i = 1, seats do
		if not self.m_Chairs[object][i] then
			self.m_Chairs[object][i] = player
			return i
		elseif not isElement(self.m_Chairs[object][i]) then
			return i
		end
	end

	return false
end

function Chair:trySitDown()
	if client.sittingOn then
		self:removePlayer(client.sittingOn, client)
		client.sittingOn = nil
		client:setAnimation("PED", "SEAT_up", -1, false, false, false, false)
		client:setFrozen(false)
		return
	end

	local colShape = createColSphere(client.matrix:transformPosition(0, 1, -.5), 1.5)
	colShape:setInterior(client.interior)
	colShape:setDimension(client.dimension)
	local objects = getElementsWithinColShape(colShape, "object")
	colShape:destroy()

	if #objects > 0 then
		for _, v in pairs(objects) do
			if Chair.Map[v:getModel()] then
				local seat = self:addPlayer(v, client)
				if not seat then client:sendError("Kein Sitzplatz frei!") return end

				client.sittingOn = v
				self:sitDown(client, v, seat)
			end
		end
	end
end

function Chair:sitDown(player, object, seat)
	player:setFrozen(true)
	player:setPosition(self:getPosition(object, seat))
	player:setRotation(0, 0, object.rotation.z + 180)
	player:setAnimation("PED", "SEAT_down", -1, false, false, false, true)
end

function Chair:getPosition(object, seat)
	local chair = Chair.Map[object:getModel()]
	local position = object.matrix:transformPosition((chair.offsetPosition or Vector3()) + (chair.seatMultiplier or Vector3(1))*(seat-1))
	position.z = position.z + .5

	return position
end
