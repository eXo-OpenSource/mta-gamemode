-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/HUD/VehicleMark.lua
-- *  PURPOSE:     VehicleMark class
-- *
-- ****************************************************************************

VehicleMark = inherit(Singleton)

addEvent("addVehicleMark", true)
addEvent("removeVehicleMark", true) 
addEvent("receiveVehicleMarks", true)
function VehicleMark:constructor()
	self.m_Stream = {}
	self.m_Data = {}

	self.m_StreamIn = bind(self.Event_StreamIn, self)
	self.m_StreamOut = bind(self.Event_StreamOut, self)

	addEventHandler("onClientRender", root, bind(self.render, self), true, "high")

	addEventHandler("addVehicleMark", localPlayer, bind(self.Event_AddMark, self))
	addEventHandler("removeVehicleMark", localPlayer, bind(self.Event_RemoveMark, self))
	addEventHandler("receiveVehicleMarks", localPlayer, bind(self.Event_ReceiveMark, self))
	triggerServerEvent("requestVehicleMarks", localPlayer)
end


function VehicleMark:Event_AddMark(element, mark) 
	if element then 
		self.m_Data[element] = mark
		addEventHandler("onClientElementStreamIn", element, self.m_StreamIn)
		addEventHandler("onClientElementStreamOut", element, self.m_StreamOut)
		if isElementStreamedIn(element) then 
			self.m_Stream[element]  = self.m_Data[element]
		end
	end
end

function VehicleMark:Event_RemoveMark(element) 
	if element then 
		self.m_Data[element] = nil
		self.m_Stream[element] = nil
		removeEventHandler("onClientElementStreamIn", element, self.m_StreamIn)
		removeEventHandler("onClientElementStreamOut", element, self.m_StreamOut)
	end
end

function VehicleMark:Event_ReceiveMark(tbl) 
	for v, mark in pairs(tbl) do 
		if v then 
			self:Event_AddMark(v, mark)
		end
	end
end

function VehicleMark:Event_StreamIn() 
	self.m_Stream[source] = self.m_Data[source]
end

function VehicleMark:Event_StreamOut() 
	self.m_Stream[source] = nil
end


function VehicleMark:render() 
	if not localPlayer.m_DisplayMode then return end
	if not core:get("HUD", "DisplayVehicleMark", true) then return end
	local cx, cy, cz = getCameraMatrix()
	for v, mark in pairs(self.m_Stream) do

		if not mark then return end
		local x,y,z = getVehicleComponentPosition ( v, "bump_rear_dummy", "world")
		if not x then 
			x,y,z = getElementPosition(v)
		end
		local dist = getDistanceBetweenPoints2D(x, y, cx, cy)

		if dist < 10 and isLineOfSightClear(cx, cy, cz, x, y, z, true, true, false, true, false, false, false, v) then  
			local scale = 0.2 + (4 / dist )
			local sx, sy = getScreenFromWorldPosition(x, y, z)
			if sx and sy then
				dxDrawText(mark, sx, sy, nil, nil, tocolor(255, 255, 255, 255), 1*scale, "sans")
			end
		end
	end
end

function VehicleMark:destructor()
	removeEventHandler("onClientRender", root, self.m_Draw)
	setPedTargetingMarkerEnabled(true)
end
