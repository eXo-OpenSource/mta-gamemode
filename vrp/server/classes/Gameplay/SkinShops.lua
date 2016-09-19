-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/SkinShops.lua
-- *  PURPOSE:     Skin shops singleton class
-- *
-- ****************************************************************************
SkinShops = inherit(Singleton)

function SkinShops:constructor()
	InteriorEnterExit:new(Vector3(2244.5, -1665.1, 15.5), Vector3(207.6, -111.1, 1005.1), 0, 0, 15)
	Blip:new("Skinshop.png", 2244.5, -1665.1)
	InteriorEnterExit:new(Vector3(477.996, -1534.395, 19.670), Vector3(161.39, -96.69, 1001.81), 0, 0, 18)
	Blip:new("Skinshop.png", 477.996, -1534.395)

	addEvent("skinBuy", true)
	addEventHandler("skinBuy", root, bind(SkinShops.Event_skinBuy, self))
end

function SkinShops:Event_skinBuy(skinId)
	if not SkinInfo[skinId] then return end
	local name, price = unpack(SkinInfo[skinId])

	if client:getMoney() >= price then
		client:setSkin(skinId)
		client:takeMoney(price, "Kleidungs-Kauf")

		client:triggerEvent("skinBought", skinId)
		client:giveAchievement(23)
	else
		client:sendError(_("Du hast nicht genügend Geld!", client))
	end
end
