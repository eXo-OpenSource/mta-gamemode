-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/SkinSelectGUI.lua
-- *  PURPOSE:     GUI label class
-- *
-- ****************************************************************************
SkinSelectGUI = inherit(GUIForm)
inherit(Singleton, SkinSelectGUI)


--[[
    skinTable = {
        [skinId] = minRank,
        [skinId] = minRank,
        [skinId] = minRank
    }
]]

function SkinSelectGUI:constructor(skinTable)
	
	local skin_count = skinTable and type(skinTable) == "table" and table.size(skinTable) or 0
	local areaHeight = math.min(math.ceil(skin_count/5)*5, 10)
	
	GUIWindow.updateGrid()		
	self.m_Width = grid("x", 16) 	
	self.m_Height = grid("y", areaHeight + 1) 

	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Kleidungs-Auswahl", true, true, self)
	self.m_ScrollableArea = GUIGridScrollableArea:new(1, 1, 15, areaHeight, 15, math.ceil(skin_count/5)*5 , true, false, self.m_Window, 1)
	self.m_ScrollableArea:updateGrid()
	
	local row = 0
	local images_per_row = 5
	for i = 1, skin_count do
		local x, y, w, h = (i-1)*3 + 1 - row*images_per_row*3, row*images_per_row + 1, 3, 5
		self.m_Image = GUIGridImage:new(x, y, w, h, "files/images/GUI/Radiobutton_checked.png", self.m_ScrollableArea)
        self.m_Label = GUIGridLabel:new(x, y + h - 1, w, 1, "Skin "..i, self.m_ScrollableArea):setAlignX("center")
        
        self.m_Image.onLeftClick = function()
			outputChatBox(i)	
		end
		if i % images_per_row == 0 then row = row + 1 end
	end
end

function SkinSelectGUI:destructor()
	GUIForm.destructor(self)
end
