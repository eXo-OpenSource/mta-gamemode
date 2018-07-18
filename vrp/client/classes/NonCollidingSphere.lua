-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/NonCollidingSphere.lua
-- *  PURPOSE:     Area where vehicles don't collide with others
-- *
-- ****************************************************************************
NonCollidingSphere = inherit(Object)

function NonCollidingSphere:constructor(col)
	self.m_ColShape = col
	self.m_HitBind = bind(self.onHit, self)
	self.m_LeaveBind = bind(self.onLeave, self)

	addEventHandler("onClientColShapeHit", self.m_ColShape, self.m_HitBind)
	addEventHandler("onClientColShapeLeave", self.m_ColShape, self.m_LeaveBind, true, "high")
end

function NonCollidingSphere:onHit(hitElement, matchingDimension)
	if getElementType(hitElement) == "vehicle" and matchingDimension then
		for k, v in pairs(getElementsByType("vehicle")) do
			setElementCollidableWith(hitElement, v, false)
		end
		for k, v in pairs(getElementsByType("player")) do
			setElementCollidableWith(hitElement, v, false)
		end
		setElementAlpha(hitElement, 200)
	end
end

function NonCollidingSphere:onLeave(hitElement, matchingDimension)
	if getElementType(hitElement) == "vehicle" and matchingDimension then
		for k, v in pairs(getElementsByType("vehicle")) do
			setElementCollidableWith(hitElement, v, true)
		end
		for k, v in pairs(getElementsByType("player")) do
			setElementCollidableWith(hitElement, v, true)
		end
		setElementAlpha(hitElement, 255)
	end
end

function NonCollidingSphere:destructor()
	removeEventHandler("onClientColShapeHit", self.m_ColShape, self.m_HitBind)
	removeEventHandler("onClientColShapeLeave", self.m_ColShape, self.m_LeaveBind)
end

function NonCollidingSphere.load()
	for index, col in pairs(getElementsByType("colshape")) do
		if col:getData("NonCollidingSphere") then
			NonCollidingSphere:new(col)
		end
	end
end
