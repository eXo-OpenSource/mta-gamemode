-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/DialogGUI.lua
-- *  PURPOSE:     Simple dialog GUI class
-- *
-- ****************************************************************************
DialogGUI = inherit(GUIForm)
inherit(Singleton, DialogGUI)

function DialogGUI:constructor(callback, ...)
    GUIForm.constructor(self, 0, screenHeight-275, screenWidth, 275, false)
    self.m_StringTable = {...}
    self.m_CallBack = callback

    self.m_Rectangle = GUIRectangle:new(0, self.m_Height, self.m_Width, self.m_Height, Color.Black, self)
    self.m_Text = GUILabel:new(0, 100, self.m_Width, self.m_Height-200, "", self):setAlignX("center")

    Animation.Move:new(self.m_Rectangle, 1000, 0, 0)
    setTimer(bind(self.fillLabel, self, self.m_StringTable[1]), 1000, 1)
end

function DialogGUI:destructor()
	GUIForm.destructor(self)
end

function DialogGUI:fillLabel(text)
    local length = #text
    local int = 0
    if not self.m_Bind then
        self:bind("space", bind(self.nextText, self))
        self.m_Bind = true
    end
    self.m_WriteTimer = setTimer(
        function()
            int = int + 1
            self.m_Text:setText(string.sub(text, 1, int))
        end
    , 20, #text)
end

function DialogGUI:nextText()
    if not isTimer(self.m_WriteTimer) then
        if self.m_LastText then
            self:endDialog()
            return
        end

        if #self.m_StringTable > 1 then
            table.remove(self.m_StringTable, 1)
            self:fillLabel(self.m_StringTable[1])
        else
            self:endDialog()
        end
    end
end

function DialogGUI:endDialog()
    self:unbind("space")
    delete(self.m_Text)
    Animation.Move:new(self.m_Rectangle, 1000, 0, self.m_Height)
    setTimer(
        function() 
            delete(self)
            if self.m_CallBack then
                self.m_CallBack()
            end
        end
    , 1000, 1)
end