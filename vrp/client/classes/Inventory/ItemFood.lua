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

addEvent("bloodFx", true)
addEventHandler("bloodFx", root, function(item)
	if isElement(source) then
		setTimer(
			function(player)
				local x, y, z = getElementPosition(player)
				fxAddBlood(x, y, z+0.6, 0, 0, 0, 150, 1)
			end, 100, 40, source
		)

	end
end)

function ItemFood.attachEffect(effect, element)
	ItemFood.attachedEffects[effect] = {effect = effect, element = element}
	addEventHandler("onClientElementDestroy", effect, function()
		ItemFood.attachedEffects[effect] = nil
	end)
	addEventHandler("onClientElementDestroy", element, function()
		ItemFood.attachedEffects[effect] = nil
		effect:destroy()
	end)
	return true
end

addEventHandler("onClientPreRender", root,
	function()
		for fx, info in pairs(ItemFood.attachedEffects) do
			if isElement(info.element) then
				local x, y, z = getElementPosition(info.element)
				setElementPosition(fx, x, y, z)
			else
				ItemFood.attachedEffects[info.effect]:destroy()
				ItemFood.attachedEffects[info.effect] = nil
			end
		end
	end
)
