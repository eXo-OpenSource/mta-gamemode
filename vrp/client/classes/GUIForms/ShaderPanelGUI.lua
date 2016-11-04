-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/ShaderPanelGUI.lua
-- *  PURPOSE:     ShaderPanel GUI class
-- *
-- ****************************************************************************
ShaderPanel = inherit(GUIForm)
inherit(Singleton, ShaderPanel)

function ShaderPanel:constructor()
  GUIForm.constructor(self, screenWidth/2-300, screenHeight/2-230, 600, 460)

  self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Shader-Einstellungen", true, true, self)
  self.m_BackButton = GUILabel:new(self.m_Width-58, 0, 30, 28, "[←]", self):setFont(VRPFont(35))
  self.m_BackButton.onLeftClick = function() self:close() SelfGUI:getSingleton():show() Cursor:show() end
  self.m_ShaderGridList = GUIGridList:new(self.m_Width*0.01, self.m_Height*0.07, self.m_Width*0.39, self.m_Height*0.8, self)
  self.m_ShaderGridList:addColumn(_"Name", 0.6)
  self.m_ShaderGridList:addColumn(_"Aktiv", 0.4)
  self:loadGridList()

  GUILabel:new(self.m_Width*0.45, self.m_Height*0.07, self.m_Width*0.55, self.m_Height*0.08, _"Shader", self.m_Window)
  GUILabel:new(self.m_Width*0.45, self.m_Height*0.15, self.m_Width*0.55, self.m_Height*0.05, _"Hier kannst du Shader aktivieren oder deaktivieren. Zuviele aktivierte Shader können sich möglicherweise auf die Performance auswirken.\nProbiere einfach ein wenig herum um die ideale Einstellung für dich zu finden.", self.m_Window):setMultiline(true)
  self.m_SelectedLabel = GUILabel:new(self.m_Width*0.45, self.m_Height*0.35, self.m_Width*0.35, self.m_Height*0.07, " ", self.m_Window):setVisible(false)
  self.m_SelectedButton = GUIButton:new(self.m_Width*0.45, self.m_Height*0.42, self.m_Width*0.35, self.m_Height*0.07, " ", self.m_Window):setBackgroundColor(Color.LightBlue):setFontSize(1.2):setVisible(false)
  self.m_SelectedButton.onLeftClick = function () self:toggleShader() end
end

function ShaderPanel:loadGridList()
    self.m_ShaderGridList:clear()
	local setting, state
    for name, key in pairs(SHADERS) do
        setting = core:get("Shaders", name) or 0
		state = setting == 0 and "Nein" or "Ja"
        item = self.m_ShaderGridList:addItem(name, state)
        item.index = name
        item.onLeftClick = function() self:onShaderSelect(name, setting) end
    end
end

function ShaderPanel:onShaderSelect(name, setting)
    self.m_SelectedLabel:setVisible(true)
    self.m_SelectedButton:setVisible(true)
    self.m_SelectedLabel:setText(name)
    self.m_SelectedButton:setText(setting == 0 and "Aktivieren" or "Deaktivieren")
end

function ShaderPanel:toggleShader()
	outputChatBox("Todo")
end
