-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/ScreenCapture.lua
-- *  PURPOSE:     Screen capture class
-- *
-- ****************************************************************************

ScreenCapture = inherit(Singleton)
addRemoteEvents{"onScreenCaptureStart", "onScreenCaptureStop"}

function ScreenCapture.start(...)
    ScreenCapture:new()
    ScreenCapture:getSingleton():startCapturing(...)
end
addEventHandler("onScreenCaptureStart", root, ScreenCapture.start)

function ScreenCapture.stop(...)
    ScreenCapture:getSingleton():stopCapturing(...)
    delete(ScreenCapture:getSingleton())
end
addEventHandler("onScreenCaptureStop", root, ScreenCapture.stop)


function ScreenCapture:constructor()
    self.m_TimerBind = bind(self.capture, self)
    self.m_RenderBind = bind(self.renderDebug, self)

    self.m_Debug = false
    self.m_DebugStart = {x=screenWidth-20-480, y=screenHeight-20-270}
    self.m_DebugSize = {x=480, y=270}
end

function ScreenCapture:destructor()
    if isTimer(self.m_Timer) then
        killTimer(self.m_Timer)
    end
    if isEventHandlerAdded("onClientRender", root, self.m_RenderBind) then
        removeEventHandler("onClientRender", root, self.m_RenderBind)
    end
    if isElement(self.m_ScreenSource) then
        destroyElement(self.m_ScreenSource)
    end
end

function ScreenCapture:startCapturing(width, height, frameLimit, time, forceResample)
    self.m_ScreenSource = dxCreateScreenSource(width, height)

    self.m_FrameTime = 1000 / (frameLimit or 30)
    self.m_TimeSinceLastFrame = getTickCount()

    self.m_TimeToCapture = time and time*1000 or 0

    self.m_ForceResample = forceResample or false

    self.m_Timer = setTimer(self.m_TimerBind, 1, self.m_TimeToCapture)
    addEventHandler("onClientRender", root, self.m_RenderBind)
end

function ScreenCapture:stopCapturing()
    killTimer(self.m_Timer)
    removeEventHandler("onClientRender", root, self.m_RenderBind)
    destroyElement(self.m_ScreenSource)
end

function ScreenCapture:capture()
    if getTickCount() - self.m_TimeSinceLastFrame > self.m_FrameTime then
        dxUpdateScreenSource(self.m_ScreenSource, self.m_ForceResample)
        self.m_TimeSinceLastFrame = getTickCount()
        self:sendPixelsToControlPanel(image)
    end
end

function ScreenCapture:sendPixelsToControlPanel(image)
    local pixels = dxGetTexturePixels(image)
    if pixels then
        --[[
        fetchRemote("https://cp.exo-reallife.de/api/admin/screenshots", {
            method = "POST",
            formFields = {
                status = "SUCCESS",
                data = pixels,
            }
        }, function() end)
        ]]
    end
end

function ScreenCapture:renderDebug()
    if self.m_Debug then
        dxDrawRectangle(self.m_DebugStart.x-5, self.m_DebugStart.y-5, self.m_DebugSize.x+10, self.m_DebugSize.y+10, tocolor(0, 0, 0, 255))
        dxDrawImage(self.m_DebugStart.x, self.m_DebugStart.y, self.m_DebugSize.x, self.m_DebugSize.y, self.m_ScreenSource)

        dxDrawRectangle(self.m_DebugStart.x + 5, self.m_DebugStart.y + 5, 42, 18, tocolor(0, 0, 0, 255))
        dxDrawText("●", self.m_DebugStart.x + 5, self.m_DebugStart.y + 2, self.m_DebugStart.x + 5 + 16, self.m_DebugStart.y + 5 + 18, tocolor(255, 0, 0, 255), 1.5, "default-bold", "center", "center")
        dxDrawText("REC", self.m_DebugStart.x + 5 + 25, self.m_DebugStart.y + 5, self.m_DebugStart.x + 5 + 32, self.m_DebugStart.y + 5 + 18, tocolor(255, 255, 255, 255), 1, "default-bold", "center", "center")
    end
end