-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/StaticWorldItems.lua
-- *  PURPOSE:     StaticWorldItems class
-- *
-- ****************************************************************************
StaticWorldItems = inherit(Singleton)

function StaticWorldItems:constructor()
	self.m_Objects = {}

	self.m_Items = {
		["Mushroom"]= {
			["class"] = nil,-- ItemManager:getSingleton():getInstance("Shrooms"),
			["offsetZ"] = -1,
			["chance"] = 33,
			["enabled"] = true
					  },
		["Osterei"] = {
			["class"] = nil,-- ItemManager:getSingleton():getInstance("Osterei"),
			["offsetZ"] = -0.85,
			["chance"] = 33,
			["enabled"] = EVENT_EASTER
					  },
		["Kürbis"] = {
			["class"] = nil,-- ItemManager:getSingleton():getInstance("Kürbis"),
			["offsetZ"] = -0.85,
			["chance"] = 33,
			["enabled"] = EVENT_HALLOWEEN
		},
	}

	-- self.m_TimedPulse = TimedPulse:new(1000*60*60)
	-- self.m_TimedPulse:registerHandler(bind(self.reload, self))
    -- self:reload(true)

	addCommandHandler("addWorldObject", bind(self.addPosition, self))
	addCommandHandler("remWorldObject", bind(self.removePosition, self))
end

function StaticWorldItems:destructor()
	for id, object in pairs(self.m_Objects) do
		if isElement(object) then
			object:destroy()
			self.m_Objects[id] = nil
		else
			self.m_Objects[id] = nil
		end
	end
end

function StaticWorldItems:addPosition(player, cmd, type, dontSave)
	if player:getRank() < RANK.Moderator then
		player:sendError(_("Du bist nicht berechtigt!", player))
		return
	end
    if not type or not self.m_Items[type] then
		local allowed = ""
		for index, class in pairs(self.m_Items) do
			allowed = index..allowed..", "
		end
		player:sendError(_("Ungültiger Typ! (%s)", player, allowed))
		return
	end

	if not player:getOccupiedVehicle() then
        local pos = player:getPosition()
		pos.z = pos.z + self.m_Items[type]["offsetZ"]
		local rot = player:getRotation()
		self.m_Items[type]["class"]:addObject(sql:lastInsertId(), pos, rot+Vector3(0, 0, 180), player:getInterior(), player:getDimension()) 
		player:sendInfo(_("%s hinzugefügt!", player, type))

		if dontSave then return end
		sql:queryExec("INSERT INTO ??_word_objects(Typ, PosX, PosY, PosZ, RotationZ, Interior, Dimension, ZoneName, Admin, Date) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, NOW());", sql:getPrefix(), type, pos.x, pos.y, pos.z, rot.z, player:getInterior(), player:getDimension(), getZoneName(pos).."/"..getZoneName(pos, true), player:getId())
    else
        player:sendError(_("Du darfst in keinem Fahrzeug sitzen!", player))
    end
end


function StaticWorldItems:removePosition(player)
    if player:getRank() < RANK.Moderator then
		player:sendError(_("Du bist nicht berechtigt!", player))
		return
	end
	if not player:getOccupiedVehicle() then

		local pos = player:getPosition()
        pos.z = pos.z-1
		local tempCol = createColSphere(pos, 5)
		for index, element in pairs(getElementsWithinColShape(tempCol, "object")) do
			if element.Id then
				player:sendInfo(_("%s entfernt!", player, element.Type))
				sql:queryExec("DELETE FROM ??_word_objects WHERE Id = ?;", sql:getPrefix(), element.Id)
				self.m_Objects[element.Id] = nil
				element:destroy()
			else
				player:sendError(_("Osterei nicht gefunden!", player))
			end
		end
    else
        player:sendError(_("Du darfst in keinem Fahrzeug sitzen!", player))
    end
end

function StaticWorldItems:reload(firstLoad)
	for id, object in pairs(self.m_Objects) do
		if isElement(object) then
			if not object.m_NotReload then
				object:destroy()
				self.m_Objects[id] = nil
			end
		else
			self.m_Objects[id] = nil
		end
	end
	self.m_Objects = {}

   	local result
	for typ, data in pairs(self.m_Items) do
		if data["enabled"] == true and ( firstLoad or not data["notReload"] ) then
			local st, count = getTickCount(), 0
			result = sql:queryFetch("SELECT * FROM ??_word_objects WHERE Typ = ?;", sql:getPrefix(), typ)
			for i, row in pairs(result) do
				if row.Typ and self.m_Items[row.Typ] then
					if DEBUG or chance(data["chance"]) then
						self.m_Objects[row.Id] = self.m_Items[row.Typ]["class"]:addObject(row.Id, Vector3(row.PosX, row.PosY, row.PosZ), Vector3(0, 0, row.RotationZ), tonumber(row.Interior) or 0 , tonumber(row.Dimension) or 0, row.Value)
						count = count+1
					end
				else
					outputDebugString("Unknown Type ("..row.Typ..") for Static World Item ID: "..row.Id)
				end
			end
			if DEBUG_LOAD_SAVE then outputServerLog(("Created %s %s-StaticWorldItems in %sms"):format(count, typ, getTickCount()-st)) end
		end
	end
end
