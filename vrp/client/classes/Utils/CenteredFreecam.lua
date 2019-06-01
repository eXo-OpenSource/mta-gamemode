-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Utils/CenteredFreecam.lua
-- *  PURPOSE:     Class for CenteredFreecam
-- *
-- ****************************************************************************
CenteredFreecam = inherit(Singleton)
addRemoteEvents{"startCenteredFreecam", "stopCenteredFreecam"}

function CenteredFreecam:constructor(element, maxZoom, noClip)
    local element = isElement(element) and element or localPlayer
    self.m_RenderEvent = bind(CenteredFreecam.render, self)
    self.m_MouseEvent = bind(CenteredFreecam.handleMouse, self)
    self.m_ScrollEvent = bind(CenteredFreecam.handleScroll, self)
    self.m_AngleX = 45
    self.m_AngleZ = element.rotation.z
    self.m_Element = element
    self.m_MaxZoom = (maxZoom or 50)
    self.m_Zoom = 1
    self.m_NoClip = noClip
    self.m_CheckObjectsOnClip = false
    self.m_ZoomData = {self.m_MaxZoom * 0.5, self.m_MaxZoom}
    addEventHandler("onClientRender", root, self.m_RenderEvent)
    addEventHandler("onClientCursorMove", root, self.m_MouseEvent)
    addEventHandler("onClientKey", root, self.m_ScrollEvent)
    RadioGUI:getSingleton():setControlEnabled(false)
end

function CenteredFreecam:destructor()
	setCameraTarget(localPlayer)
	removeEventHandler("onClientRender", root, self.m_RenderEvent)
	removeEventHandler("onClientCursorMove", root, self.m_MouseEvent)
	removeEventHandler("onClientKey", root, self.m_ScrollEvent)
	RadioGUI:getSingleton():setControlEnabled(true)
end

function CenteredFreecam:handleScroll(btn)
    if btn == "mouse_wheel_up" or btn == "mouse_wheel_down" then
        local z = self.m_ZoomData[1]
        local delta = getKeyState("lshift") and 5 or 1
        z = math.clamp(1, btn == "mouse_wheel_up" and z - delta or z + delta, self.m_MaxZoom)
        self.m_ZoomData[1] = z
    end
end

function CenteredFreecam:handleMouse(rx, ry, x, y)
    if isCursorShowing() then return end
    self.m_AngleZ = (self.m_AngleZ + ( x - screenWidth / 2 ) / 10 ) % 360
    self.m_AngleX = (self.m_AngleX + ( y - screenHeight / 2 ) / 10 ) % 360
    if ( self.m_AngleX > 180 ) then
        if ( self.m_AngleX < 315 ) then self.m_AngleX = 315 end
    else
        if ( self.m_AngleX > 45 ) then self.m_AngleX = 45 end
    end
end

function CenteredFreecam:render()
    local desiredZoom = self.m_ZoomData[2] < self.m_ZoomData[1] and self.m_ZoomData[2] or self.m_ZoomData[1]
    if desiredZoom ~= self.m_Zoom then
        self.m_Zoom = self.m_Zoom + (desiredZoom-self.m_Zoom)/10
    end
    local ex, ey, ez = self.m_Element.position.x, self.m_Element.position.y, self.m_Element.position.z
    local ox, oy, oz
	ox = ex - math.sin ( math.rad ( self.m_AngleZ ) ) * self.m_Zoom
	oy = ey - math.cos ( math.rad ( self.m_AngleZ ) ) * self.m_Zoom
    oz = ez + math.tan ( math.rad ( self.m_AngleX ) ) * self.m_Zoom

    setCameraMatrix ( ox, oy, oz, self.m_Element.position)
    if not self.m_NoClip then
        local hit, x, y, z = processLineOfSight(self.m_Element.position, ox, oy, oz, true, true, false, self.m_CheckObjectsOnClip, false, false, true, false, self.m_Element)
        if hit and getDistanceBetweenPoints3D(x, y, z, self.m_Element.position) < getDistanceBetweenPoints3D(ox, oy, oz, self.m_Element.position) then
            self.m_ZoomData[2] = getDistanceBetweenPoints3D(x, y, z, self.m_Element.position)
        else
            self.m_ZoomData[2] = self.m_MaxZoom
        end
    end
end

function CenteredFreecam.isEnabled()
    return CenteredFreecam:isInstantiated()
end

CenteredFreecam.start = function(...)
    if CenteredFreecam:isInstantiated() then
        delete(CenteredFreecam:getSingleton())
    end
    CenteredFreecam:getSingleton(...)
end
addEventHandler("startCenteredFreecam", root, CenteredFreecam.start)

CenteredFreecam.stop = function()
    if CenteredFreecam:isInstantiated() then
        delete(CenteredFreecam:getSingleton())
    end
end
addEventHandler("stopCenteredFreecam", root, CenteredFreecam.stop)
