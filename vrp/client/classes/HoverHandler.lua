-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/HoverHandler.lua
-- *  PURPOSE:     Class that handles Hover on elements
-- *
-- ****************************************************************************
HoverHandler = inherit(Singleton)

function HoverHandler:constructor()
	addEventHandler("onClientCursorMove", root,bind(self.onClientCursorMove,self))
	self.m_CurrentHoverElement = false
end

function HoverHandler:closeAll()
	if FactionWTBoxHoverGUI:isInstantiated() then
		delete(FactionWTBoxHoverGUI:getSingleton())
	end
	if FactionMoneyBagHoverGUI:isInstantiated() then
		delete(FactionMoneyBagHoverGUI:getSingleton())
	end
	self.m_CurrentHoverElement = false
end

function HoverHandler:onClientCursorMove(cursorX, cursorY, absX, absY, worldX, worldY, worldZ)
	if not isCursorShowing() then
		self:closeAll()
		return
	end

	local element = getElementBehindCursor(worldX, worldY, worldZ)
	if isElement(element) then
		if getElementData(element,"weaponBox")  then
			if self.m_CurrentHoverElement == false or self.m_CurrentHoverElement ~= element then
				self.m_CurrentHoverElement = element
				FactionWTBoxHoverGUI:getSingleton(element)
			end
		elseif getElementData(element,"MoneyBag")  then
			if self.m_CurrentHoverElement == false or self.m_CurrentHoverElement ~= element then
				self.m_CurrentHoverElement = element
				FactionMoneyBagHoverGUI:getSingleton(element)
			end
		end
	end
	self:closeAll()
end
