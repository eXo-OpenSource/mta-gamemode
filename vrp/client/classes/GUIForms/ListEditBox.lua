-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/ListEditBox.lua
-- *  PURPOSE:     Generic list edit box class
-- *
-- ****************************************************************************
ListEditBox = inherit(GUIForm)

function ListEditBox:constructor(title, text, items, integerOnly, offsetY, callback)
	local offsetY = offsetY or 0

    self.m_Items = items
    self.m_Values = {}
    self.m_IntegerOnly = integerOnly

    for key, value in pairs(items) do
        self.m_Values[key] = value.value
    end

    if text ~= nil and text ~= "" then
        offsetY = offsetY + 1
    end

	GUIWindow.updateGrid()
	self.m_Width = grid("x", 21)
	self.m_Height = grid("y", 12 + offsetY)

	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, title, true, true, self)

    if text ~= nil and text ~= "" then
        self.m_Label = GUIGridLabel:new(1, 1, 20, offsetY, text, self.m_Window)
    end

	self.m_GridList = GUIGridGridList:new(1, 1 + offsetY, 20, 10, self.m_Window)
	self.m_GridList:addColumn(_"Name", 0.5)
	self.m_GridList:addColumn(_"Wert", 0.5)
    self:updateGrid()
    
    self.m_SubmitButton = GUIGridButton:new(16, 11 + offsetY, 5, 1, _"Bestätigen", self.m_Window):setBackgroundColor(Color.Green):setBarEnabled(true)

	if callback then
		self.m_SubmitButton.onLeftClick = function() if callback then callback(self.m_Values) end delete(self) end
	end
end

function ListEditBox:updateGrid()
    self.m_GridList:clear()
    for key, value in pairs(self.m_Values) do
		local item = self.m_GridList:addItem(tostring(self.m_Items[key].label), tostring(value))
		item.onLeftDoubleClick = bind(self.onGridClick, self, key)
    end
end

function ListEditBox:onGridClick(key)
	setTimer(bind(self.handleOnGridClick, self, key), 100, 1)
end

function ListEditBox:handleOnGridClick(key)
    local val = self.m_Values[key]
    InputBox:new(self.m_Items[key].label, "", bind(self.inputSelected, self, key), self.m_IntegerOnly, 0, val)
end

function ListEditBox:inputSelected(key, value)
    self.m_Values[key] = self.m_IntegerOnly and tonumber(value) or value
    self:updateGrid()
end
