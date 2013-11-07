GUIWindow = inherit(GUIElement)

function GUIWindow:constructor(posX, posY, width, height, title, relative)
	self.m_Element = guiCreateWindow(posX, posY, width, height, title, relative)
	
	addEventHandler("onClientGUIClick", self.m_Element,
		function()
			
		end, false
	)
end

function GUIWindow:setMovable(status)
	return guiWindowSetMovable(self.m_Element, status)
end

function GUIWindow:setSizeable(status)
	return guiWindowSetSizable(self.m_Element, status)
end
