
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
	GUIWindow.updateGrid()
	self.m_Width = grid("x", 6) 	-- width of the window
	self.m_Height = grid("y", 3) 	-- height of the window

	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, grid("x", 1), self.m_Width, self.m_Height, false)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Gießkanne (Taste X)", true, false, self)
	self.m_Progress = GUIGridProgressBar:new(1, 1, 5, 1, self.m_Window)
	self.m_Progress:setText(_"Füllstand")
	self.m_Progress:setProgressTextEnabled(true)
	self.m_InfoLabel = GUIGridLabel:new(1, 2, 3, 1, _"Bodenqualität:", self.m_Window)
	self.m_InfoLabelRes = GUIGridLabel:new(3, 2, 3, 1, "", self.m_Window)
	self.m_InfoLabelRes:setAlignX("right")

	self:refresh(state)
	self:updateGroundInfo()
	self.m_UpdateGroundInfoTimer = setTimer(bind(self.updateGroundInfo, self), 500, 0) -- render not really necessary as the player moves fairly slow
end

function ItemCanGUI:updateGroundInfo()
	local surfaceClear, surfaceRightType = Plant.checkGroundInfo()
	if not surfaceClear then
		self.m_InfoLabelRes:setText(_"zu steil")
		self.m_InfoLabelRes:setColor(Color.Red)
	elseif not surfaceRightType then
		self.m_InfoLabelRes:setText(_"zu trocken")
		self.m_InfoLabelRes:setColor(Color.Red)
	else
		self.m_InfoLabelRes:setText(_"fruchtbar")
		self.m_InfoLabelRes:setColor(Color.Green)
	end
end

function ItemCanGUI:destructor()
	GUIForm.destructor(self)
	if isTimer(self.m_UpdateGroundInfoTimer) then killTimer(self.m_UpdateGroundInfoTimer) end
end

function ItemCanGUI:refresh(state)
	self.m_Progress:setProgress(state*10)
	if tonumber(state) < 1 then
		InfoBox:new(_"Du kannst deine Gießkanne im Wasser auffüllen (drücke X)")
	end
end
