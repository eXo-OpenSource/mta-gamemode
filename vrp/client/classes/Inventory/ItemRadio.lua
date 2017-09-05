-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/ItemRadio.lua
-- *  PURPOSE:     3dRadio item class
-- *
-- ****************************************************************************
addEvent("itemRadioChangeURLClient", true)
addEventHandler("itemRadioChangeURLClient", root,
	function(url)
		if isElement(source.Sound) then
			source.Sound:destroy()
		end
		local sound = Sound3D.create(url, source:getPosition())
		sound:setInterior(source:getInterior())
		sound:setDimension(source:getDimension())
		sound:attach(source)
		source.Sound = sound
	end
)

addEvent("itemRadioRemove", true)
addEventHandler("itemRadioRemove", root,
	function()
		if source.Sound and isElement(source.Sound) then
			source.Sound:destroy()
		end
	end
)

addEvent("itemRadioMenu", true)
addEventHandler("itemRadioMenu", root,
	function()
		local cx, cy = getCursorPosition()
		ClickHandler:getSingleton():addMouseMenu(RadioMouseMenu:new(cx*screenWidth, cy*screenHeight, source), source)
	end
)
