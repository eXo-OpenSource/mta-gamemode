-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/MapEditor/MapEditor.lua
-- *  PURPOSE:     Map Editor class
-- *
-- ****************************************************************************

MapEditor = inherit(Singleton)
addRemoteEvents{"MapEditor:enableClient", "MapEditor:giveControlPermission"}

function MapEditor.enableClient(state)
    MapEditor:new()
    MapEditor:getSingleton():enableEditorMode(state)
end
addEventHandler("MapEditor:enableClient", root, MapEditor.enableClient)

function MapEditor:constructor()
    self.m_ClickBind = bind(self.Event_onClientClick, self)
    self.m_DoubleClickBind = bind(self.Event_onClientDoubleClick, self)
    self.m_ObjectPlacedBind = bind(self.onObjectPlaced, self)
    self.m_KeyBind = bind(self.Event_onClientKey, self)

end

function MapEditor:enableEditorMode(state)
    if state == true then
        if not isEventHandlerAdded("onClientClick", root, self.m_ClickBind) then
            addEventHandler("onClientClick", root, self.m_ClickBind)
            addEventHandler("onClientDoubleClick", root, self.m_DoubleClickBind)
            addEventHandler("onClientKey", root, self.m_KeyBind)
        end
        MapEditorMainGUI:new()
    else
        removeEventHandler("onClientClick", root, self.m_ClickBind)
        removeEventHandler("onClientDoubleClick", root, self.m_DoubleClickBind)
        removeEventHandler("onClientKey", root, self.m_KeyBind)
        delete(MapEditorMainGUI:getSingleton())
    end
end

function MapEditor:Event_onClientClick(button, state, absoluteX, absoluteY, worldX, worldY, worldZ, element)
    if not self.m_ControlledObject then
        if isElement(element) and element:getData("MapEditor:object") then
            if button == "left" and state == "down" then
                triggerServerEvent("MapEditor:requestControlForObject", element, "normal")
            elseif button == "right" and state == "up" then
                triggerServerEvent("MapEditor:requestControlForObject", element, "ObjectPlacer")
            end
        end
    else
        if not isElement(element) or not element:getData("MapEditor:object") then
            triggerServerEvent("MapEditor:requestControlForObject", self.m_ControlledObject, "removeControl")
            self.m_ControlledObject = nil
        end
    end
end

function MapEditor:Event_onClientDoubleClick(button, absoluteX, absoluteY, worldX, worldY, worldZ, element)
    if not self.m_ControlledObject then
        if button == "left" then
            if isElement(element) and element:getData("MapEditor:object") then
                MapEditorObjectGUI:new(element)
                self.m_ControlledObject = element
            end
        end
    end
end

function MapEditor:Event_onClientKey(button, state)
    if button == "delete" and state == "down" then
        if self.m_ControlledObject then
            triggerServerEvent("MapEditor:removeObject", self.m_ControlledObject)
        end
    end
end

function MapEditor:abortPlacing()
    self.m_ControlledObject = nil
end

function MapEditor:setPlacingMode(state, model)
    if state == true then
        self.m_PlacingMode = state
        self.m_PlacingModel = model
    else
        self.m_PlacingMode = nil
        self.m_PlacingModel = nil
    end
end

function MapEditor:onObjectPlaced(position, rotation, scale, interior, dimension, model)
    local x, y, z = position.x, position.y, position.z
    local rx, ry, rz = rotation.x, rotation.y, rotation.z
    local sx, sy, sz
    if scale then
        sx, sy, sz = scale.x, scale.y, scale.z
    else
        sx, sy, sz = 1, 1, 1
    end
    local interior = interior or localPlayer:getInterior()
    local dimension = dimension or localPlayer:getDimension()
    local model = model or self.m_PlacingModel

    if isElement(self.m_ControlledObject) then
        self.m_ControlledObject:setAlpha(255)
        self.m_ControlledObject:setCollisionsEnabled(true)
    end

    triggerServerEvent("MapEditor:placeObject", self.m_ControlledObject or localPlayer, x, y, z, rx, ry, rz, sx, sy, sz, interior, dimension, model)
    self.m_ControlledObject = nil
    self:setPlacingMode(false)
end

function MapEditor:receiveControlPermission(object, callbackType, permission)
    if permission == true then
        if callbackType == "normal" then
            self.m_SelectedObject = object
        elseif callbackType == "ObjectPlacer" then
            self.m_ControlledObject = object
            self.m_ControlledObject:setAlpha(0)
            self.m_ControlledObject:setCollisionsEnabled(false)
            ObjectPlacer:new(self.m_ControlledObject:getModel(), self.m_ObjectPlacedBind, false)
            self:setPlacingMode(true, object:getModel())
        end
    end
end