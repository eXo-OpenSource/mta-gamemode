-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/ObjectPlacer.lua
-- *  PURPOSE:     Class that simplifies placing objects via mouse (similar to the editor)
-- *
-- ****************************************************************************
ObjectPlacer = inherit(Object)

function ObjectPlacer:constructor(model, callback)
    showCursor(true)

    self.m_Object = createObject(model, localPlayer:getPosition())
    self.m_Object:setCollisionsEnabled(false)
    self.m_Callback = callback

    self.m_CursorMove = bind(self.Event_CursorMove, self)
    addEventHandler("onClientCursorMove", root, self.m_CursorMove)

    self.m_MouseWheel = bind(self.Event_MouseWheel, self)
    bindKey("mouse_wheel_down", "down", self.m_MouseWheel)
    bindKey("mouse_wheel_up", "down", self.m_MouseWheel)

    self.m_Click = bind(self.Event_Click, self)
    addEventHandler("onClientClick", root, self.m_Click)


end

function ObjectPlacer:destructor()
    if self.m_Object and isElement(self.m_Object) then
        self.m_Object:destroy()
    end

    unbindKey("mouse_wheel_down", "down", self.m_MouseWheel)
    unbindKey("mouse_wheel_up", "down", self.m_MouseWheel)
    removeEventHandler("onClientCursorMove", root, self.m_CursorMove)
    removeEventHandler("onClientClick", root, self.m_Click)
end

function ObjectPlacer:Event_CursorMove(cursorX, cursorY, absX, absY, worldX, worldY, worldZ)
    local camX, camY, camZ = getCameraMatrix()
    local surfaceFound, surfaceX, surfaceY, surfaceZ, element, nx, ny, nz, materialID = processLineOfSight(camX, camY, camZ, worldX, worldY, worldZ, true,
        true, true, true, true, true, false, true, self.m_Object)

	if surfaceFound and materialID ~= 51 and materialID ~= 53 then -- probably add more unexpeted materialIDs
		local surfaceZ = getGroundPosition(surfaceX, surfaceY, surfaceZ)
        self.m_Object:setPosition(surfaceX, surfaceY, surfaceZ + self.m_Object:getDistanceFromCentreOfMassToBaseOfModel())
    end
end

function ObjectPlacer:Event_MouseWheel(button, state)
    if button == "mouse_wheel_down" then
        self.m_Object:setRotation(0, 0, self.m_Object:getRotation().z + 10)
    else
        self.m_Object:setRotation(0, 0, self.m_Object:getRotation().z - 10)
    end
end

function ObjectPlacer:Event_Click()
    if self.m_Callback then
        self.m_Callback(self.m_Object:getPosition(), self.m_Object:getRotation().z)
    end

    -- Self-destruct
    delete(self)
end

addEvent("objectPlacerStart", true)
addEventHandler("objectPlacerStart", root,
    function(model, callbackEvent)
        Inventory:getSingleton():hide()
        setTimer(
        function(model,callbackEvent)
            local objectPlacer = ObjectPlacer:new(model,
                function(position, rotation)
                    triggerServerEvent(callbackEvent, localPlayer, position.x, position.y, position.z, rotation)
                end
            )
        end,250,1,model,callbackEvent)

    end
)
