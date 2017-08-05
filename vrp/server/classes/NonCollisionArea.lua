-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/NonCollisionArea.lua
-- *  PURPOSE:     Area where vehicles don't collide with others entities
-- *
-- ****************************************************************************
NonCollisionArea = inherit(Object)
NonCollisionArea.Vehicles = {}
function NonCollisionArea:constructor( col )
	self.m_ColShape = col
	addEventHandler("onColShapeHit", self.m_ColShape,
		function(hitElement, matchingDimension)
			if getElementType(hitElement) == "vehicle" and matchingDimension then
				if not instanceof(hitElement,FactionVehicle) and not instanceof(hitElement,CompanyVehicle) then 	
					local occupant = getVehicleOccupant(hitElement,0)
					if not occupant then
						setElementAlpha(hitElement, 200)
						setElementCollisionsEnabled(hitElement,false)
						setElementFrozen(hitElement,true)
					end
					NonCollisionArea[hitElement] = true
				end
			end
		end
	)
	
	addEventHandler("onColShapeLeave", self.m_ColShape,
		function(hitElement, matchingDimension)
			if getElementType(hitElement) == "vehicle" and matchingDimension then
				setElementCollisionsEnabled(hitElement,true)
				setElementAlpha(hitElement, 255)
				NonCollisionArea[hitElement] = false
			end
		end
	)
	
	addEventHandler("onVehicleEnter",root,
		function( player, seat ) 
			if seat == 0 then 
				if NonCollisionArea[source] then 
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
				if NonCollisionArea[source] then 
					setElementCollisionsEnabled(source,false)
					setElementAlpha(source, 200)
					setElementFrozen(source,true)
				end
			end	
		end
	)
	
end