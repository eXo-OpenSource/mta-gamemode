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
	[1768] = {seats = 3, offsetPosition = Vector3(.3, -.6), seatMultiplier = Vector3(.7)},
	[1766] = {seats = 3, offsetPosition = Vector3(.3, -.6), seatMultiplier = Vector3(.7)},
	[1764] = {seats = 2, offsetPosition = Vector3(.6, -.6), seatMultiplier = Vector3(.9)},
	[1763] = {seats = 2, offsetPosition = Vector3(.2, -.5), seatMultiplier = Vector3(.9)},
	[1761] = {seats = 2, offsetPosition = Vector3(.3, -.7), seatMultiplier = Vector3(.7)},
	[1760] = {seats = 3, offsetPosition = Vector3(.2, -.6), seatMultiplier = Vector3(.8)},
	[1757] = {seats = 3, offsetPosition = Vector3(.4, -.6), seatMultiplier = Vector3(.7)},
	[1756] = {seats = 2, offsetPosition = Vector3(.4, -.6), seatMultiplier = Vector3(1.1)},
	[1753] = {seats = 3, offsetPosition = Vector3(.3, -.7), seatMultiplier = Vector3(.8)},
	[1713] = {seats = 2, offsetPosition = Vector3(.3, -.7)},
	[1712] = {seats = 2, offsetPosition = Vector3(.2, -.7), seatMultiplier = Vector3(1.1)},
	[1710] = {seats = 4, offsetPosition = Vector3(.2, -.7), seatMultiplier = Vector3(1.1)},
	[1706] = {seats = 2, offsetPosition = Vector3(0, -.6)},
	[1703] = {seats = 2, offsetPosition = Vector3(.6, -.6), seatMultiplier = Vector3(.8)},
	[1702] = {seats = 2, offsetPosition = Vector3(.6, -.6), seatMultiplier = Vector3(.8)},
	[1811] = {seats = 1, offsetPosition = Vector3(-.5), rotationOffset = 90},
	[2310] = {seats = 1, offsetPosition = Vector3(-.5), rotationOffset = 90},
	[2636] = {seats = 1, offsetPosition = Vector3(-.5), rotationOffset = 90},
	[2356] = {seats = 1, offsetPosition = Vector3(-.1, .7, .1), rotationOffset = 0},
	[1721] = {seats = 1, offsetPosition = Vector3(0, .7, .1), rotationOffset = 0},
	[2309] = {seats = 1, offsetPosition = Vector3(-0.05, .7, .1), rotationOffset = 0},
	[1704] = {seats = 1, offsetPosition = Vector3(0.5, -0.6, .2), rotationOffset = 180},
	[1714] = {seats = 1, offsetPosition = Vector3(0, -0.6, .2), rotationOffset = 180},
	[1257] = {seats = 2, offsetPosition = Vector3(0, -0.2, -0.6), rotationOffset = 90, seatMultiplier = Vector3(0, -1.1, 0)},
	[1722] = {seats = 1, offsetPosition = Vector3(0, 0.8, -0.2), rotationOffset = 0},
	[1280] = {seats = 1, offsetPosition = Vector3(-.5), rotationOffset = 90},
	[1806] = {seats = 1, offsetPosition = Vector3(0, .6, .1), rotationOffset = 0},
	[1663] = {seats = 1, offsetPosition = Vector3(0, -.5, .1), rotationOffset = 180},
	[1671] = {seats = 1, offsetPosition = Vector3(0, -.5), rotationOffset = 180},
	[2291] = {seats = 1, offsetPosition = Vector3(.6, -.6), rotationOffset = 180},
	[1727] = {seats = 1, offsetPosition = Vector3(.5, -.6), rotationOffset = 180},
}

function Chair:constructor()
	self.m_Chairs = {}

	addEventHandler("onPlayerChairSitDown", root, bind(Chair.trySitDown, self))
end

function Chair:removePlayer(objectId, player)
	for i, sittingPlayer in pairs(self.m_Chairs[objectId]) do
		if sittingPlayer == player then
			self.m_Chairs[objectId][i] = nil
			return
		end
	end
end

function Chair:addPlayer(object, objectId, player)
	local seats = Chair.Map[object].seats

	if not self.m_Chairs[objectId] then
		self.m_Chairs[objectId] = {}
	end

	for i = 1, seats do
		if not self.m_Chairs[objectId][i] then
			self.m_Chairs[objectId][i] = player
			return i
		elseif not isElement(self.m_Chairs[objectId][i]) then
			self.m_Chairs[objectId][i] = player
			return i
		end
	end

	return false
end

function Chair:trySitDown(object, position, rotation)
	if client.sittingOn then
		self:removePlayer(client.sittingOn, client)
		client.sittingOn = nil
		client:setAnimation("PED", "SEAT_up", -1, false, false, false, false)
		client:setFrozen(false)
		return
	end

	if not object then return end
	if isElement(object) then
		object = object:getModel()
	end

	position = Vector3(unpack(position))
	rotation = Vector3(unpack(rotation))

	if Chair.Map[object] then
		local objectId = object + position.length	-- unique id cause we interact with MTA elements and gta world objects
		local seat = self:addPlayer(object, objectId, client)
		if seat then
			client.sittingOn = objectId
			self:sitDown(client, object, position, rotation, seat)
		end
	end
end

function Chair:sitDown(player, object, position, rotation, seat)
    player:setRotation(0, 0, rotation.z + (Chair.Map[object].rotationOffset or 180))
    nextframe(function()
        player:setPosition(self:getPosition(object, position, rotation, seat))
        player:setFrozen(true)
        player:setAnimation("PED", "SEAT_down", -1, false, false, false, true)
    end)
end

function Chair:getPosition(object, position, rotation, seat)
	local chair = Chair.Map[object]
	local position = Matrix(position, rotation):transformPosition((chair.offsetPosition or Vector3()) + (chair.seatMultiplier or Vector3(1))*(seat-1))
	position.z = position.z + .5

	return position
end
