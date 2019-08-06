-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/MapEditor/MapEditor.lua
-- *  PURPOSE:     Map Editor class
-- *
-- ****************************************************************************

MapEditor = inherit(Singleton)
addRemoteEvents{"MapEditor:enableClient", "MapEditor:giveControlPermission"}

function MapEditor.enableClient(state, mapId)
    MapEditor:new()
    MapEditor:getSingleton():enableEditorMode(state, mapId)
end
addEventHandler("MapEditor:enableClient", root, MapEditor.enableClient)

function MapEditor:constructor()
    self.m_ClickBind = bind(self.Event_onClientClick, self)
    self.m_DoubleClickBind = bind(self.Event_onClientDoubleClick, self)
    self.m_ObjectPlacedBind = bind(self.onObjectPlaced, self)
    self.m_NewObjectPlacedBind = bind(self.onNewObjectPlaced, self)
    self.m_KeyBind = bind(self.Event_onClientKey, self)
    self.m_PermissionBind = bind(self.receiveControlPermission, self)
    self.m_MeshRenderBind = bind(self.renderMesh, self)
    
    self.m_DrawLineSize = 300
    self.m_ObjectXML = xmlLoadFile("files/data/objects.xml")
    self.m_Shader = dxCreateShader("files/shader/mapeditorColorize.fx")
    self.m_DeleteMessage = "Du bist im Begriff ein World-Object der Standard Map zu entfernen, denke lieber zwei Mal nach, ob Du wirklich dieses Objekt entfernen willst!"
end

function MapEditor:destructor()
    if self.m_ObjectXML then
        xmlUnloadFile(self.m_ObjectXML)
    end
    if self.m_Shader then
        destroyElement(self.m_Shader)
    end
end

function MapEditor:enableEditorMode(state, mapId)
    if state == true then
        if not isEventHandlerAdded("onClientClick", root, self.m_ClickBind) then
            addEventHandler("onClientClick", root, self.m_ClickBind)
            addEventHandler("onClientDoubleClick", root, self.m_DoubleClickBind)
            addEventHandler("onClientKey", root, self.m_KeyBind)
            addEventHandler("MapEditor:giveControlPermission", root, self.m_PermissionBind)
            addEventHandler("onClientRender", root, self.m_MeshRenderBind)
        end
        self.m_ControlledObject = nil
        self.m_MapId = mapId
        MapEditorMainGUI:new()
    else
        removeEventHandler("onClientClick", root, self.m_ClickBind)
        removeEventHandler("onClientDoubleClick", root, self.m_DoubleClickBind)
        removeEventHandler("onClientKey", root, self.m_KeyBind)
        removeEventHandler("MapEditor:giveControlPermission", root, self.m_PermissionBind)
        removeEventHandler("onClientRender", root, self.m_MeshRenderBind)
        if self.m_ControlledObject then
            triggerServerEvent("MapEditor:requestControlForObject", self.m_ControlledObject, "removeControl")
        end
        self.m_ControlledObject = nil
        self.m_MapId = nil
        if self.m_ShortMessage then delete(self.m_ShortMessage) end
        MapEditorMainGUI:getSingleton():setClosed()
        if MapEditorMainGUI:isInstantiated() then delete(MapEditorMainGUI:getSingleton()) end
        if MapEditorMapGUI:isInstantiated() then delete(MapEditorMapGUI:getSingleton()) end
        if MapEditorObjectGUI:isInstantiated() then delete(MapEditorObjectGUI:getSingleton()) end
        if MapEditorObjectCreateGUI:isInstantiated() then delete(MapEditorObjectCreateGUI:getSingleton()) end
        if MapEditorEditingPlayersGUI:isInstantiated() then delete(MapEditorEditingPlayersGUI:getSingleton()) end
        delete(self)
    end
end

function MapEditor:getEditingMap()
    return self.m_MapId
end

function MapEditor:Event_onClientClick(button, state, absoluteX, absoluteY, worldX, worldY, worldZ, element)
    if MapEditorMapGUI:isInstantiated() or MapEditorObjectGUI:isInstantiated() or self.m_PlacingMode or GUIElement.getHoveredElement() then 
        return 
    end

    if state == "up" then
        if isElement(element) then
            if element:getType() == "object" then
                if element:getData("MapEditor:object") then
                    if button == "left" then
                        triggerServerEvent("MapEditor:requestControlForObject", element, "normal", self.m_ControlledObject)
                        return
                    elseif button == "right" then
                        triggerServerEvent("MapEditor:requestControlForObject", element, "ObjectPlacer", self.m_ControlledObject)
                        return
                    end
                else
                    if element.m_IsTemporary then 
                        return 
                    end

                    ErrorBox:new("Dieses Objekt kannst Du nicht bearbeiten!")
                end
            end
        end
    end
    
    if not isElement(element) or not element:getData("MapEditor:object") then
        if self.m_ControlledObject and not self.m_ControlledObject.m_IsTemporary then
            triggerServerEvent("MapEditor:requestControlForObject", self.m_ControlledObject, "removeControl")
            self.m_ControlledObject = nil
            if self.m_ObjectBlip then
                delete(self.m_ObjectBlip)
            end
        end
    end
