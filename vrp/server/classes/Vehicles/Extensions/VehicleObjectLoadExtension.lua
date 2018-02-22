-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Vehicles/Extensions/VehicleObjectLoadExtension.lua
-- *  PURPOSE:     utility class to manage attaching of objects to a vehicle
-- *
-- ****************************************************************************

VehicleObjectLoadExtension = inherit(Object) --gets inherited from vehicle to provide methods to vehicle object
VehicleObjectLoadExtension.ms_InteractionCooldown = 1000
VehicleObjectLoadExtension.ms_LoadHook = Hook:new()
VehicleObjectLoadExtension.ms_UnloadHook = Hook:new()


function VehicleObjectLoadExtension:canObjectBeLoaded(objId)
    if VEHICLE_OBJECT_ATTACH_POSITIONS[self:getModel()] and self.m_LoadedObjects then
        if objId then
            return VEHICLE_OBJECT_ATTACH_POSITIONS[self:getModel()].objectId == objId
        end
        return true -- return true if there is any object loadable
    end
    return false
end

function VehicleObjectLoadExtension:switchObjectLoadingMarker(state)
    if self.m_LoadingMarkerActive ~= state then
        if state then
            local markerOffset = VEHICLE_OBJECT_ATTACH_POSITIONS[self:getModel()].loadMarkerPos
            self.m_LoadingMarker = createMarker(self.position + self.matrix.forward * markerOffset.y + self.matrix.up * markerOffset.z + self.matrix.right * markerOffset.x, "corona", 1, 58, 186, 242, 50)
            addEventHandler("onMarkerHit", self.m_LoadingMarker, bind(VehicleObjectLoadExtension.Event_OnLoadingMarkerHit, self))
        else
            if isElement(self.m_LoadingMarker) then
                self.m_LoadingMarker:destroy()
            end
        end
        local doors = VEHICLE_OBJECT_ATTACH_POSITIONS[self:getModel()].vehicleDoors
        if doors then
            for i,v in pairs(doors) do
                setVehicleDoorOpenRatio(self, v, state and 1 or 0, math.random(400, 600))
            end
        end
        self.m_LoadingMarkerActive = state
    end
end

function VehicleObjectLoadExtension:initObjectLoading()
    if VEHICLE_OBJECT_ATTACH_POSITIONS[self:getModel()] and not self.m_LoadedObjects then
        self.m_LoadedObjects = {}
        self.m_LastInteraction = getTickCount()
        if isElementFrozen(self) then
            self:switchObjectLoadingMarker(true)
        end
        addEventHandler("onElementDestroy", self, bind(VehicleObjectLoadExtension.Event_OnDestroy, self))
    end
end

function VehicleObjectLoadExtension:isValidObjectToLoad(object)
    if not isElement(object) then return false end
    return object:getModel() == VEHICLE_OBJECT_ATTACH_POSITIONS[self:getModel()].objectId
end

function VehicleObjectLoadExtension:getMaxObjects()
    if self.m_LoadedObjects then return #VEHICLE_OBJECT_ATTACH_POSITIONS[self:getModel()].positions end
end

function VehicleObjectLoadExtension:getObjectCount()
    if self.m_LoadedObjects then return #self.m_LoadedObjects end
end

function VehicleObjectLoadExtension:Event_OnLoadingMarkerHit(hitEle, dim)
    if not dim then return false end
    if getElementType(hitEle) == "player" then
        outputDebug(hitEle:getPlayerAttachedObject())
        if hitEle:getPlayerAttachedObject() then
            self:tryLoadObject(hitEle, hitEle:getPlayerAttachedObject())
        else
            self:tryUnloadObject(hitEle)
        end
    end
end

function VehicleObjectLoadExtension:Event_OnDestroy()
    self:switchObjectLoadingMarker(false)
end

function VehicleObjectLoadExtension:tryLoadObject(player, object)
    local cooled = (getTickCount() - self.m_LastInteraction) > VehicleObjectLoadExtension.ms_InteractionCooldown
    if self:getObjectCount() < self:getMaxObjects() then
        if self:isValidObjectToLoad(object) then
            if cooled then
                VehicleObjectLoadExtension.getLoadHook():call(self, player, object)
                self:internalLoadObject(player, object)
                self.m_LastInteraction = getTickCount()
            end 
        else
            player:sendError("Dieses Fahrzeug kann dein Objekt nicht transportieren!")
        end
    else
        player:sendError("Dieses Fahrzeug ist voll!")
    end
end

function VehicleObjectLoadExtension:tryUnloadObject(player)
    local cooled = (getTickCount() - self.m_LastInteraction) > VehicleObjectLoadExtension.ms_InteractionCooldown
    if self:getObjectCount() > 0 then
        if not player:getPlayerAttachedObject() then
            if cooled then
                VehicleObjectLoadExtension.getLoadHook():call(self, player, object)
                self:internalUnloadObject(player)
                self.m_LastInteraction = getTickCount()
            end 
        else
            player:sendError("Du hast bereits ein Objekt dabei!")
        end
    else
        player:sendError("Dieses Fahrzeug ist leer!")
    end
    VehicleObjectLoadExtension.getUnloadHook():call(self, player, object)
end

function VehicleObjectLoadExtension:internalLoadObject(player, object)
    player:detachPlayerObject(object)
    local data = VEHICLE_OBJECT_ATTACH_POSITIONS[self:getModel()]
    local pos = data.positions[self:getObjectCount() + 1]
    object:attach(self, pos, 0, 0, data.randomRotation and math.random(0, 360) or data.rotation)
    table.insert(self.m_LoadedObjects, object)
end

function VehicleObjectLoadExtension:internalUnloadObject(player)
    local object = table.remove(self.m_LoadedObjects, #self.m_LoadedObjects)
    object:detach()
    player:attachPlayerObject(object)
    
end

function VehicleObjectLoadExtension.getLoadHook()
    return VehicleObjectLoadExtension.ms_LoadHook
end

function VehicleObjectLoadExtension.getUnloadHook()
    return VehicleObjectLoadExtension.ms_UnloadHook
end


if DEBUG then
    addCommandHandler("geld", function(player)
        local newBag = createObject(1550, player.position + Vector3(0, 1, 0))
        newBag:setData("Money", 1337, true)
        newBag:setData("MoneyBag", true, true)
        player:attachPlayerObject(newBag)
        addEventHandler("onElementClicked", newBag, function(btn, state, player)
            player:attachPlayerObject(source)
        end)
    end)
end