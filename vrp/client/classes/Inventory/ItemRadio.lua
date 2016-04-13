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
		local sound = Sound3D.create(url, source:getPosition())
		sound:attach(source)
		source.Sound = sound
	end
)

addEvent("itemRadioMenu", true)
addEventHandler("itemRadioMenu", root,
	function()
		local cx, cy = getCursorPosition()
		ClickHandler:getSingleton():addMouseMenu(RadioMouseMenu:new(cx*screenWidth, cy*screenHeight, source), source)
	end
)

addEvent("itemRadioRemove", true)
addEventHandler("itemRadioRemove", root,
	function()
		source.Sound:destroy()
	end
)
