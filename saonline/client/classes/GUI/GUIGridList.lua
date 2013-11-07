-- ****************************************************************************
-- *
-- *  PROJECT:     GTA:SA Online
-- *  FILE:        client/classes/GUI/GUIGridList.lua
-- *  PURPOSE:     GUI grid wrapper
-- *
-- ****************************************************************************
--[[
	Todo: The gridlist class requires some extra work e.g. a seperate grid list item class
]]

GUIGridList = inherit(GUIElement)

function GUIGridList:constructor(posX, posY, width, height, relative, parent)
	self.m_Element = guiCreateGridList(posX, posY, width, height, relative, parent)
end

function GUIGridList:addColumn(title, width)
	return guiGridListAddColumn(self.m_Element, title, width)
end

function GUIGridList:addRow(...)
	local row = guiGridListAddRow(self.m_Element)
	local columns = {...}
	for k, v in ipairs(columns) do
		guiGridListSetItemText(self.m_Element, row, k, v, false, false)
	end
end

function GUIGridList:clear()
	guiGridListClear(self.m_Element)
end

function GUIGridList:getSelectedItem()
	return guiGridListGetSelectedItem(self.m_Element)
end
