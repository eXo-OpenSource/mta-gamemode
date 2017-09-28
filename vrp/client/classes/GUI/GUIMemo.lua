-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/GUIMemo.lua
-- *  PURPOSE:     GUI memo class
-- *
-- ****************************************************************************
GUIMemo = inherit(GUIWebView)
addEvent("onMemoTextChanged")

function GUIMemo:constructor(posX, posY, width, height, parent)
	GUIWebView.constructor(self, posX, posY, width, height, "http://mta/local/files/html/memo.htm", true, parent)

	addEventHandler("onMemoTextChanged", self.m_Browser, function(text) self.m_Text = text end)
end

function GUIMemo:getText()
	return self.m_Text
end

function GUIMemo:setText(text)
	assert(type(text) == "string" or type(text) == "number", "Bad argument @ GUIMemo.setText")
	self:callEvent("onMemoSetText", tostring(text))
end

-- Styles: full; lite; none (default)
function GUIMemo:setToolbarStyle(style)
	assert(type(style) == "string", "Bad argument @ GUIMemo.setToolbarStyle")
	self:callEvent("onMemoSetToolbarStyle", style)
end
