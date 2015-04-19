-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/KeyBindingsGUI.lua
-- *  PURPOSE:     KeyBindings GUI class
-- *
-- ****************************************************************************
KeyBindings = inherit(GUIForm)
inherit(Singleton, KeyBindings)

KeyBindings.ms_ValidKeys = {["a"] = true; ["b"] = true; ["c"] = true; ["d"] = true; ["e"] = true;}

function KeyBindings:constructor ()
  self.ms_Keys = {
    ["KeyTogglePhone"]       = {["key"] = core:get("KeyBindings", "KeyTogglePhone"), ["name"] = _"Handy"};
    ["KeyTogglePolicePanel"] = {["key"] = core:get("KeyBindings", "KeyTogglePolicePanel"), ["name"] = _"Polizei Panel"};
    ["KeyToggleSelfGUI"]     = {["key"] = core:get("KeyBindings", "KeyToggleSelfGUI"), ["name"] = _"Self-Menü"};
    ["KeyToggleScoreboard"]  = {["key"] = core:get("KeyBindings", "KeyToggleScoreboard"), ["name"] = _"Spielerliste"};
    ["KeyToggleInventory"]   = {["key"] = core:get("KeyBindings", "KeyToggleInventory"), ["name"] = _"Inventar"};
    ["KeyToggleCustomMap"]   = {["key"] = core:get("KeyBindings", "KeyToggleCustomMap"), ["name"] = _"Mapübersicht"};
  }

  GUIForm.constructor(self, screenWidth/2-300, screenHeight/2-230, 600, 460)
  self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Tastenzuordnungen ändern", true, true, self)

  -- Reihe 1
  GUILabel:new(self.m_Width*0.01, self.m_Height*0.07, self.m_Width*0.31, self.m_Height*0.07, self.ms_Keys["KeyTogglePhone"].name, self.m_Window)
  self.ms_Keys["KeyTogglePhone"].button = GUIButton:new(self.m_Width*0.01, self.m_Height*0.14, self.m_Width*0.31, self.m_Height*0.07, self.ms_Keys["KeyTogglePhone"].key:upper(), self.m_Window):setBackgroundColor(Color.LightBlue):setFontSize(1.2)
  self.ms_Keys["KeyTogglePhone"].button.onLeftClick = function () outputDebug("Change KeyTogglePhone") end

  GUILabel:new(self.m_Width*0.01, self.m_Height*0.25, self.m_Width*0.31, self.m_Height*0.07, self.ms_Keys["KeyTogglePolicePanel"].name, self.m_Window)
  self.ms_Keys["KeyTogglePolicePanel"].button = GUIButton:new(self.m_Width*0.01, self.m_Height*0.32, self.m_Width*0.31, self.m_Height*0.07, self.ms_Keys["KeyTogglePolicePanel"].key:upper(), self.m_Window):setBackgroundColor(Color.LightBlue):setFontSize(1.2)
  self.ms_Keys["KeyTogglePolicePanel"].button.onLeftClick = function () outputDebug("Change KeyTogglePolicePanel") end

  GUILabel:new(self.m_Width*0.01, self.m_Height*0.43, self.m_Width*0.31, self.m_Height*0.07, self.ms_Keys["KeyToggleSelfGUI"].name, self.m_Window)
  self.ms_Keys["KeyToggleSelfGUI"].button = GUIButton:new(self.m_Width*0.01, self.m_Height*0.5, self.m_Width*0.31, self.m_Height*0.07, self.ms_Keys["KeyToggleSelfGUI"].key:upper(), self.m_Window):setBackgroundColor(Color.LightBlue):setFontSize(1.2)
  self.ms_Keys["KeyToggleSelfGUI"].button.onLeftClick = function () outputDebug("Change KeyToggleSelfGUI") end

  GUILabel:new(self.m_Width*0.01, self.m_Height*0.61, self.m_Width*0.31, self.m_Height*0.07, self.ms_Keys["KeyToggleScoreboard"].name, self.m_Window)
  self.ms_Keys["KeyToggleScoreboard"].button = GUIButton:new(self.m_Width*0.01, self.m_Height*0.68, self.m_Width*0.31, self.m_Height*0.07, self.ms_Keys["KeyToggleScoreboard"].key:upper(), self.m_Window):setBackgroundColor(Color.LightBlue):setFontSize(1.2)
  self.ms_Keys["KeyToggleScoreboard"].button.onLeftClick = function () outputDebug("Change KeyToggleScoreboard") end

  GUILabel:new(self.m_Width*0.01, self.m_Height*0.79, self.m_Width*0.31, self.m_Height*0.07, self.ms_Keys["KeyToggleInventory"].name, self.m_Window)
  self.ms_Keys["KeyToggleInventory"].button = GUIButton:new(self.m_Width*0.01, self.m_Height*0.86, self.m_Width*0.31, self.m_Height*0.07, self.ms_Keys["KeyToggleInventory"].key:upper(), self.m_Window):setBackgroundColor(Color.LightBlue):setFontSize(1.2)
  self.ms_Keys["KeyToggleInventory"].button.onLeftClick = function () outputDebug("Change KeyToggleInventory") end

  -- Reihe 2
  GUILabel:new(self.m_Width*0.34, self.m_Height*0.07, self.m_Width*0.32, self.m_Height*0.07, self.ms_Keys["KeyToggleCustomMap"].name, self.m_Window)
  self.ms_Keys["KeyToggleCustomMap"].button = GUIButton:new(self.m_Width*0.34, self.m_Height*0.14, self.m_Width*0.32, self.m_Height*0.07, self.ms_Keys["KeyToggleCustomMap"].key:upper(), self.m_Window):setBackgroundColor(Color.LightBlue):setFontSize(1.2)
  self.ms_Keys["KeyToggleCustomMap"].button.onLeftClick = function () outputDebug("Change KeyToggleCustomMap") end

  GUILabel:new(self.m_Width*0.34, self.m_Height*0.25, self.m_Width*0.32, self.m_Height*0.07, self.ms_Keys["KeyToggleCustomMap"].name, self.m_Window)
  self.ms_Keys["KeyToggleCustomMap"].button = GUIButton:new(self.m_Width*0.34, self.m_Height*0.32, self.m_Width*0.32, self.m_Height*0.07, self.ms_Keys["KeyToggleCustomMap"].key:upper(), self.m_Window):setBackgroundColor(Color.LightBlue):setFontSize(1.2)
  self.ms_Keys["KeyToggleCustomMap"].button.onLeftClick = function () outputDebug("Change KeyToggleCustomMap") end

  GUILabel:new(self.m_Width*0.34, self.m_Height*0.43, self.m_Width*0.32, self.m_Height*0.07, self.ms_Keys["KeyToggleCustomMap"].name, self.m_Window)
  self.ms_Keys["KeyToggleCustomMap"].button = GUIButton:new(self.m_Width*0.34, self.m_Height*0.5, self.m_Width*0.32, self.m_Height*0.07, self.ms_Keys["KeyToggleCustomMap"].key:upper(), self.m_Window):setBackgroundColor(Color.LightBlue):setFontSize(1.2)
  self.ms_Keys["KeyToggleCustomMap"].button.onLeftClick = function () outputDebug("Change KeyToggleCustomMap") end

  GUILabel:new(self.m_Width*0.34, self.m_Height*0.61, self.m_Width*0.32, self.m_Height*0.07, self.ms_Keys["KeyToggleCustomMap"].name, self.m_Window)
  self.ms_Keys["KeyToggleCustomMap"].button = GUIButton:new(self.m_Width*0.34, self.m_Height*0.68, self.m_Width*0.32, self.m_Height*0.07, self.ms_Keys["KeyToggleCustomMap"].key:upper(), self.m_Window):setBackgroundColor(Color.LightBlue):setFontSize(1.2)
  self.ms_Keys["KeyToggleCustomMap"].button.onLeftClick = function () outputDebug("Change KeyToggleCustomMap") end

  GUILabel:new(self.m_Width*0.34, self.m_Height*0.79, self.m_Width*0.32, self.m_Height*0.07, self.ms_Keys["KeyToggleCustomMap"].name, self.m_Window)
  self.ms_Keys["KeyToggleCustomMap"].button = GUIButton:new(self.m_Width*0.34, self.m_Height*0.86, self.m_Width*0.32, self.m_Height*0.07, self.ms_Keys["KeyToggleCustomMap"].key:upper(), self.m_Window):setBackgroundColor(Color.LightBlue):setFontSize(1.2)
  self.ms_Keys["KeyToggleCustomMap"].button.onLeftClick = function () outputDebug("Change KeyToggleCustomMap") end

  -- Reihe 3
  GUILabel:new(self.m_Width*0.68, self.m_Height*0.07, self.m_Width*0.31, self.m_Height*0.07, self.ms_Keys["KeyToggleCustomMap"].name, self.m_Window)
  self.ms_Keys["KeyToggleCustomMap"].button = GUIButton:new(self.m_Width*0.68, self.m_Height*0.14, self.m_Width*0.31, self.m_Height*0.07, self.ms_Keys["KeyToggleCustomMap"].key:upper(), self.m_Window):setBackgroundColor(Color.LightBlue):setFontSize(1.2)
  self.ms_Keys["KeyToggleCustomMap"].button.onLeftClick = function () outputDebug("Change KeyToggleCustomMap") end

  GUILabel:new(self.m_Width*0.68, self.m_Height*0.25, self.m_Width*0.31, self.m_Height*0.07, self.ms_Keys["KeyToggleCustomMap"].name, self.m_Window)
  self.ms_Keys["KeyToggleCustomMap"].button = GUIButton:new(self.m_Width*0.68, self.m_Height*0.32, self.m_Width*0.31, self.m_Height*0.07, self.ms_Keys["KeyToggleCustomMap"].key:upper(), self.m_Window):setBackgroundColor(Color.LightBlue):setFontSize(1.2)
  self.ms_Keys["KeyToggleCustomMap"].button.onLeftClick = function () outputDebug("Change KeyToggleCustomMap") end

  GUILabel:new(self.m_Width*0.68, self.m_Height*0.43, self.m_Width*0.31, self.m_Height*0.07, self.ms_Keys["KeyToggleCustomMap"].name, self.m_Window)
  self.ms_Keys["KeyToggleCustomMap"].button = GUIButton:new(self.m_Width*0.68, self.m_Height*0.5, self.m_Width*0.31, self.m_Height*0.07, self.ms_Keys["KeyToggleCustomMap"].key:upper(), self.m_Window):setBackgroundColor(Color.LightBlue):setFontSize(1.2)
  self.ms_Keys["KeyToggleCustomMap"].button.onLeftClick = function () outputDebug("Change KeyToggleCustomMap") end

  GUILabel:new(self.m_Width*0.68, self.m_Height*0.61, self.m_Width*0.31, self.m_Height*0.07, self.ms_Keys["KeyToggleCustomMap"].name, self.m_Window)
  self.ms_Keys["KeyToggleCustomMap"].button = GUIButton:new(self.m_Width*0.68, self.m_Height*0.68, self.m_Width*0.31, self.m_Height*0.07, self.ms_Keys["KeyToggleCustomMap"].key:upper(), self.m_Window):setBackgroundColor(Color.LightBlue):setFontSize(1.2)
  self.ms_Keys["KeyToggleCustomMap"].button.onLeftClick = function () outputDebug("Change KeyToggleCustomMap") end

  GUILabel:new(self.m_Width*0.68, self.m_Height*0.79, self.m_Width*0.31, self.m_Height*0.07, self.ms_Keys["KeyToggleCustomMap"].name, self.m_Window)
  self.ms_Keys["KeyToggleCustomMap"].button = GUIButton:new(self.m_Width*0.68, self.m_Height*0.86, self.m_Width*0.31, self.m_Height*0.07, self.ms_Keys["KeyToggleCustomMap"].key:upper(), self.m_Window):setBackgroundColor(Color.LightBlue):setFontSize(1.2)
  self.ms_Keys["KeyToggleCustomMap"].button.onLeftClick = function () outputDebug("Change KeyToggleCustomMap") end
end

function KeyBindings:changeKey (keyName, newKey)
  if newKey == "" or newKey == " " then return end
  if not self.m_Keys[keyName] then return end
  --if not self.ms_ValidKeys[newKey] then return end

  self.m_Keys[keyName].key = newKey
  self.m_Keys[keyName].button:setText(newKey:upper())
  core:set("KeyBindings", keyName, newKey)
  -- Todo: for bindings updates without a reconnect, we need a bindins class
end
