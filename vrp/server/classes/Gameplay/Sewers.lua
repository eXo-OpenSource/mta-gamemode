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

addRemoteEvents{"Sewers:requestRadioLocation"}
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

    addEventHandler("Sewers:requestRadioLocation", root, function()
        if self.m_SewerRadio then 
            local x,y,z = getElementPosition(self.m_SewerRadio)
            client:triggerEvent("Sewers:getRadioLocation", x, y, z,  self.m_Dimension)
        end
    end)
end

function Sewers:destructor()

end

function Sewers:createMap()
    self:createStorage()

    self.m_Map = MapParser:new(":exo_maps/sewer.map")
	self.m_Map:create(self.m_Dimension)
	local x, y, z = getElementPosition(self.m_Map:getElements(1)[1])
	local bin = createObject(1337, x, y, z) 
	bin:setAlpha(0)
    bin:setCollisionsEnabled(false)
    bin:setDimension(self.m_Dimension)
    bin:setInterior(0)
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

    --// move the whole map to this position 
    bin:setPosition(1483.02, -1736.06, 13.38-50)

    local enter
    for i = 1, #entrances do 
        if Sewers.EntranceLinks[i] then 
            enter = Teleporter:new( entrances[i]:getPosition(), entrances[Sewers.EntranceLinks[i]]:getPosition(), 0, 0, 0, self.m_Dimension, 0, self.m_Dimension) 
            self.m_Entrances[enter] = true
        elseif Sewers.EntranceExternal[i] then  
            enter = Teleporter:new( Sewers.EntranceExternal[i][1],  entrances[i]:getPosition(), 0, Sewers.EntranceExternal[i][2], 0, self.m_Dimension, 0, Sewers.EntranceExternal[i][3] or 0) 
            self.m_Entrances[enter] = true
            enter:setFade(true)
        end
    end
end

function Sewers:createStorage()
    self.m_Storage = MapParser:new(":exo_maps/fraktionen/insurgent_storage.map")
    self.m_Storage:create(self.m_Dimension)
    local x, y, z = getElementPosition(self.m_Storage:getElements(1)[1])
    local bin = createObject(1337, x, y, z) 
    bin:setAlpha(0)
    bin:setCollisionsEnabled(false)
    bin:setDimension(self.m_Dimension)
    bin:setInterior(0)
    local entrance = nil
    self.m_PedPositions = {}
    for key, obj in ipairs(self.m_Storage.m_Maps[1]) do 
        if isElement(obj) then
            if obj:getModel() == 2102 then 
                self.m_SewerRadio = obj
            end
            attachRotationAdjusted ( obj, bin)
            if obj:getType() == "marker" then
                if not entrance then
                    entrance = obj
                else 
                    table.insert(self.m_PedPositions, obj)
                end
                obj:setAlpha(0)
            end
		end
    end
    bin:setPosition(1483.02-200, -1736.06, 13.38-50)
    if entrance and isElement(entrance) then
        Sewers.EntranceExternal[24] = {entrance:getPosition(), 0, self.m_Dimension}
    end
    local p
    for i, marker in ipairs(self.m_PedPositions) do 
        p = createPed(220, marker:getPosition().x, marker:getPosition().y, marker:getPosition().z +0.5)
        p:setFrozen(true)
        p:setDimension(3)
        p:setRotation(0, 0, findRotation(p:getPosition().x, p:getPosition().y, entrance:getPosition().x, entrance:getPosition().y))
    end
end