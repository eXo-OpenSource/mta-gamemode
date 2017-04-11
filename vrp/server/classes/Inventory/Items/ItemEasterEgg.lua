-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/ItemEasteregg.lua
-- *  PURPOSE:     Eastereggs class
-- *
-- ****************************************************************************
ItemEasteregg = inherit(Item)

function ItemEasteregg:constructor()
    self.m_Model = 1933
	self.m_Eastereggs = {}

	self.m_TimedPulse = TimedPulse:new(60*60*1000)
	self.m_TimedPulse:registerHandler(bind(self.reload, self))
    self:reload()

    addCommandHandler("addEasteregg", bind(self.addPosition, self))
	addCommandHandler("removeEasteregg", bind(self.removePosition, self))
end

function ItemEasteregg:destructor()

end

function ItemEasteregg:use( player )

end

function ItemEasteregg:addPosition(player)
	if player:getRank() < RANK.Moderator then
		player:sendError(_("Du bist nicht berechtigt!", player))
		return
	end
    if not player:getOccupiedVehicle() then
        local pos = player:getPosition()
        pos.z = pos.z-1
		sql:queryExec("INSERT INTO ??_Eastereggs(PosX, PosY, PosZ) VALUES(?, ?, ?);", sql:getPrefix(), pos.x, pos.y, pos.z)
        self:addEasteregg(sql:lastInsertId(), pos)
        player:sendInfo(_("Osterei hinzugefügt!", player))
    else
        player:sendError(_("Du darfst in keinem Fahrzeug sitzen!", player))
    end
end

function ItemEasteregg:removePosition(player)
    if player:getRank() < RANK.Moderator then
		player:sendError(_("Du bist nicht berechtigt!", player))
		return
	end
	if not player:getOccupiedVehicle() then

		local pos = player:getPosition()
        pos.z = pos.z-1
		local tempCol = createColSphere(pos, 5)
		for index, element in pairs(getElementsWithinColShape(tempCol, "object")) do
			if element:getModel() == self.m_MagicModel or element:getModel() == self.m_NormalModel then
				if element.Id then
					sql:queryExec("DELETE FROM ??_Eastereggs WHERE Id = ?;", sql:getPrefix(), element.Id)
					self.m_Eastereggs[Id] = nil
					element:destroy()
					player:sendInfo(_("Osterei entfernt!", player))
				else
				    player:sendError(_("Osterei nicht gefunden!", player))
				end
			end
		end
    else
        player:sendError(_("Du darfst in keinem Fahrzeug sitzen!", player))
    end
end

function ItemEasteregg:reload()
	for id, object in pairs(self.m_Eastereggs) do
		if isElement(object) then
			object:destroy()
			self.m_Eastereggs[id] = nil
		else
			self.m_Eastereggs[id] = nil
		end
	end
	self.m_Eastereggs = {}

   	local count, countPositions = 0, 0
	local result = sql:queryFetch("SELECT * FROM ??_Eastereggs;", sql:getPrefix())

	for i, row in pairs(result) do
		if chance(33) then
			self:addEasteregg(row.Id, Vector3(row.PosX, row.PosY, row.PosZ))
			count = count+1
		end
		countPositions = countPositions+1
	end
	outputDebugString(count.." Ostereier von "..countPositions.." Positionen geladen!")
end

function ItemEasteregg:addEasteregg(Id, pos)
	self.m_Eastereggs[Id] = createObject(self.m_Model, pos)
	self.m_Eastereggs[Id].Id = Id
    self.m_Eastereggs[Id]:setData("clickable", true, true)
    addEventHandler("onElementClicked",self.m_Eastereggs[Id], bind(self.onEastereggClick, self))
end

function ItemEasteregg:onEastereggClick(button, state, player)
    if button == "left" and state == "down" then
        if source:getModel() == self.m_Model then
            if player:getInventory():getFreePlacesForItem("Osterei") >= 1 then
                source:destroy()
                player:getInventory():giveItem("Osterei", 1)
                player:sendInfo(_("Du hast ein Osterei gesammelt!", player))
            else
                player:sendError(_("Du kannst nicht soviele Ostereier tragen! Maximal %d Stk.!", player, player:getInventory():getMaxItemAmount("Osterei")))
            end
        end
    end
end
