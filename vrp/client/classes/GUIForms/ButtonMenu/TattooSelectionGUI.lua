-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/TattooSelectionGUI.lua
-- *  PURPOSE:     TattooSelectionGUI
-- *
-- ****************************************************************************
TattooSelectionGUI = inherit(GUIButtonMenu)

TattooSelectionGUI.Values = {
	[4] = "Linker Oberarm",
	[5] = "Linker Unterarm",
	[6] = "Rechter Oberarm",
	[7] = "Rechter Unterarm",
	[8] = "Rücken",
	[9] = "Linke Brust",
	[10] = "Rechte Brust",
	[11] = "Bauch",
	[12] = "Unterer Rücken"
}

inherit(Singleton, TattooSelectionGUI)

addRemoteEvents{"showTattooSelectionGUI"}

function TattooSelectionGUI:constructor(shopId)
	GUIButtonMenu.constructor(self, _("Tattoo-Auswahl"), 300, 450)

	self.m_ShopId = shopId

	self:addItems()

	-- Events
	--addEventHandler("updateTattooSelectionGUI", root, bind(self.Event_updateTattooSelectionGUI, self))
	addEventHandler("shopCloseManageGUI", root, bind(self.Event_close, self))
end

function TattooSelectionGUI:addItems()
	for id, name in pairs(TattooSelectionGUI.Values) do
		self:addItem(name, Color.Accent, bind(self.itemCallback, self, id))
	end
end

function TattooSelectionGUI:itemCallback(type)
	triggerServerEvent("shopOnTattooSelection", root, self.m_ShopId, type)
	delete(self)
end

function TattooSelectionGUI:Event_close()
	if self.m_StreamGUI then
		delete(self.m_StreamGUI)
	end
	delete(self)
end

addEventHandler("showTattooSelectionGUI", root,
		function(shopId)
			if TattooSelectionGUI:isInstantiated() then
				delete(TattooSelectionGUI:getSingleton())
			end
			TattooSelectionGUI:new(shopId)
		end
	)
