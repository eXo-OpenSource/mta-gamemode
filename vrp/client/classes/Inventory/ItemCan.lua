
addEvent("itemCanEnable", true)
addEventHandler("itemCanEnable", root,
	function(state)
		ItemCanGUI:new(state)
	end
)

addEvent("itemCanDisable", true)
addEventHandler("itemCanDisable", root,
	function()
		delete(ItemCanGUI:getSingleton())
	end
)

addEvent("itemCanRefresh", true)
addEventHandler("itemCanRefresh", root,
	function(state)
		ItemCanGUI:getSingleton():refresh(state)
	end
)

ItemCanGUI = inherit(GUIForm)
inherit(Singleton, ItemCanGUI)

function ItemCanGUI:constructor(state)
	GUIForm.constructor(self, screenWidth/2-200/2, 20, 200, 80, false)
	GUIRectangle:new(0, 0, self.m_Width, self.m_Height, tocolor(0, 0, 0, 125), self)
	GUILabel:new(0,0,self.m_Width, 30, _"Gießkannen-Füllstand:", self)
	self.m_Progress = GUIProgressBar:new(0,30,self.m_Width, 30,self)
	self.m_CanLabel = GUILabel:new(0, 30, self.m_Width, 30, state.."/10", self):setAlignX("center"):setAlignY("center"):setColor(Color.Black)
	self.m_HelpLabel = GUILabel:new(0, 60, self.m_Width, 20, _"Im Wasser auffüllen! Taste X", self)
	self.m_Progress:setForegroundColor(tocolor(50,200,255))
	self.m_Progress:setBackgroundColor(tocolor(180,240,255))
	self:refresh(state)
end

function ItemCanGUI:refresh(state)
	self.m_CanLabel:setText(state.."/10")
	self.m_Progress:setProgress(state*10)
	if tonumber(state) < 1 then
		self.m_HelpLabel:setText(_"Im Wasser auffüllen! Taste X")
	else
		self.m_HelpLabel:setText(_"Benutze die Kanne mit Taste X")
	end
end
