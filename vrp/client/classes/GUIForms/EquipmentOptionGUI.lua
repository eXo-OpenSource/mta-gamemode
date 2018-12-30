-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/EquipmentOptionGUI.lua
-- *  PURPOSE:     EquipmentOptionGUI GUI
-- *
-- ****************************************************************************
addRemoteEvents{"onRefreshEquipmentOption"}
EquipmentOptionGUI = inherit(GUIForm)
inherit(Singleton, EquipmentOptionGUI)

function EquipmentOptionGUI:constructor()
	GUIWindow.updateGrid()			-- initialise the grid function to use a window
	self.m_Width = grid("x", 14) 	-- width of the window
	self.m_Height = grid("y", 8) 	-- height of the window

	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Equipment-Rechte", true, true, self)
	
	GUIGridLabel:new(1, 1, 14, 1, "Stelle und sehe hier die Rechte für die Ausrüstungskiste ein.", self.m_Window)
	self.m_Scroll = GUIGridScrollableArea:new(1, 2, 12, 4, 12, 12, true, false, self.m_Window, 2)
	self.m_Items = {}
	self.m_LastUpdate = getTickCount()
	self.m_Labels = {}
	self.m_UpdateButton = GUIGridIconButton:new(12, 7, FontAwesomeSymbols.Save, self.m_Window):setBarEnabled(false):setBackgroundColor(Color.Green)
	self.m_UpdateButton.onLeftClick = bind(self.post, self)
	self.m_ResetButton = GUIGridIconButton:new(13, 7, FontAwesomeSymbols.Erase, self.m_Window):setBarEnabled(false):setBackgroundColor(Color.Orange)
	self.m_ResetButton.onLeftClick = function() 
		if self.m_LastUpdate+1000 < getTickCount() then 
			self.m_LastUpdate = getTickCount()
			triggerServerEvent("factionEquipmentOptionRequest", localPlayer) 
		end
	end
	triggerServerEvent("factionEquipmentOptionRequest", localPlayer)
end

function EquipmentOptionGUI:fill()
	local count = 0
	for item, rank in pairs(self.m_Permission) do 
		if item ~= "metadata" then
			self.m_Labels[item] = GUIGridLabel:new(1, count, 7, 1, item, self.m_Scroll):setBackgroundColor(Color.Black):setColor(Color.White):setAlignX("center")
			self.m_Items[item] = GUIGridChanger:new(8, count, 4, 1, self.m_Scroll)
			self.m_Items[item]:addItem("Jeder")
			for rank = 1, 6 do 
				self.m_Items[item]:addItem(("Rang %s"):format(rank))
			end
			if rank > 0 then
				self.m_Items[item]:setIndex(rank+1)
			end
			self.m_Items[item].onChange = function(rank, index) self:Event_onChangeItemRank(rank, index, item) end
			
			count = count + 1
		end
	end
	self.m_Scroll:resize(12, count)
	self.m_DateLabel = GUIGridLabel:new(1, 7, 11, 1, ("Zuletzt: von %s am %s"):format(self.m_Permission["metadata"][1], self.m_Permission["metadata"][2]), self.m_Window)
end

function EquipmentOptionGUI:Event_onChangeItemRank(rank, index, item)
	self.m_Changes[item] = index
end

function EquipmentOptionGUI:post()
	triggerServerEvent("factionEquipmentOptionSubmit", localPlayer, self.m_Changes)
end


function EquipmentOptionGUI:destructor()
	GUIForm.destructor(self)
end

function EquipmentOptionGUI:refresh( permissions ) 
	if permissions then 
		for item, changer in pairs(self.m_Items) do 
			changer:delete()
			if self.m_Labels[item] then 
				self.m_Labels[item]:delete()
			end
		end
		if self.m_DateLabel then 
			self.m_DateLabel:delete()
			self.m_DateLabel = nil
		end
		self.m_Changes = {}
		self.m_Scroll:clear()
		self.m_Permission = permissions
		self:fill()	
    end
end

function EquipmentOptionGUI:addBackButton(callBack)
	if self.m_Window then
		self.m_Window:addBackButton(function () callBack() delete(self) end)
	end
end

addEventHandler("onRefreshEquipmentOption", root, function(...)
	EquipmentOptionGUI:getSingleton():refresh(...)
end)
