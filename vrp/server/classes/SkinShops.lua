-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/SkinShops.lua
-- *  PURPOSE:     Skin shops singleton class
-- *
-- ****************************************************************************
SkinShops = inherit(Singleton)

function SkinShops:constructor()
	InteriorEnterExit:new(Vector3(2244.5, -1665.1, 15.5), Vector3(207.6, -111.1, 1005.1), 0, 0, 15)

	Blip:new("Skinshop.png", 2244.5, -1665.1)
	addEvent("skinBuy", true)
	addEventHandler("skinBuy", root, bind(SkinShops.Event_skinBuy, self))
end

function SkinShops:Event_skinBuy(skinId)
	if not SkinInfo[skinId] then return end
	local name, price = unpack(SkinInfo[skinId])

	if client:getMoney() >= price then
		client:setSkin(skinId)
		client:takeMoney(price)

		client:triggerEvent("skinBought", skinId)
	else
		client:sendError(_("Du hast nicht genügend Geld!", client))
	end
end
