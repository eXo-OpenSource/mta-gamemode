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
    [25] = 29,
    [28] = 27,
    [26] = 30,
    [33] = 35,
    [31] = 36,
    [37] = 38,
    [32] = 34,

}

Sewers.EntranceExternal =
{
    [1] = {Vector3(1489.14551, -1720.22449, 8.93633), 0},  -- BENEATH LS-PS
    [22] = {Vector3(2877.68, -2124.83, 4.42), 90}, -- east-ls
    [15] = { Vector3(2630.69214, -1459.24158, 22.35500), 180}, -- north-east ls
    [24] = { Vector3(2613.28, -2147.70, -0.22, 0), 90},
}

addRemoteEvents{"Sewers:requestRadioLocation"}
function Sewers:constructor()
    self.m_Dimension = 3
    self.m_RadioLink = "files/audio/Ambient/BENITRATOR.mp3"
    self.m_RadioVolume = 1
    self.m_NoRadioReverb = false
    self.m_Entrances = {}
    self.m_CasinoMembers = {}
    self.m_EntranceMarkers = {}
    self:createMap()

    self.m_RectangleCol = createColRectangle( 1055.47, -2264.60, 1668.47- 1055.47, -1348.3+2264.60 )
    self.m_RectangleCol:setDimension(self.m_Dimension)

    self.m_AntiFallCuboid = createColCuboid( 1055.47, -2264.60, -50, 1668.47- 1055.47, -1348.3+2264.60, 4 )
    self.m_AntiFallCuboid:setDimension(self.m_Dimension)
    addEventHandler("onColShapeHit", self.m_AntiFallCuboid, function(hE, bDim)
        if isValidElement(hE, "player") and bDim then
            self:teleportBack(hE)
        end
    end)
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
        if isValidElement(hE, "player") and bDim then
            hE:setInSewer(true)
            hE:triggerEvent("Sewers:applyTexture")
        end
    end)
    addEventHandler("onColShapeLeave", self.m_RectangleCol, function( hE, bDim)
        if isValidElement(hE, "player") and bDim then
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

function Sewers:teleportBack(player)
    if player:isLoggedIn() then
        local min = math.huge
        local dist, entrance
        if player:getDimension() == self.m_Dimension then
            for id, marker in pairs(self.m_EntranceMarkers) do
                if marker and isElement(marker) then
                    dist = (marker:getPosition() - player:getPosition()):getLength()
                    if min > dist then
                        min = dist
                        entrance = marker
                    end
                end
            end
        end
        if entrance and isElement(entrance) then
            player:setFrozen(true)
            player:setPosition(entrance:getPosition().x, entrance:getPosition().y, entrance:getPosition().z+0.2)
            setTimer(function() player:setFrozen(false) end, 400, 1)
            player:sendInfo("Du wurdest zum nächstgelgenen Ort teleportiert, da du unter die Map gefallen bist!")
        end
    end
end

function Sewers:destructor()

end

function Sewers:createMap()
    self:createSewerCasino()
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

    for k, entranceObj in ipairs(entrances) do
        table.insert(self.m_EntranceMarkers, entranceObj)
    end
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
        table.insert(self.m_EntranceMarkers, entrance)
        Sewers.EntranceExternal[39] = {entrance:getPosition(), 0, self.m_Dimension}
    end

    local randomPed = math.random(1, #self.m_PedPositions)
    local marker = self.m_PedPositions[randomPed]
    local ped =  NPC:new(220, marker:getPosition().x, marker:getPosition().y, marker:getPosition().z +0.5, 0)
    ped:setModel(109)
    ped:setImmortal(true)
    ped:setFrozen(true)
    ped:setDimension(3)
    ped:setRotation(0, 0, findRotation(ped:getPosition().x, ped:getPosition().y, entrance:getPosition().x, entrance:getPosition().y))
    giveWeapon(ped, 30, 200, true)
    setElementData(ped, "SewerPed", true)
    setElementData(ped, "clickable", true)
	addEventHandler("onElementClicked", ped, bind(self.Event_onPedClick, self))
    self:addKevlarToPed(ped)
end

function Sewers:createSewerCasino()
    self.m_Casino = MapParser:new(":exo_maps/sewer-casino.map")
    self.m_Casino:create(self.m_Dimension)
    self.m_EnterCasino = InteriorEnterExit:new(Vector3(1324.11, -2035.92, -32.28), Vector3(508.27499, -1695.637, 800.672), 180, 180, 18, self.m_Dimension, 0, 3)

    for key, obj in ipairs(self.m_Casino.m_Maps[1]) do
        if isElement(obj) then
            if obj:getModel() == 1515 then
                SlotGameManager:getSingleton():add(obj)
            end
		end
    end

    self.m_EffectShape = createColCuboid(456.71, -1742.53, 784.67,100, 55, 55)
    self.m_EffectShape:setDimension(self.m_Dimension)
    self.m_EffectShape:setInterior(18)

    addEventHandler("onColShapeHit", self.m_EffectShape, function( hE, bDim)
        if isValidElement(hE, "player") and bDim and hE:getInterior() == 18 then
            hE:triggerEvent("Sewers:casinoApplyTexture", self.m_RadioLink, self.m_RadioVolume, self.m_NoRadioReverb)
            self.m_CasinoMembers[hE] = true
        end
    end)
    addEventHandler("onColShapeLeave", self.m_EffectShape, function( hE, bDim)
        if isValidElement(hE, "player") then
            hE:triggerEvent("Sewers:casinoRemoveTexture")
            self.m_CasinoMembers[hE] = nil
        end
    end)

    self.m_AntifallCasino = createColCuboid(456.71, -1742.53, 784.67,100, 55, 10)
    self.m_AntifallCasino:setDimension(self.m_Dimension)
    self.m_AntifallCasino:setInterior(18)
    self.m_AntifallCasino:setDimension(self.m_Dimension)
    addEventHandler("onColShapeHit", self.m_AntifallCasino, function(hE, bDim)
        if isValidElement(hE, "player") and hE:getDimension() == self.m_Dimension and hE:getInterior() == 18 then
            hE:setInterior(18)
            hE:setDimension(self.m_Dimension)
            hE:setPosition(Vector3(508.27499, -1695.637, 800.672))
        end
    end)
    local door = createObject(2944, 1323.5, -2035.07, -32.28)
    door:setRotation(0, 0, -10)
    door:setInterior(0)
    door:setDimension(3)

    Slotmachine:new(502.22, -1703.63, 801.32, 0, 0, 90, 18, 3)
end

function Sewers:setCasinoRadio(url, volume, noreverb)
    if url and url ~= "" then
        self.m_RadioLink = url
        self.m_RadioVolume = volume
        self.m_NoRadioReverb = noreverb
        for player, bool in pairs(self.m_CasinoMembers) do
            player:triggerEvent("Sewers:updateCasinoRadio", url, volume or 1, noreverb)
        end
    end
end

function Sewers:lockCasino(state) 
    self.m_EnterCasino.m_Locked = state
end

function Sewers:Event_onPedClick(button, state, player)
	local faction = player:getFaction()

	if
		button ~= "left"
		or state ~= "down"
		or not faction
		or not faction:isEvilFaction()
	then
		return
	end
	player:triggerEvent("openArmsDealerGUI")
end

function Sewers:addKevlarToPed(ped)
    local itemName = "Kevlar"
    local x,y,z = getElementPosition(ped)
    local dim = getElementDimension(ped)
    local int = getElementInterior(ped)
    local model, zOffset, yOffset, scale, rotX, rotZ = WearableShirt.objectTable[itemName][1] or WearableShirt.objectTable["Kevlar"][1],  WearableShirt.objectTable[itemName][2] or WearableShirt.objectTable["Kevlar"][2], WearableShirt.objectTable[itemName][3] or WearableShirt.objectTable["Kevlar"][3], WearableShirt.objectTable[itemName][4] or WearableShirt.objectTable["Kevlar"][4], WearableShirt.objectTable[itemName][5] or WearableShirt.objectTable["Kevlar"][5],  WearableShirt.objectTable[itemName][6] or WearableShirt.objectTable["Kevlar"][6]
    local rotY =  WearableShirt.objectTable[itemName][7] or WearableShirt.objectTable["Kevlar"][7]
    local obj = createObject(model,x,y,z)
    local objName =  WearableShirt.objectTable["Kevlar"][8]
    setElementDimension(obj, dim)
    setElementInterior(obj, int)
    setObjectScale(obj, scale)
    setElementDoubleSided(obj,true)
    exports.bone_attach:attachElementToBone(obj, ped, 3, 0, yOffset, zOffset, rotX , rotY, rotZ)
end
