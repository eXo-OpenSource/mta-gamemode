-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/ItemRadio.lua
-- *  PURPOSE:     3dRadio item class
-- *
-- ****************************************************************************
ItemRadio = inherit(Item)

function ItemRadio:constructor()
	
end

function ItemRadio:destructor()
end

function ItemRadio:use(player)
end

addEvent("itemRadioChangeURL", true)
addEventHandler("itemRadioChangeURL", root,
	function(url)
		local radioObject = source
		
		if radioObject.sound then
			radioObject.sound:destroy()
			radioObject.sound = nil
		end
		
		if url ~= "" then
			-- Todo: Adjust sound range
			radioObject.sound = Sound3D.create(url, radioObject:getPosition())
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
