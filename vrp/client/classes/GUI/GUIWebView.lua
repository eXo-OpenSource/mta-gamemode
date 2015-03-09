-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/GUIWebView.lua
-- *  PURPOSE:     GUI webview wrapper class (better integration)
-- *
-- ****************************************************************************
GUIWebView = inherit(GUIElement)

function GUIWebView:constructor(posX, posY, width, height, url, transparent, parent)
    GUIElement.constructor(self, posX, posY, width, height, parent)

    self.m_IsLocal = url:sub(0, 7) ~= "http://" and url:sub(0, 8) ~= "https://"
    self.m_Browser = Browser.create(width, height, self.m_IsLocal, transparent)

    self.m_CursorMoveFunc = bind(self.onCursorMove, self)
    self.m_UpdateFunc = bind(self.update, self)
    addEventHandler("onClientCursorMove", root, self.m_CursorMoveFunc)
    addEventHandler("onClientPreRender", root, self.m_UpdateFunc)
    addEventHandler("onClientBrowserCreated", self.m_Browser, function() source:loadURL(url) end)
end

function GUIWebView:destructor()
    removeEventHandler("onClientCursorMove", root, self.m_CursorMoveFunc)

    GUIElement.destructor(self)
end

function GUIWebView:drawThis()
    dxDrawImage(self.m_AbsoluteX, self.m_AbsoluteY, self.m_Width, self.m_Height, self.m_Browser)
end

function GUIWebView:update()
    -- Request redraw
    self:anyChange()
end

function GUIWebView:setVisible(state, ...)
    self.m_Browser:setRenderingPaused(not state)

    GUIElement.setVisible(state, ...)
end

function GUIWebView:onInternalLeftClick()
    self.m_Browser:focus()

    self.m_Browser:injectMouseDown("left")
end

function GUIWebView:onInternalRightClick()
    self.m_Browser:injectMouseUp("right")
end

function GUIWebView:onInternalMouseWheelDown()
    self.m_Browser:injectMouseWheel(20, 0)
end

function GUIWebView:onInternalMouseWheelUp()
    self.m_Browser:injectMouseWheel(-20, 0)
end

function GUIWebView:onCursorMove(relX, relY, absX, absY)
    if not isCursorShowing() then
        return
    end

    local x, y = absX - self.m_AbsoluteX, absY - self.m_AbsoluteY
    self.m_Browser:injectMouseMove(x, y)
end
