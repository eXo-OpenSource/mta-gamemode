-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/SkinSelectGUI.lua
-- *  PURPOSE:     GUI label class
-- *
-- ****************************************************************************
SkinSelectGUI = inherit(GUIForm)
inherit(Singleton, SkinSelectGUI)
addRemoteEvents{"openSkinSelectGUI"}
local images_per_row = 5
--[[
    skinTable = { skinId1, skinId2}
]]

function SkinSelectGUI:constructor(skinTable, groupId, groupType)
	
	local skin_count = skinTable and type(skinTable) == "table" and table.size(skinTable) or 0
	local areaHeight = math.min(math.ceil(skin_count/5)*5, 10)
	self.m_SkinCount = skin_count
	
	GUIWindow.updateGrid()		
	self.m_Width = grid("x", 16) 	
	self.m_Height = grid("y", areaHeight + 1) 


	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Kleidungs-Auswahl", true, true, self)

	self.m_EditButton = GUIGridIconButton:new(1, 1, FontAwesomeSymbols.Edit, self.m_Window)
	self.m_EditButton.onLeftClick = bind(SkinSelectGUI.setEditable, self) 


	self.m_ScrollableArea = GUIGridScrollableArea:new(1, 1, 15, areaHeight, 15, math.ceil(skin_count/5)*5 , true, false, self.m_Window, 1)
	self.m_ScrollableArea:updateGrid()
	
	local row = 0
	local i = 1
	self.m_SkinUpdateTimer = setTimer(function()
		local skinId = skinTable[i]
		local x, y, w, h = (i-1)*3 + 1 - row*images_per_row*3, row*images_per_row + 1, 3, 5
		
		self.m_Image = GUIGridWebView:new(x, y, w, h, INGAME_WEB_PATH .. "/ingame/skinPreview/skinPreview.php?skin="..skinId, true, self.m_ScrollableArea)
        self.m_Label = GUIGridLabel:new(x, y + h - 1, w, 1, "Skin "..skinId, self.m_ScrollableArea):setAlignX("center")
		self.m_Image.onLeftClick = function()	
			if type(callbackFunction) == "function" then
				--callbackFunction(skinId)
			end
		end
		if i % images_per_row == 0 then row = row + 1 end
		i = i + 1
	end, 50, skin_count)
end

function SkinSelectGUI:setEditable()
	if not self.m_Editable then
		if not self.m_EditItems then
			self.m_EditItems = {}
			local row = 0
			for i = 1, self.m_SkinCount do
				local x, y, w, h = (i-1)*3 + 1 - row*images_per_row*3, row*images_per_row + 1, 3, 1
				local changer = GUIGridChanger:new(x, y, w, h, self.m_ScrollableArea)
				for i = 0, 5 do	
					changer:addItem("Rang "..i)
				end
				table.insert(self.m_EditItems, changer)
				if i % images_per_row == 0 then row = row + 1 end
			end
		end
	else
		if self.m_EditItems then
			for i, v in pairs(self.m_EditItems) do
				v:delete()
			end
			self.m_EditItems = nil
		end
	end
	self.m_Editable = not self.m_Editable
end

function SkinSelectGUI:destructor()
	if isTimer(self.m_SkinUpdateTimer) then
		killTimer(self.m_SkinUpdateTimer)
	end
	GUIForm.destructor(self)
end


function SkinSelectGUI.open(skinTable, groupId, groupType)
	if SkinSelectGUI:isInstantiated() then
		delete(SkinSelectGUI:getSingleton())
	end
	SkinSelectGUI:new(skinTable, groupId, groupType)
end
addEventHandler("openSkinSelectGUI", root, SkinSelectGUI.open)
