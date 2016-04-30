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
	self.m_ScoreboardTrigger = bind(self.scoreboardGUI, self)
	self.m_CustomMap = bind(self.customMap, self)
	self.m_WebPanel = bind(self.webPanel, self)
	self.m_Inventory = bind(self.inventory, self)

	self.m_Keys = {
	  ["KeyTogglePhone"]         = {["defaultKey"] = "u", ["name"] = "Handy", ["func"] = self.m_TogglePhone};
	  ["KeyTogglePolicePanel"]   = {["defaultKey"] = "F4", ["name"] = "Polizei Computer", ["func"] = self.m_PolicePanel};
	  ["KeyToggleSelfGUI"]       = {["defaultKey"] = "F2", ["name"] = "Self-Menü", ["func"] = self.m_SelfMenu};
	  ["KeyToggleHelpGUI"]       = {["defaultKey"] = "F1", ["name"] = "Hilfe-Menü", ["func"] = self.m_HelpMenu};
	  ["KeyToggleAnimationMenu"] = {["defaultKey"] = "F3", ["name"] = "Animations-Menü", ["func"] = self.m_AnimationMenu};
	  ["KeyToggleScoreboard"]    = {["defaultKey"] = "TAB", ["name"] = "Spielerliste", ["func"] = self.m_ScoreboardTrigger, ["trigger"] = "both"};
	  ["KeyToggleCustomMap"]     = {["defaultKey"] = "F11", ["name"] = "Karte", ["func"] = self.m_CustomMap};
	  ["KeyToggleWebPanel"]      = {["defaultKey"] = "F9", ["name"] = "Webpanel", ["func"] = self.m_WebPanel};
	  ["KeyToggleInventory"]     = {["defaultKey"] = "i", ["name"] = "Inventar", ["func"] = self.m_Inventory};
	}
	self:loadBinds()
end

function KeyBinds:loadBinds()
	for index, key in pairs(self.m_Keys) do
		bindKey(core:get("KeyBindings", index, key["defaultKey"]), key["trigger"] or "down", key["func"])
	end
end

function KeyBinds:unloadBinds()
	for index, key in pairs(self.m_Keys) do
		unbindKey(core:get("KeyBindings", index, key["defaultKey"]), key["trigger"] or "down", key["func"])
	end
end

function KeyBinds:changeKey(keyName, newKey)
	self:unloadBinds()
	core:set("KeyBindings", keyName, newKey)
	self:loadBinds()
end

function KeyBinds:getBindsList()
	return self.m_Keys
end

function KeyBinds:webPanel()
	WebPanel:getSingleton():toggle()
end

function KeyBinds:inventory()
	Inventory:getSingleton():toggle()
end

function KeyBinds:togglePhone()
	Phone:getSingleton():toggle()
end

function KeyBinds:customMap()
	CustomF11Map:getSingleton():toggle()
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
	elseif KeyBindings:getSingleton():isVisible() then
		KeyBindings:getSingleton():close()
	else
		SelfGUI:getSingleton():open()
	end
end

function KeyBinds:animationMenu()
	if not localPlayer:isInVehicle() then
		if not AnimationGUI:isInstantiated() then
			AnimationGUI:new()
		else
			delete(AnimationGUI:getSingleton())
		end
	end
end

function KeyBinds:policePanel()
	if not PolicePanel:isInstantiated() then
		if localPlayer:getFactionId() == 1 or localPlayer:getFactionId() == 2 or localPlayer:getFactionId() == 3 then
			if localPlayer:getPublicSync("Faction:Duty") == true then
				PolicePanel:new()
			else
				ErrorBox:new(_"Du bist nicht im Dienst!")
			end
		end
	else
		delete(PolicePanel:getSingleton())
	end
end

function KeyBinds:helpMenu()
	if not HelpGUI:isInstantiated() then
		HelpGUI:new()
	else
		delete(HelpGUI:getSingleton())
	end
end

function KeyBinds:scoreboardGUI()
	if not ScoreboardGUI:getSingleton():isVisible() then
		ScoreboardGUI:getSingleton():setVisible(true):bringToFront()
	else
		ScoreboardGUI:getSingleton():setVisible(false)
	end
end
