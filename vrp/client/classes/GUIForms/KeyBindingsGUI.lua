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
    ["KeyTogglePhone"]       = {["key"] = core:get("KeyBindings", "KeyTogglePhone") or "U", ["name"] = _"Handy"};
    ["KeyTogglePolicePanel"] = {["key"] = core:get("KeyBindings", "KeyTogglePolicePanel") or "F4", ["name"] = _"Polizei Panel"};
    ["KeyToggleSelfGUI"]     = {["key"] = core:get("KeyBindings", "KeyToggleSelfGUI") or "F2", ["name"] = _"Self-Menü"};
    ["KeyToggleScoreboard"]  = {["key"] = core:get("KeyBindings", "KeyToggleScoreboard") or "Tab", ["name"] = _"Spielerliste"};
    ["KeyToggleInventory"]   = {["key"] = core:get("KeyBindings", "KeyToggleInventory") or "I", ["name"] = _"Inventar"};
    ["KeyToggleCustomMap"]   = {["key"] = core:get("KeyBindings", "KeyToggleCustomMap") or "F11", ["name"] = _"Mapübersicht"};
  }

  GUIForm.constructor(self, screenWidth/2-300, screenHeight/2-230, 600, 460)
  self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Tastenzuordnungen ändern", true, true, self)

  self.m_BackButton = GUILabel:new(self.m_Width-58, 0, 30, 28, "[←]", self):setFont(VRPFont(35))
  self.m_BackButton.onLeftClick = function() self:close() SelfGUI:getSingleton():show() Cursor:show() end

  self.m_KeyGridList = GUIGridList:new(self.m_Width*0.01, self.m_Height*0.07, self.m_Width*0.35, self.m_Height*0.8, self)
  self.m_KeyGridList:addColumn(_"Name", 0.6)
  self.m_KeyGridList:addColumn(_"Taste", 0.4)
  for index, key in pairs(self.ms_Keys ) do
      item = self.m_KeyGridList:addItem(key.name, key.key:upper())
      item.index = index
      item.onLeftClick = function() self:onKeySelect(index) end
  end
  GUILabel:new(self.m_Width*0.4, self.m_Height*0.07, self.m_Width*0.6, self.m_Height*0.08, _"Tastenzuordnungen", self.m_Window)
  GUILabel:new(self.m_Width*0.4, self.m_Height*0.15, self.m_Width*0.6, self.m_Height*0.05, _"Hier kannst du deine Tastenzuordnungen ändern. Klicke einfach die gewünschte Funktion links an.\nMit Klick auf den blauen Button kannst du die Zuordnung ändern.", self.m_Window):setMultiline(true)
  self.m_SelectedLabel = GUILabel:new(self.m_Width*0.4, self.m_Height*0.35, self.m_Width*0.32, self.m_Height*0.07, self.ms_Keys["KeyToggleCustomMap"].name, self.m_Window):setVisible(false)
  self.m_SelectedButton = GUIButton:new(self.m_Width*0.4, self.m_Height*0.42, self.m_Width*0.32, self.m_Height*0.07, self.ms_Keys["KeyToggleCustomMap"].key:upper(), self.m_Window):setBackgroundColor(Color.LightBlue):setFontSize(1.2):setVisible(false)
  self.m_SelectedButton.onLeftClick = function () self:waitForKey() end

  self.m_onKeyBind = bind(self.onKeyPressed, self)
end

function KeyBindings:onKeySelect(key)
    self.m_SelectedLabel:setVisible(true)
    self.m_SelectedButton:setVisible(true)
    self.m_SelectedLabel:setText(self.ms_Keys[key].name)
    self.m_SelectedButton:setText(self.ms_Keys[key].key)
end

function KeyBindings:waitForKey ()
    self.m_SelectedButton:setText("...")
    addEventHandler("onClientKey", root, self.m_onKeyBind)
end

function KeyBindings:onKeyPressed(key, press)
    if press == false then
        local item = self.m_KeyGridList:getSelectedItem()
        self:changeKey(item.index, key)
        removeEventHandler("onClientKey", root, self.m_onKeyBind)
    end
end

function KeyBindings:changeKey (keyName, newKey)
  if newKey == "" or newKey == " " then return end
  if not self.ms_Keys[keyName] then return end

  self.ms_Keys[keyName].key = newKey
  self.m_SelectedButton:setText(newKey:upper())
  core:set("KeyBindings", keyName, newKey)

  -- Todo: for bindings updates without a reconnect, we need a bindins class
end
