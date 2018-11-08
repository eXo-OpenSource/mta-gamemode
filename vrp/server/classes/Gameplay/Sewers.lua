-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Sewers.lua
-- *  PURPOSE:     Sewers class
-- *
-- ****************************************************************************
Sewers = inherit(Singleton)
Sewers.EntranceLinks = 
{
    [4] = 2,
    [3] = 7,
    [8] = 5,
    [6] = 13,
    [14] = 11,
    [12] = 20,
    [19] = 23,
    [9] = 17,
    [10] = 21,
}

Sewers.EntranceExternal =
{
    [1] = {Vector3(1489.14551, -1720.22449, 8.93633), 0},  -- BENEATH LS-PS
    [22] = {Vector3(2869.74976, -2124.99414, 5.72266), 90}, -- east-ls
    [15] = { Vector3(2630.69214, -1459.24158, 22.35500), 180}, -- north-east ls
}
function Sewers:constructor() 
    self.m_Entrances = {}
    self:createMap()
end

function Sewers:destructor()

end

function Sewers:createMap()
    self.m_Map = MapParser:new(":exo_maps/sewer.map")
	self.m_Map:create(3)
	local x, y, z = getElementPosition(self.m_Map:getElements(1)[1])
	local bin = createObject(1337, x, y, z) 
	setElementAlpha(bin, 0)
    setElementCollisionsEnabled(bin, false)
    setElementDimension(bin, 3)
    setElementInterior(bin, 21)
    local entrances = {}
    local mx, my, mz
	for key, obj in ipairs(self.m_Map.m_Maps[1]) do 
        if isElement(obj) then
            if obj:getType() == "marker" then
                obj:setPosition(obj:getPosition().x, obj:getPosition().y, obj:getPosition().z+1.2)
                table.insert(entrances, obj)
                obj:setAlpha(0)
            end
            attachRotationAdjusted ( obj, bin)
		end
    end
    local enter
    setElementPosition(bin, x, y, z+400)
    for i = 1, #entrances do 
        enter = nil
        if Sewers.EntranceLinks[i] then 
            enter = InteriorEnterExit:new( entrances[i]:getPosition(), entrances[Sewers.EntranceLinks[i]]:getPosition(), 0, 0, 21, 3, 21, 3) 
            self.m_Entrances[enter] = true
        elseif Sewers.EntranceExternal[i] then  
            enter = InteriorEnterExit:new( Sewers.EntranceExternal[i][1],  entrances[i]:getPosition(), 0, Sewers.EntranceExternal[i][2], 21, 3, 0, 0) 
            self.m_Entrances[enter] = true
        end
        if enter then 
            enter:setMarkerType("arrow")
        end
    end    
end
