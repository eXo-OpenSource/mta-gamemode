-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/ItemRadio.lua
-- *  PURPOSE:     3dRadio item class
-- *
-- ****************************************************************************
ItemRadio = inherit(Item)

function ItemRadio:constructor()
	self.m_Sound = false
end

function ItemRadio:destructor()
end

function ItemRadio:use(player)
end

function ItemRadio:onCollect()
	self.m_Sound:destroy()
	self.m_Sound = nil
end

function ItemRadio:onAction(name, url, object)
	if name == "changeurl" then
		if self.m_Sound then
			self.m_Sound:destroy()
			self.m_Sound = nil
		end

		if url ~= "" then
			-- Todo: Adjust sound range
			self.m_Sound = Sound3D.create(url, object:getPosition())
		end
	end
end

addEvent("itemRadioMenu", true)
addEventHandler("itemRadioMenu", root,
	function()
		local cx, cy = getCursorPosition()
		ClickHandler:getSingleton():addMouseMenu(RadioMouseMenu:new(cx*screenWidth, cy*screenHeight, source), source)
	end
)
