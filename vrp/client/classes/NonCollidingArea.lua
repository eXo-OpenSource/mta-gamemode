-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/NonCollidingArea.lua
-- *  PURPOSE:     Area where vehicles don't collide with others
-- *
-- ****************************************************************************
NonCollidingArea = inherit(Object)

function NonCollidingArea:constructor(x, y, width, height)
	self.m_ColShape = createColRectangle(x, y, width, height)
	
	addEventHandler("onClientColShapeHit", self.m_ColShape,
		function(hitElement, matchingDimension)
			if getElementType(hitElement) == "vehicle" and matchingDimension then
				for k, v in pairs(getElementsByType("vehicle")) do
					setElementCollidableWith(hitElement, v, false)
				end
				setElementAlpha(hitElement, 200)
			end
		end
	)
	
	addEventHandler("onClientColShapeLeave", self.m_ColShape,
		function(hitElement, matchingDimension)
			if getElementType(hitElement) == "vehicle" and matchingDimension then
				for k, v in pairs(getElementsByType("vehicle")) do
					setElementCollidableWith(hitElement, v, true)
				end
				setElementAlpha(hitElement, 255)
			end
		end
	)
end

function NonCollidingArea:destructor()
	destroyElement(self.m_ColShape)
end
