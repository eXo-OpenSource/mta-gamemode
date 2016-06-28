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
    self.m_MushRoomTable = {}
    self:load()


    addCommandHandler("addMushroom", bind(self.addPosition, self))
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


end

function DrugsShroom:expire( player )
  player.m_DrugOverDose = 0
  player:triggerEvent("onClientItemExpire", "Shrooms" )
end

function DrugsShroom:addPosition(player, cmd)
    if not player:getOccupiedVehicle() then
        local pos = player:getPosition()
        pos.z = pos.z-1
        if not self.m_MushRoomTable then self.m_MushRoomTable = {} end
        table.insert(self.m_MushRoomTable, {pos.x, pos.y, pos.z})
        self:addMushroom(pos.x, pos.y, pos.z)
        player:sendInfo(_("Mushroom hinzugefügt!", player))
        self:savePositions()
    else
        player:sendError(_("Du darfst in keinem Fahrzeug sitzen!", player))
    end
end

function DrugsShroom:loadPositions()
    if not getResourceFromName("vrp_data") then createResource("vrp_data") end
    if not getResourceState(getResourceFromName("vrp_data")) == "running" then startResource(getResourceFromName("vrp_data")) end
    if not fileExists(self.m_Path) then
        local file = fileCreate(self.m_Path)
        fileSetPos(file, 0)
        fileWrite(file, toJSON(self.m_MushRoomTable))
        fileClose(file)
        fileClose()
    end

    local file = fileOpen (self.m_Path, false)
    if file then
    	local buffer
    	while not fileIsEOF(file) do
    		buffer = fileRead(file, 50000)
    	end
    	fileClose(file)
        if fromJSON(buffer) then
    	       self.m_MushRoomTable = fromJSON(buffer)
           end
        outputDebug("mushrooms.dat - Loaded "..#self.m_MushRoomTable.." Mushroom Positions!")
    end
end

function DrugsShroom:savePositions()
    local mushRoomJSON = toJSON(self.m_MushRoomTable)
    if not getResourceFromName("vrp_data") then createResource("vrp_data") end
    if not getResourceState(getResourceFromName("vrp_data")) == "running" then startResource(getResourceFromName("vrp_data")) end
    fileDelete(self.m_Path)
    if not fileExists(self.m_Path) then
        fileClose(fileCreate(self.m_Path))
    end
    local file = fileOpen (self.m_Path, false)
    fileSetPos(file, 0)
    fileWrite(file, mushRoomJSON)
    fileClose(file)
    outputDebug("mushrooms.dat saved")
end


function DrugsShroom:load()
    self:loadPositions()
    self.m_Mushrooms = {}
    if self.m_MushRoomTable then
        for index, pos in pairs(self.m_MushRoomTable) do
            self.m_Mushrooms[#self.m_Mushrooms+1] =
            self:addMushroom(unpack(pos))
        end
    end
end

function DrugsShroom:addMushroom(posX, posY, posZ)
    local index = #self.m_Mushrooms+1
    self.m_Mushrooms[index] = createObject(self.m_Models[math.random(1, #self.m_Models)], posX, posY, posZ)
    self.m_Mushrooms[index]:setData("clickable", true, true)
    addEventHandler("onElementClicked",self.m_Mushrooms[index], bind(self.onMushroomClick, self))
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
