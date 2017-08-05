-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/NonCollisionArea.lua
-- *  PURPOSE:     Area where vehicles don't collide with others entities
-- *
-- ****************************************************************************
NonCollisionArea = inherit(Object)

function NonCollisionArea:constructor( col )
	self.m_ColShape = col
	addEventHandler("onColShapeHit", self.m_ColShape,
		function(hitElement, matchingDimension)
			local dim1 = hitElement:getDimension() 
			local dim2 = source:getDimension()
			if getElementType(hitElement) == "vehicle" and dim1 == dim2 then
				local occupant = getVehicleOccupant(hitElement,0)
				if not occupant then
					if not instanceof(hitElement,FactionVehicle) then 	
						setElementAlpha(hitElement, 200)
						setElementCollisionsEnabled(hitElement,false)
						setElementFrozen(hitElement,true)
					end
				end
				hitElement.m_CollisionArea = self 
			end
		end
	)
	
	addEventHandler("onColShapeLeave", self.m_ColShape,
		function(hitElement, matchingDimension)
			if getElementType(hitElement) == "vehicle" and matchingDimension then
				setElementCollisionsEnabled(hitElement,true)
				setElementAlpha(hitElement, 255)
				hitElement.m_CollisionArea = false
			end
		end
	)
	
	addEventHandler("onVehicleEnter",root,
		function( player, seat ) 
			if seat == 0 then 
				if source.m_CollisionArea == self then 
					setElementCollisionsEnabled(source,true)
					setElementAlpha(source, 255)
					setElementFrozen(source,false)
				end
			end
		end
	)
	
	addEventHandler("onVehicleExit",root,
		function( player, seat ) 
			if seat == 0 then 
				if source.m_CollisionArea == self then 
					setElementCollisionsEnabled(source,false)
					setElementAlpha(source, 200)
					setElementFrozen(source,true)
				end
			end	
		end
	)
	
end