end

function MapEditor:Event_onClientDoubleClick(button, absoluteX, absoluteY, worldX, worldY, worldZ, element)
    if button == "left" then

        if self:getRemovingMode() then
            local worldModelId = false
            if ClickHandler:getSingleton().m_WorldObjectInfos then
                worldModelId = ClickHandler:getSingleton().m_WorldObjectInfos[1]
                wX = ClickHandler:getSingleton().m_WorldObjectInfos[2]
                wY = ClickHandler:getSingleton().m_WorldObjectInfos[3]
                wZ = ClickHandler:getSingleton().m_WorldObjectInfos[4]
                wrX = ClickHandler:getSingleton().m_WorldObjectInfos[5]
                wrY = ClickHandler:getSingleton().m_WorldObjectInfos[6]
                wrZ = ClickHandler:getSingleton().m_WorldObjectInfos[7]
                worldLODModelId = ClickHandler:getSingleton().m_WorldObjectInfos[8]
            end
            if worldModelId then
                nextframe(
                    function()
                        self:setRemovingMode(false, true)
                        self.m_ControlledObject = createObject(worldModelId, wX, wY, wZ, wrX, wrY, wrZ)
                        self.m_ControlledObject:setScale(1.001)
                        self:colorizeObject(worldModelId, self.m_ControlledObject)
                        self.m_ControlledObject.m_IsTemporary = true
                        
                        self.m_ShortMessage:setText(("Du bist im Begriff das World-Object \"%s\" zu löschen!\n(Linksklick Ja, Rechtsklick Nein)"):format(self:getWorldModelName(worldModelId) or "UNBEKANNT"))
                        self.m_ShortMessage.onLeftClick = function()
                            nextframe(function()
                                local radius = self.m_ControlledObject:getRadius()
                                self:colorizeObject(false)
                                self.m_ControlledObject:destroy()
                                self.m_ControlledObject = nil
                                triggerServerEvent("MapEditor:removeWorldModel", localPlayer, worldModelId, wX, wY, wZ, wrX, wrY, wrZ, radius, worldLODModelId)
                                delete(self.m_ShortMessage)
                                return
                            end)
                        end
                        self.m_ShortMessage.onRightClick = function()
                            nextframe(function()
                                self:colorizeObject(false)
                                self.m_ControlledObject:destroy()
                                self.m_ControlledObject = nil
                                delete(self.m_ShortMessage)
                                return
                            end)
                        end
                    end
                )
            end
        end

        if isElement(element) and element:getType() == "object" then
            if element:getData("MapEditor:object") then
                triggerServerEvent("MapEditor:requestControlForObject", element, "ObjectSetter")
            end
        end
    end
end

function MapEditor:Event_onClientKey(button, state)
    if MapEditorObjectGUI:isInstantiated() then
        return
    end

    if button == "delete" and state == false then
        if self.m_ControlledObject then
            if self.m_ObjectBlip then
                delete(self.m_ObjectBlip)
            end
            nextframe(function()
                triggerServerEvent("MapEditor:removeObject", self.m_ControlledObject)
                self.m_ControlledObject = nil
            end)
        end
    elseif button == "c" and state == false then
        if self.m_ControlledObject then
            local x, y, z = getElementPosition(self.m_ControlledObject)
            local rx, ry, rz = getElementRotation(self.m_ControlledObject)
            local sx, sy, sz = getObjectScale(self.m_ControlledObject)
            local interior = getElementInterior(self.m_ControlledObject)
            local dimension = getElementDimension(self.m_ControlledObject)
            local model = getElementModel(self.m_ControlledObject)
            local breakable = isObjectBreakable(self.m_ControlledObject)
            local collision = getElementCollisionsEnabled(self.m_ControlledObject)
            local doublesided = isElementDoubleSided(self.m_ControlledObject)
            triggerServerEvent("MapEditor:requestControlForObject", self.m_ControlledObject, "removeControl")
            triggerServerEvent("MapEditor:placeObject", localPlayer, x, y, z, rx, ry, rz, sx, sy, sz, interior, dimension, model, breakable, collision, doublesided)
            self.m_ControlledObject = nil
        end
    end
end

function MapEditor:getObjectXML()
    return self.m_ObjectXML
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

