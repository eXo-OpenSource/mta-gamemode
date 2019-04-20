-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/NonCollisionArea.lua
-- *  PURPOSE:     Clientside area where vehicles don't collide with other elements
-- *
-- ****************************************************************************
NonCollisionArea = inherit(Object)

NonCollisionArea.Areas = {
	["Cuboid"] = createColCuboid,
	["Sphere"] = createColSphere,
}

NonCollisionArea.DefaultOptions = {
	ignoreDimension = false,
	vehicles = true,
	players = false
}

function NonCollisionArea:constructor(colType, args, options)
	-- Create colshape
	if type(colType) == "string" then
		if not NonCollisionArea.Areas[colType] then outputDebug("NonCollisionArea: Invalid colType string") return false end
		self.m_ColShape = NonCollisionArea.Areas[colType](unpack(args))
	elseif isElement(colType) and colType:getType() == "colshape" then
		self.m_ColShape = colType
	else
		outputDebug("NonCollisionArea: Invalid colType")
		return false
	end

	-- Define options
	options = self:getOptions(options)
	self.m_IgnoreDimension = options.ignoreDimension
	self.m_Vehicles = options.vehicles
	self.m_Players = options.players

	addEventHandler("onClientColShapeHit", self.m_ColShape,
		function(hitElement, matchingDimension)
			if hitElement:getType() == "vehicle" and (matchingDimension or self.m_IgnoreDimension) then
				hitElement:setAlpha(180)

				if self.m_Vehicles then
					for _, vehicle in pairs(getElementsByType("vehicle")) do
						hitElement:setCollidableWith(vehicle, false)
					end
				end

				if self.m_Players then
					for _, player in pairs(getElementsByType("player")) do
						hitElement:setCollidableWith(player, false)
					end
				end

				outputDebug("ignoreDim: " .. tostring(self.m_IgnoreDimension))
				outputDebug("vehicles: " .. tostring(self.m_Vehicles))
				outputDebug("players: " .. tostring(self.m_Players))
			end
		end
	)

	addEventHandler("onClientColShapeLeave", self.m_ColShape,
		function(hitElement, matchingDimension)
			if hitElement:getType() == "vehicle" and (matchingDimension or self.m_IgnoreDimension) then
				hitElement:setAlpha(255)

				if self.m_Vehicles then
					for _, vehicle in pairs(getElementsByType("vehicle")) do
						hitElement:setCollidableWith(vehicle, true)
					end
				end

				if self.m_Players then
					for _, player in pairs(getElementsByType("player")) do
						hitElement:setCollidableWith(player, true)
					end
				end
			end
		end
	)
end

function NonCollisionArea:destructor()
	self.m_ColShape:destroy()
end

function NonCollisionArea:getOptions(options)
	if not options then return NonCollisionArea.DefaultOptions end

	for key, value in pairs(NonCollisionArea.DefaultOptions) do
		if options[key] == nil then
			options[key] = value
		end
	end

	return options
end

function NonCollisionArea.load()
	for _, col in pairs(getElementsByType("colshape")) do
		local colData = col:getData("NonCollisionArea")
		if colData then
			NonCollisionArea:new(col, nil, type(colData) == "table" and colData or nil)
		end
	end
end
