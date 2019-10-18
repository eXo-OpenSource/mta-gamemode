-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Utils/CenteredBonecam.lua
-- *  PURPOSE:     Class for CenteredBonecam
-- *
-- ****************************************************************************
CenteredBonecam = inherit(Singleton)
addRemoteEvents{"startCenteredBonecam", "stopCenteredBonecam"}

function CenteredBonecam:constructor(maxZoom, noClip, boneId)
    self.m_RenderEvent = bind(CenteredBonecam.render, self)
    self.m_MouseEvent = bind(CenteredBonecam.handleMouse, self)
    self.m_ScrollEvent = bind(CenteredBonecam.handleScroll, self)
    self.m_AngleX = 0
    local x1, y1, z1, x2, y2, z2 = getCameraMatrix()
    self.m_AngleZ = -findRotation(x1, y1, x2, y2) -- -localPlayer.rotation.z
    self.m_BoneId = boneId
    self.m_MaxZoom = (maxZoom or 50)
    self.m_Zoom = 1
    self.m_NoClip = noClip
    self.m_CheckObjectsOnClip = false
    self.m_ZoomData = {self.m_MaxZoom * 0.5, self.m_MaxZoom}
    addEventHandler("onClientRender", root, self.m_RenderEvent)
    addEventHandler("onClientCursorMove", root, self.m_MouseEvent)
    --addEventHandler("onClientKey", root, self.m_ScrollEvent)
    RadioGUI:getSingleton():setControlEnabled(false)
end

function CenteredBonecam:destructor()
	setCameraTarget(localPlayer)
	removeEventHandler("onClientRender", root, self.m_RenderEvent)
	removeEventHandler("onClientCursorMove", root, self.m_MouseEvent)
	--removeEventHandler("onClientKey", root, self.m_ScrollEvent)
	RadioGUI:getSingleton():setControlEnabled(true)
end

function CenteredBonecam:handleScroll(btn)
    if btn == "mouse_wheel_up" or btn == "mouse_wheel_down" then
        local z = self.m_ZoomData[1]
        local delta = getKeyState("lshift") and 5 or 1
        z = math.clamp(1, btn == "mouse_wheel_up" and z - delta or z + delta, self.m_MaxZoom)
        self.m_ZoomData[1] = z
    end
end

function CenteredBonecam:handleMouse(rx, ry, x, y)
    if isCursorShowing() then return end
    self.m_AngleZ = (self.m_AngleZ + ( x - screenWidth / 2 ) / 10 ) % 360
    self.m_AngleX = (self.m_AngleX + ( y - screenHeight / 2 ) / 10 ) % 360
    if ( self.m_AngleX > 180 ) then
        if ( self.m_AngleX < 315 ) then self.m_AngleX = 315 end
    else
        if ( self.m_AngleX > 45 ) then self.m_AngleX = 45 end
    end
end

function CenteredBonecam:render()
    local desiredZoom = self.m_ZoomData[2] < self.m_ZoomData[1] and self.m_ZoomData[2] or self.m_ZoomData[1]
    if desiredZoom ~= self.m_Zoom then
        self.m_Zoom = self.m_Zoom + (desiredZoom-self.m_Zoom)/10
    end
    local ex, ey, ez = getPedBonePosition(localPlayer, self.m_BoneId)
    local ox, oy, oz
	ox = ex - math.sin ( math.rad ( self.m_AngleZ ) ) * self.m_Zoom
	oy = ey - math.cos ( math.rad ( self.m_AngleZ ) ) * self.m_Zoom
    oz = ez + math.tan ( math.rad ( self.m_AngleX ) ) * self.m_Zoom

    setCameraMatrix ( ox, oy, oz, ex, ey, ez)
    setElementRotation(localPlayer, 0, 0, -self.m_AngleZ)
    if not self.m_NoClip then
        local hit, x, y, z = processLineOfSight(ex, ey, ez, ox, oy, oz, true, true, false, self.m_CheckObjectsOnClip, false, false, true, false, localPlayer)
        if hit and getDistanceBetweenPoints3D(x, y, z, ex, ey, ez) < getDistanceBetweenPoints3D(ox, oy, oz, ex, ey, ez) then
            self.m_ZoomData[2] = getDistanceBetweenPoints3D(x, y, z, ex, ey, ez)
        else
            self.m_ZoomData[2] = self.m_MaxZoom
        end
    end
end

function CenteredBonecam.isEnabled()
    return CenteredBonecam:isInstantiated()
end

CenteredBonecam.start = function(...)
    if CenteredBonecam:isInstantiated() then
        delete(CenteredBonecam:getSingleton())
    end
    CenteredBonecam:getSingleton(...)
end
addEventHandler("startCenteredBonecam", root, CenteredBonecam.start)

CenteredBonecam.stop = function()
    if CenteredBonecam:isInstantiated() then
        delete(CenteredBonecam:getSingleton())
    end
end
addEventHandler("stopCenteredBonecam", root, CenteredBonecam.stop)