function MapEditor:setRemovingMode(state, keepShortMessage)
    self.m_RemovingMode = state
    if state == true then
        self.m_ShortMessage = ShortMessage:new(self.m_DeleteMessage, "Map Editor: Hinweis", Color.Red, -1, callback, false, false, false, true)
    else
        if self.m_ShortMessage and not keepShortMessage then
            delete(self.m_ShortMessage)
        end
    end
end

function MapEditor:getRemovingMode()
    return self.m_RemovingMode
end

function MapEditor:onNewObjectPlaced(position, rotation)
    if position == false then
        MapEditorObjectCreateGUI:getSingleton():setOpened()
        MapEditorObjectCreateGUI:getSingleton():show()
        return
    end

    self:onObjectPlaced(position, rotation)
    delete(MapEditorObjectCreateGUI:getSingleton())
end

function MapEditor:onObjectPlaced(position, rotation, scale, interior, dimension, model, breakable, collision, doublesided)
    if position == false then 
        self:setPlacingMode(false)
        return
    end

    local x, y, z = position.x, position.y, position.z
    local rx, ry, rz
    if type(rotation) == "number" then
        rx, ry, rz = 0, 0, rotation
        if self.m_ControlledObject then
            rx, ry = getElementRotation(self.m_ControlledObject)
        end
    else
        rx, ry, rz = rotation.x, rotation.y, rotation.z
    end
    local sx, sy, sz
    if scale then
        sx, sy, sz = scale.x, scale.y, scale.z
    else
        sx, sy, sz = 1, 1, 1
    end
    local interior = interior or localPlayer:getInterior()
    local dimension = dimension or localPlayer:getDimension()
    local model = model or self.m_PlacingModel
    if breakable == nil then
        breakable = false
    end
    if collision == nil then
        collision = true
    end
    if doublesided == nil then
        doublesided = false
    end

    triggerServerEvent("MapEditor:placeObject", self.m_ControlledObject or localPlayer, x, y, z, rx, ry, rz, sx, sy, sz, interior, dimension, model, breakable, collision, doublesided)
    self.m_ControlledObject = nil
    if self.m_ObjectBlip then
        delete(self.m_ObjectBlip)
    end
    self:setPlacingMode(false)
end

function MapEditor:receiveControlPermission(object, callbackType, permission)
    if permission == true then
        if callbackType == "normal" then
            self.m_ControlledObject = object
        elseif callbackType == "ObjectPlacer" then
            self.m_ControlledObject = object
            ObjectPlacer:new(self.m_ControlledObject:getModel(), self.m_ObjectPlacedBind, object, true)
            self:setPlacingMode(true, object:getModel())
        elseif callbackType == "ObjectSetter" then
            MapEditorObjectGUI:new(object)
            self.m_ControlledObject = object
        end
        if self.m_ObjectBlip then
            delete(self.m_ObjectBlip)
        end
        local x, y = getElementPosition(object)
        self.m_ObjectBlip = Blip:new("Marker.png", x, y, 3000, {255, 255, 0}, {255, 255, 0})
        self.m_ObjectBlip:attach(object)
    end
end

function MapEditor:selectObject(object, request)
    self:colorizeObject(false)
    if isElement(self.m_ControlledObject) and self.m_ControlledObject.m_IsTemporary then
        self.m_ControlledObject:destroy()
        self.m_ControlledObject = nil
    end

    if object and isElement(object) then
        triggerServerEvent("MapEditor:requestControlForObject", object, request, self.m_ControlledObject)
    end
    if type(object) == "table" then
        self.m_ControlledObject = createObject(object.worldModelId, object.wX, object.wY, object.wZ, object.wrX, object.wrY, object.wrZ)
        self.m_ControlledObject:setInterior(object.interior)
        self:colorizeObject(object.worldModelId, self.m_ControlledObject)
        self.m_ControlledObject.m_IsTemporary = true
        if self.m_ObjectBlip then
            delete(self.m_ObjectBlip)
        end
        self.m_ObjectBlip = Blip:new("Marker.png", object.wX, object.wY, 3000, {255, 255, 0}, {255, 255, 0})
        self.m_ObjectBlip:attach(self.m_ControlledObject)
    end
end

function MapEditor:colorizeObject(model, object)
    if self.m_ShaderTextures then
        for key, texture in pairs(self.m_ShaderTextures) do
            engineRemoveShaderFromWorldTexture(self.m_Shader, texture)
        end
        self.m_ShaderTextures = nil
    end
    if not model then
        return
    end

    self.m_ShaderTextures = engineGetVisibleTextureNames("*", model)
    if #self.m_ShaderTextures > 0 then
        for key, texture in pairs(self.m_ShaderTextures) do
            engineApplyShaderToWorldTexture(self.m_Shader, texture, object)
        end
    end
