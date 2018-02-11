ItemSlam = inherit(Singleton) 

function ItemSlam:constructor() 
	self.m_Slams = {}
	addRemoteEvents{"syncItemSlams"}
	triggerServerEvent("onRequestSlams", localPlayer)
	addEventHandler("onClientRender", root, bind(self.Event_Render, self))
	addEventHandler("syncItemSlams", root, bind(self.Event_onReceiveSlams, self))
end

function ItemSlam:destructor() 

end

function ItemSlam:Event_onReceiveSlams( tbl ) 
	self.m_Slams = tbl 
end

function ItemSlam:Event_Render( ) 
	local objects = self.m_Slams
	local x,y,z, x2, y2, rot, _, vec3
	local px, py, pz = getElementPosition(localPlayer)
	local hit, hitx, hity, hitz, hitElement
	for key, obj in pairs(objects) do 
		if obj and isElement(obj) and getElementData(obj, "detonatorSlam") then 
			x,y,z = getElementPosition(obj) 
			if getDistanceBetweenPoints3D( x, y, z, px, py, pz ) <= 20 then
				_, _, rot = getElementRotation(obj)
				x2,y2 = getPointFromDistanceRotation(x, y, 6, -rot-180)
				vec3 = Vector3( x2 - x, y2 -y, z):getNormalized()*0.1
				hit, hitx, hity, hitz, hitElement = processLineOfSight(	x+vec3.x, y+vec3.y, z, x2, y2, z, true, true, true, true, true, false, false, false, obj)
				if(hitx) then
					if getElementData( obj, "Slam:laserEnabled")  then
						dxDrawLine3D(x, y, z, hitx, hity, hitz, tocolor(255, 0, 0, 200), 1)
						hit, hitx, hity, hitz, hitElement = processLineOfSight(	x, y, z, x2, y2, z, false, true, true, false)
						if hit and hitElement then
							if getElementType(hitElement) == "player" or getElementType(hitElement) == "vehicle" then
								if hitElement == localPlayer or hitElement == getPedOccupiedVehicle(hitElement) then
									triggerServerEvent("onSlamTouchLine", localPlayer, obj)
								end
							end
						end 
					else 
						dxDrawLine3D(x, y, z, hitx, hity, hitz, tocolor(0, 200, 0, 200), 1)
					end
				end
			end
		end
	end
end