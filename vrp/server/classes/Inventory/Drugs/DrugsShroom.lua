-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/Drugs/DrugsShroom.lua
-- *  PURPOSE:     Shroom class
-- *
-- ****************************************************************************
DrugsShroom = inherit(ItemDrugs)

function DrugsShroom:constructor()
    self.m_Path = "files/data/mushrooms.dat"
    self.m_MagicModel = 1882
    self.m_NormalModel = 1947
    self.m_Models = {self.m_MagicModel, self.m_NormalModel}
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
        createObject(self.m_Models[math.random(1, #self.m_Models)], pos)
        player:sendInfo(_("Mushroom hinzugefügt!", player))
        self:savePositions()
    else
        player:sendError(_("Du darfst in keinem Fahrzeug sitzen!", player))
    end
end

function DrugsShroom:loadPositions()

    if not fileExists(self.m_Path) then
        fileClose(fileCreate(self.m_Path))
    end
    local file = fileOpen (self.m_Path, false)
	local buffer
	while not fileIsEOF(file) do
		buffer = fileRead(file, 50000)
	end
	fileClose(file)
	self.m_MushRoomTable = fromJSON(buffer)
    outputDebug("mushrooms.dat loaded")
end

function DrugsShroom:savePositions()
    local mushRoomJSON = toJSON(self.m_MushRoomTable)
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
            self.m_Mushrooms[#self.m_Mushrooms+1] = createObject(self.m_Models[math.random(1, #self.m_Models)], unpack(pos))
        end
    end
end
