-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/KeyBindManager.lua
-- *  PURPOSE:     KeyBindings Mangager class
-- *
-- ****************************************************************************
KeyBinds = inherit(Singleton)

function KeyBinds:constructor()
	self.m_TogglePhone = bind(self.togglePhone, self)
	self.m_HelpMenu = bind(self.helpMenu, self)
	self.m_AnimationMenu = bind(self.animationMenu, self)
	self.m_PolicePanel = bind(self.policePanel, self)
	self.m_SelfMenu = bind(self.selfMenu, self)

	self.m_Keys = {
	  ["KeyTogglePhone"]  = 	{["defaultKey"] = "u", 	["name"] = "Handy", ["func"] = self.m_TogglePhone};
	  ["KeyTogglePolicePanel"]= {["defaultKey"] = "F4", ["name"] = "Polizei Computer", ["func"] = self.m_PolicePanel};
	  ["KeyToggleSelfGUI"]    = {["defaultKey"] = "F2", ["name"] = "Self-Menü", ["func"] = self.m_SelfMenu};
	  ["KeyToggleHelpGUI"]    = {["defaultKey"] = "F9", ["name"] = "Hilfe-Menü", ["func"] = self.m_HelpMenu};
	  ["KeyToggleAnimationMenu"] = {["defaultKey"] = "l", ["name"] = "Hilfe-Menü", ["func"] = self.m_AnimationMenu};
	}
	self:loadBinds()
end

function KeyBinds:loadBinds()
	for index, key in pairs(self.m_Keys) do
		bindKey(core:get("KeyBindings", index, key["defaultKey"]), "down", key["func"])
	end
end

function KeyBinds:reloadBinds()
	for index, key in pairs(self.m_Keys) do
		unbindKey(core:get("KeyBindings", index, key["defaultKey"]), "down", key["func"])
	end
	self:loadBinds()
end

function KeyBinds:changeKey(keyName, newKey)
	 core:set("KeyBindings", keyName, newKey)
	 self:reloadBinds()
end

function KeyBinds:getBindsList()
	return self.m_Keys
end

function KeyBinds:togglePhone()
	Phone:getSingleton():toggle()
end

function KeyBinds:selfMenu()
	if SelfGUI:getSingleton():isVisible() then
		SelfGUI:getSingleton():close()
	elseif CompanyGUI:getSingleton():isVisible() then
		CompanyGUI:getSingleton():close()
	elseif FactionGUI:getSingleton():isVisible() then
		FactionGUI:getSingleton():close()
	elseif GroupGUI:getSingleton():isVisible() then
		GroupGUI:getSingleton():close()
	elseif TicketGUI:getSingleton():isVisible() then
		TicketGUI:getSingleton():close()
	elseif AdminGUI:getSingleton():isVisible() then
		AdminGUI:getSingleton():close()
	elseif MigratorPanel:getSingleton():isVisible() then
		MigratorPanel:getSingleton():close()
	else
		SelfGUI:getSingleton():open()
	end
end

function KeyBinds:animationMenu()
	if not localPlayer:isInVehicle() then
		if AnimationGUI:isInstantiated() then
			delete(AnimationGUI:getSingleton())
		else
			AnimationGUI:new()
		end
	end
end

function KeyBinds:policePanel()
	if localPlayer:getFactionId() == 1 or localPlayer:getFactionId() == 2 or localPlayer:getFactionId() == 3 and localPlayer:getPublicSync("Faction:Duty") then
		if PolicePanel:isInstantiated() then
			delete(PolicePanel:getSingleton())
		else
			PolicePanel:new()
		end
	end
end

function KeyBinds:helpMenu()
	if not HelpGUI:isInstantiated() then
		HelpGUI:new()
	else
		delete(HelpGUI:getSingleton())
	end
end
