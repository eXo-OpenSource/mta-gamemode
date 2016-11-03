-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/GroupProperty.lua
-- *  PURPOSE:     Group Property class
-- *
-- ****************************************************************************
GroupProperty = inherit(Object)

function GroupProperty:constructor(Id, Name, OwnerId, Type, Price, Pickup, InteriorId, InteriorSpawn, Cam, Open)

	self.m_Id = Id
	self.m_Name = Name
	self.m_Price = Price
	self.m_Owner = GroupManager.getFromId(OwnerId) or false
	self.m_Open = Open
	self.m_Position = Position
	self.m_Interior = Interior
	self.m_InteriorPosition = InteriorPosition
	self.m_Dimension = Id+1000
	self.m_CamMatrix = Cam

	self.m_Pickup = createPickup(Pickup, 3, 1272, 0)
	addCommandHandler("enter",
		function(player)
			self:openForPlayer(player)
		end
	)

	self.m_ExitMarker = createMarker(InteriorSpawn, "corona", 2, 255, 255, 255, 200)
	self.m_ExitMarker:setInterior(InteriorId)
	self.m_ExitMarker:setDimension(self.m_Dimension)
	addEventHandler("onMarkerHit", self.m_ExitMarker,
		function(hitElement, matchingDimension)
			if matchingDimension then
				self:closeForPlayer(hitElement)
			end
		end
	)
end

function GroupProperty:destructor()
	if isElement(self.m_Pickup) then
		self.m_Pickup:destroy()
	end
end

function GroupProperty:openForPlayer(player)
	if getElementType(player) == "player" then
		player:setInterior(self.m_Interior, self.m_InteriorPosition.x, self.m_InteriorPosition.y, self.m_InteriorPosition.z)
		player:setDimension(self.m_Dimension)
		player:setRotation(0, 0, 0)
		player:setCameraTarget(player)
	end
end

function GroupProperty:closeForPlayer(player)
	if getElementType(player) == "player" then
		player:setInterior(0, self.m_Position.x, self.m_Position.y, self.m_Position.z)
		player:setDimension(0)
		player:setRotation(0, 0, 0)
		player:setCameraTarget(player)
	end
end

-- Short setters

-- Short getters
function GroupProperty:getId() return self.m_Id end
function GroupProperty:getName() return self.m_Name end
function GroupProperty:getPrice() return self.m_Price end
function GroupProperty:hasOwner() return self.m_Owner ~= false end
function GroupProperty:getOwner() return self:hasOwner() and self.m_Owner or false end


