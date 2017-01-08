-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/Drugs/DrugsShroom.lua
-- *  PURPOSE:     Shroom class
-- *
-- ****************************************************************************
DrugsShroom = inherit(ItemDrugs)

function DrugsShroom:constructor()
    self.m_Path = ":vrp_data/mushrooms.dat"
    self.m_MagicModel = 1947
    self.m_NormalModel = 1882
    self.m_Models = {self.m_MagicModel, self.m_NormalModel}
	self.m_MushRooms = {}

	self.m_TimedPulse = TimedPulse:new(60*60*1000)
	self.m_TimedPulse:registerHandler(bind(self.reload, self))
    self:reload()

    addCommandHandler("addMushroom", bind(self.addPosition, self))
	addCommandHandler("removeMushroom", bind(self.removePosition, self))
end

function DrugsShroom:destructor()

end

function DrugsShroom:use( player )
  	player:triggerEvent("onClientItemUse", "Shrooms", SHROOM_EXPIRETIME )
    if isTimer( player.m_ShroomExpireTimer ) then
      killTimer( player.m_ShroomExpireTimer )
      if ( player.m_DrugOverdose ) then
        player.m_DrugOverdose = player.m_DrugOverdose + 1
      else
        player.m_DrugOverdose = 1
      end
    end
    player.m_ShroomExpireFunc = bind( DrugsShroom.expire, self )
    player.m_ShroomExpireTimer = setTimer( player.m_ShroomExpireFunc, SHROOM_EXPIRETIME, 1, player )
	StatisticsLogger:getSingleton():addDrugUse( player, "Shrooms" )
end

function DrugsShroom:expire( player )
  player.m_DrugOverDose = 0
  player:triggerEvent("onClientItemExpire", "Shrooms" )
end

function DrugsShroom:addPosition(player)
	if player:getRank() < RANK.Moderator then
		player:sendError(_("Du bist nicht berechtigt!", player))
		return
	end
    if not player:getOccupiedVehicle() then
        local pos = player:getPosition()
        pos.z = pos.z-1
		sql:queryExec("INSERT INTO ??_mushrooms(PosX, PosY, PosZ) VALUES(?, ?, ?);", sql:getPrefix(), pos.x, pos.y, pos.z)
        self:addMushroom(sql:lastInsertId(), pos)
        player:sendInfo(_("Mushroom hinzugefügt!", player))
    else
        player:sendError(_("Du darfst in keinem Fahrzeug sitzen!", player))
    end
end

function DrugsShroom:removePosition(player)
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
					sql:queryExec("DELETE FROM ??_mushrooms WHERE Id = ?;", sql:getPrefix(), element.Id)
					self.m_MushRooms[Id] = nil
					element:destroy()
					player:sendInfo(_("Mushroom entfernt!", player))
				else
				    player:sendError(_("Mushroom nicht gefunden!", player))
				end
			end
		end
    else
        player:sendError(_("Du darfst in keinem Fahrzeug sitzen!", player))
    end
end

function DrugsShroom:reload()
	for id, object in pairs(self.m_MushRooms) do
		object:destroy()
		self.m_MushRooms[id] = nil
	end
	self.m_MushRooms = {}

   	local count, countPositions = 0, 0
	local result = sql:queryFetch("SELECT * FROM ??_mushrooms;", sql:getPrefix())

	for i, row in pairs(result) do
		if chance(33) then
			self:addMushroom(row.Id, Vector3(row.PosX, row.PosY, row.PosZ))
			count = count+1
		end
		countPositions = countPositions+1
	end
	outputDebugString(count.."Mushrooms von "..countPositions.." Positionen geladen!")
end

function DrugsShroom:addMushroom(Id, pos)
	local model = self.m_Models[math.random(1, #self.m_Models)]
	self.m_MushRooms[Id] = createObject(model, pos)
	self.m_MushRooms[Id].Id = Id
    self.m_MushRooms[Id]:setData("clickable", true, true)
    addEventHandler("onElementClicked",self.m_MushRooms[Id], bind(self.onMushroomClick, self))
end

function DrugsShroom:onMushroomClick(button, state, player)
    if button == "left" and state == "down" then
        if source:getModel() == self.m_MagicModel then
            if player:getInventory():getFreePlacesForItem("Shrooms") >= 1 then
                source:destroy()
                player:getInventory():giveItem("Shrooms", 1)
                player:sendInfo(_("Du hast einen seltenen Magic-Mushroom gesammelt!", player))
            else
                player:sendError(_("Du kannst nicht soviele Shrooms tragen! Maximal %d Stk.!", player, player:getInventory():getMaxItemAmount("Shrooms")))
            end
        elseif source:getModel() == self.m_NormalModel then
            if player:getInventory():getFreePlacesForItem("Pilz") >= 1 then
                source:destroy()
                player:getInventory():giveItem("Pilz", 1)
                player:sendInfo(_("Du hast einen Pilz gesammelt!", player))
            else
                player:sendError(_("Du kannst nicht soviele Pilze tragen! Maximal %d Stk.!", player, player:getInventory():getMaxItemAmount("Pilz")))
            end
        end
    end
end