end

function MapEditor:renderMesh()
    if self.m_ControlledObject and not self.m_PlacingMode then
        if not isElement(self.m_ControlledObject) then
            return
        end
        
        local x, y, z = getElementPosition(self.m_ControlledObject)
        local basedistance = self.m_ControlledObject:getDistanceFromCentreOfMassToBaseOfModel()
        local basedistance = basedistance - 0.1
        dxDrawLine3D(x, y, z-basedistance, x+self.m_DrawLineSize, y, z-basedistance, tocolor(255, 0, 0, 255), 2.0)
        dxDrawLine3D(x, y, z-basedistance, x, y+self.m_DrawLineSize, z-basedistance, tocolor(0, 255, 0, 255), 2.0)
        dxDrawLine3D(x, y, z-basedistance, x, y, z-basedistance+self.m_DrawLineSize, tocolor(0, 0, 255, 255), 2.0)

        if not isElementOnScreen(self.m_ControlledObject) then
            return
        end

        local x1, y1, z1, x2, y2, z2 = getElementBoundingBox(self.m_ControlledObject)
        local x1 = x+x1
        local y1 = y+y1
        local z1 = z+z1
        local x2 = x+x2
        local y2 = y+y2
        local z2 = z+z2

        dxDrawLine3D(x1, y1, z1, x2, y1, z1, tocolor(255, 255, 255, 255), 2.0)
        dxDrawLine3D(x1, y1, z2, x2, y1, z2, tocolor(255, 255, 255, 255), 2.0)

        dxDrawLine3D(x1, y2, z1, x2, y2, z1, tocolor(255, 255, 255, 255), 2.0)
        dxDrawLine3D(x1, y2, z2, x2, y2, z2, tocolor(255, 255, 255, 255), 2.0)

        dxDrawLine3D(x1, y1, z1, x1, y2, z1, tocolor(255, 255, 255, 255), 2.0)
        dxDrawLine3D(x1, y1, z2, x1, y2, z2, tocolor(255, 255, 255, 255), 2.0)

        dxDrawLine3D(x2, y1, z1, x2, y2, z1, tocolor(255, 255, 255, 255), 2.0)
        dxDrawLine3D(x2, y1, z2, x2, y2, z2, tocolor(255, 255, 255, 255), 2.0)

        dxDrawLine3D(x1, y1, z1, x1, y1, z2, tocolor(255, 255, 255, 255), 2.0)
        dxDrawLine3D(x1, y2, z1, x1, y2, z2, tocolor(255, 255, 255, 255), 2.0)

        dxDrawLine3D(x2, y1, z1, x2, y1, z2, tocolor(255, 255, 255, 255), 2.0)
        dxDrawLine3D(x2, y2, z1, x2, y2, z2, tocolor(255, 255, 255, 255), 2.0)

    end
end

function MapEditor:getWorldModelName(id)
	local objects = MapEditor:getSingleton():getObjectXML()
    for key, node in pairs(xmlNodeGetChildren(objects)) do
        for k, subnode in pairs(xmlNodeGetChildren(node)) do
            if xmlNodeGetAttribute(subnode, "model") then
                if xmlNodeGetAttribute(subnode, "model") == tostring(id) then
					return xmlNodeGetAttribute(subnode, "name")
				end
            else
                for sk, subsubnode in pairs(xmlNodeGetChildren(subnode)) do
                    if xmlNodeGetAttribute(subsubnode, "model") == tostring(id) then
                    	return xmlNodeGetAttribute(subsubnode, "name")
					end
                end
            end
        end
    end
end

function MapEditor:findMatchingObjects(name)
    local objecttable = {}
	local objects = MapEditor:getSingleton():getObjectXML()
    for key, node in pairs(xmlNodeGetChildren(objects)) do
        for k, subnode in pairs(xmlNodeGetChildren(node)) do
            if xmlNodeGetAttribute(subnode, "model") then
                if string.find(string.lower(xmlNodeGetAttribute(subnode, "name")), string.lower(name)) then
					objecttable[#objecttable+1] = {xmlNodeGetAttribute(subnode, "model"), xmlNodeGetAttribute(subnode, "name")}
				end
            else
                for sk, subsubnode in pairs(xmlNodeGetChildren(subnode)) do
                    if string.find(string.lower(xmlNodeGetAttribute(subsubnode, "name")), string.lower(name)) then
                    	objecttable[#objecttable+1] = {xmlNodeGetAttribute(subsubnode, "model"), xmlNodeGetAttribute(subsubnode, "name")}
					end
                end
            end
        end
    end
    return objecttable
end