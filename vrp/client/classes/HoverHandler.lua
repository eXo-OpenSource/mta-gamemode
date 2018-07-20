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
	if FactionExplosiveTruckBoxGUI:isInstantiated() then
		delete(FactionExplosiveTruckBoxGUI:getSingleton())
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
		if self.m_CurrentHoverElement == element then return end -- do nothing if it is the same element
		if getElementData(element, "weaponBox") then
			if self.m_CurrentHoverElement == false or self.m_CurrentHoverElement ~= element then
				self.m_CurrentHoverElement = element
				if FactionWTBoxHoverGUI:isInstantiated() then
					delete(FactionWTBoxHoverGUI:getSingleton())
				end
				FactionWTBoxHoverGUI:getSingleton(element)
				return
			end
		elseif getElementData(element, "explosiveBox") then
			if self.m_CurrentHoverElement == false or self.m_CurrentHoverElement ~= element then
				self.m_CurrentHoverElement = element
				if FactionExplosiveTruckBoxGUI:isInstantiated() then
					delete(FactionExplosiveTruckBoxGUI:getSingleton())
				end
				FactionExplosiveTruckBoxGUI:getSingleton(element)
				return
			end
		elseif getElementData(element, "MoneyBag") then
			if self.m_CurrentHoverElement == false or self.m_CurrentHoverElement ~= element then
				self.m_CurrentHoverElement = element
				if FactionMoneyBagHoverGUI:isInstantiated() then
					delete(FactionMoneyBagHoverGUI:getSingleton())
				end
				FactionMoneyBagHoverGUI:getSingleton(element)
				return
			end
		end
	end
	self:closeAll()
end
