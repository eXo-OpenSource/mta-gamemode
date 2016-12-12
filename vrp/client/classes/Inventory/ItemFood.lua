-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Inventory/ItemFood.lua
-- *  PURPOSE:     Item Food class client
-- *
-- ****************************************************************************

local ItemFood = {}
ItemFood.attachedEffects = {}

addEvent("smokeEffect", true)
addEventHandler("smokeEffect", root, function(item)
	if isElement(item) then
		local effect = createEffect("cigarette_smoke", 0, 0, 0)
		ItemFood.attachEffect(effect, item)
	end
end)

function ItemFood.attachEffect(effect, element)
	ItemFood.attachedEffects[effect] = {effect = effect, element = element}
	addEventHandler("onClientElementDestroy", effect, function() ItemFood.attachedEffects[effect] = nil end)
	addEventHandler("onClientElementDestroy", element, function() ItemFood.attachedEffects[effect] = nil end)
	return true
end

addEventHandler("onClientPreRender", root,
	function()
		for fx, info in pairs(ItemFood.attachedEffects) do
			local x, y, z = getElementPosition(info.element)
			setElementPosition(fx, x, y, z)
		end
	end
)
