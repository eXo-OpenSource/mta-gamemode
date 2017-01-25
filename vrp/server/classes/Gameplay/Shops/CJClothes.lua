-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Shops/CJClothes.lua
-- *  PURPOSE:     CJ-Clothes class
-- *
-- ****************************************************************************
CJClothes = inherit(Shop)

function CJClothes:constructor(id, name, position, rotation, typeData, dimension, robable, money, lastRob, owner, price, ownerType)
	self:create(id, name, position, rotation, typeData, dimension, robable, money, lastRob, owner, price, ownerType)

	if typeData["ClothesMarker"] then
		self.m_ClothesMarker = {}
		for type, pos in pairs(typeData["ClothesMarker"]) do
			self.m_ClothesMarker[type] = createMarker(pos, "cylinder", 1, 255, 255, 0, 120)
			self.m_ClothesMarker[type].typeId = CJ_CLOTHE_TYPES[type]
			self.m_ClothesMarker[type].clothes = CJ_CLOTHES[type]
			self.m_ClothesMarker[type]:setInterior(self.m_Interior)
			self.m_ClothesMarker[type]:setDimension(self.m_Dimension)
			addEventHandler("onMarkerHit", self.m_ClothesMarker[type], bind(self.onCJClothesMarkerHit, self))
		end
	end

end

function CJClothes:onCJClothesMarkerHit(hitElement, dim)
	if dim and hitElement:getType() == "player" then
		if hitElement:getModel() == 0 then
			hitElement:triggerEvent("showClothesShopGUI", self.m_Id, source.typeId, source.clothes)
		else
			local cjName, cjPrice = unpack(SkinInfo[0])
			hitElement:triggerEvent("questionBox", _("Diese Kleidung ist nur für den %s-Skin möchtest du diesen für %d$ kaufen?", hitElement, cjName, cjPrice), "skinBuy", nil, 0)
		end
	end
end


function CJClothes:onShopEnter(player)
	player:sendShortMessage(_("Herzlich Willkommen im %s!", player, self.m_Name))
end
