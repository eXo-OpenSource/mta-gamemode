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
  self.m_Window:addBackButton(function () delete(self) SelfGUI:getSingleton():show() end)
  self.m_ShaderGridList = GUIGridList:new(self.m_Width*0.01, self.m_Height*0.07, self.m_Width*0.39, self.m_Height*0.8, self)
  self.m_ShaderGridList:addColumn(_"Name", 0.6)
  self.m_ShaderGridList:addColumn(_"Aktiv", 0.4)
  self:loadGridList()

  GUILabel:new(self.m_Width*0.45, self.m_Height*0.07, self.m_Width*0.55, self.m_Height*0.08, _"Shader", self.m_Window)
  GUILabel:new(self.m_Width*0.45, self.m_Height*0.15, self.m_Width*0.55, self.m_Height*0.05, _"Hier kannst du Shader aktivieren oder deaktivieren. Zu viele aktivierte Shader können sich möglicherweise auf die Performance auswirken.\nProbiere einfach ein wenig herum um die ideale Einstellung für dich zu finden.", self.m_Window):setMultiline(true)
  self.m_SelectedLabel = GUILabel:new(self.m_Width*0.45, self.m_Height*0.45, self.m_Width*0.35, self.m_Height*0.07, " ", self.m_Window):setVisible(false)
  self.m_SelectedButton = GUIButton:new(self.m_Width*0.45, self.m_Height*0.52, self.m_Width*0.35, self.m_Height*0.07, " ", self.m_Window):setBackgroundColor(Color.LightBlue):setFontSize(1.2):setVisible(false)
  self.m_SelectedButton.onLeftClick = function () self:toggleShader() end
end

function ShaderPanel:loadGridList()
    self.m_ShaderGridList:clear()
	local setting, state
    for name, key in pairs(SHADERS) do
        setting = core:get("Shaders", name) or false
		state = setting == false and "Nein" or "Ja"
        item = self.m_ShaderGridList:addItem(name, state)
        item.index = name
        item.onLeftClick = function() self:onShaderSelect(name) end
    end
end

function ShaderPanel:onShaderSelect(name)
    local setting = core:get("Shaders", name) or false

	self.m_SelectedLabel:setVisible(true)
    self.m_SelectedButton:setVisible(true)
    self.m_SelectedLabel:setText(name)
    self.m_SelectedButton:setText(setting == false and "Aktivieren" or "Deaktivieren")
	self.m_SelectedShader = name
	self.m_SelectedActive = setting

end

function ShaderPanel:toggleShader()
	self.m_SelectedActive = not self.m_SelectedActive
	triggerEvent(SHADERS[self.m_SelectedShader]["event"], root, self.m_SelectedActive)
	core:set("Shaders", self.m_SelectedShader, self.m_SelectedActive)
    self.m_SelectedButton:setText(self.m_SelectedActive == false and "Aktivieren" or "Deaktivieren")
	self:loadGridList()
end

function ShaderPanel:onShow()
	SelfGUI:getSingleton():addWindow(self)
end

function ShaderPanel:onHide()
	SelfGUI:getSingleton():removeWindow(self)
end

Shaders = {}
function Shaders.load()
	local setting
	for name, key in pairs(SHADERS) do
        setting = core:get("Shaders", name) 
        if setting == nil then setting = key["enabled"] core:set("Shaders", name, key["enabled"]) end 
		triggerEvent(key["event"], root, setting)
	end
end
