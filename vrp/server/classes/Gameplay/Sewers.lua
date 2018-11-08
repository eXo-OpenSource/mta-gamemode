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
    self.m_Dimension = 3
    self.m_Entrances = {}
    self:createMap()

    self.m_RectangleCol = createColRectangle( 1248.42, -2081.78, 1668.47- 1248.42, -1348.3+2081.78 )
    self.m_RectangleCol:setDimension(self.m_Dimension)

    addEventHandler("onElementDimensionChange", root, function( dim)
        if dim == self.m_Dimension then 
            if source:isWithinColShape(self.m_RectangleCol) then 
                if source:getType() == "player" then 
                    source:setInSewer(true)
                    source:triggerEvent("Sewers:applyTexture")
                end
            end
        else 
            if source:isWithinColShape(self.m_RectangleCol) then 
                if source:getType() == "player" then 
                    source:setInSewer(false)
                    source:triggerEvent("Sewers:removeTexture")
                end
            end
        end
    end
    )
    addEventHandler("onColShapeHit", self.m_RectangleCol, function( hE, bDim)
        if hE:getType() == "player" and bDim then 
            hE:setInSewer(true)
            hE:triggerEvent("Sewers:applyTexture")
        end
    end)
    addEventHandler("onColShapeLeave", self.m_RectangleCol, function( hE, bDim)
        if hE:getType() == "player" and bDim then 
            hE:setInSewer(false)
            hE:triggerEvent("Sewers:removeTexture")
        end
    end)
end

function Sewers:destructor()

end

function Sewers:createMap()
    self.m_Map = MapParser:new(":exo_maps/sewer.map")
	self.m_Map:create(self.m_Dimension)
	local x, y, z = getElementPosition(self.m_Map:getElements(1)[1])
	local bin = createObject(1337, x, y, z) 
	setElementAlpha(bin, 0)
    setElementCollisionsEnabled(bin, false)
    setElementDimension(bin, self.m_Dimension)
    setElementInterior(bin, 0)
    local entrances = {}
    local mx, my, mz
	for key, obj in ipairs(self.m_Map.m_Maps[1]) do 
        if isElement(obj) then
            if obj:getType() == "marker" then
                obj:setPosition(obj:getPosition().x, obj:getPosition().y, obj:getPosition().z+0.3)
                table.insert(entrances, obj)
                obj:setAlpha(0)
            end
            attachRotationAdjusted ( obj, bin)
		end
    end
    local enter
    setElementPosition(bin, 1483.02, -1736.06, 13.38-50)
    for i = 1, #entrances do 
        enter = nil
        if Sewers.EntranceLinks[i] then 
            enter = Teleporter:new( entrances[i]:getPosition(), entrances[Sewers.EntranceLinks[i]]:getPosition(), 0, 0, 0, self.m_Dimension, 0, self.m_Dimension) 
            self.m_Entrances[enter] = true
        elseif Sewers.EntranceExternal[i] then  
            enter = Teleporter:new( Sewers.EntranceExternal[i][1],  entrances[i]:getPosition(), 0, Sewers.EntranceExternal[i][2], 0, self.m_Dimension, 0, 0) 
            self.m_Entrances[enter] = true
            enter:setFade(true)
        end
    end    
end
