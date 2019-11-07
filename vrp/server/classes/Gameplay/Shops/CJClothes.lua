-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Shops/CJClothes.lua
-- *  PURPOSE:     CJ-Clothes class
-- *
-- ****************************************************************************
CJClothes = inherit(Shop)

function CJClothes:constructor(id, name, position, rotation, typeData, dimension, robable, money, lastRob, owner, price, ownerType, interior)
	self:create(id, name, position, rotation, typeData, dimension, robable, money, lastRob, owner, price, ownerType, interior)

	--if self.m_Marker then
		--addEventHandler("onMarkerHit", self.m_Marker, bind(self.onTattooMarkerHit, self))
	--end

	if typeData["ClothesMarker"] then
		self.m_ClothesMarker = {}
		for type, pos in pairs(typeData["ClothesMarker"]) do
			self.m_ClothesMarker[type] = createMarker(pos, "cylinder", 1, 255, 255, 0, 120)
			self.m_ClothesMarker[type].typeId = CJ_CLOTHE_TYPES[type]
			self.m_ClothesMarker[type].clothes = CJ_CLOTHES[type]
			self.m_ClothesMarker[type]:setInterior(0)
			self.m_ClothesMarker[type]:setDimension(DYNAMIC_INTERIOR_DUMMY_DIMENSION)
			if type == "Tattoos" then
				addEventHandler("onMarkerHit", self.m_ClothesMarker[type], bind(self.onTattooMarkerHit, self))
			else
				addEventHandler("onMarkerHit", self.m_ClothesMarker[type], bind(self.onCJClothesMarkerHit, self))
			end
		end
	end

end

function CJClothes:onInternalEntranceUpdate(interior, dimension) 
	for type, marker in pairs(self.m_ClothesMarker) do 
		marker:setInterior(interior)
		marker:setDimension(dimension)
	end
end

function CJClothes:onCJClothesMarkerHit(hitElement, dim)
	if dim and hitElement:getType() == "player" then
		if hitElement:getModel() == 0 then
			hitElement:triggerEvent("showClothesShopGUI", self.m_Id, source.typeId, source.clothes)
		else
			local cjName, cjPrice = unpack(SkinInfo[0])
			QuestionBox:new(hitElement, hitElement, _("Diese Kleidung ist nur für den %s-Skin möchtest du diesen für %d$ kaufen?", hitElement, cjName, cjPrice), "skinBuy", nil, 0)
		end
	end
end

function CJClothes:onTattooMarkerHit(hitElement, dim)
	if dim and hitElement:getType() == "player" then
		if hitElement:getModel() == 0 then
			hitElement:triggerEvent("showTattooSelectionGUI", self.m_Id)
		else
			local cjName, cjPrice = unpack(SkinInfo[0])
			QuestionBox:new(hitElement, hitElement, _("Diese Tattoos sind nur für den %s-Skin möchtest du diesen für %d$ kaufen?", hitElement, cjName, cjPrice), "skinBuy", nil, 0)
		end
	end
end

function CJClothes:onTattoSelection(player, typeId)
	local type = CJ_CLOTHE_TYPES[typeId]
	local clothes = CJ_CLOTHES[type]
	player:triggerEvent("showClothesShopGUI", self.m_Id, typeId, clothes)
end

function CJClothes:onShopEnter(player)
	player:sendShortMessage(_("Herzlich Willkommen im %s!", player, self.m_Name))
end
