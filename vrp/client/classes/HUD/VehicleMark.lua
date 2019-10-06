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

	self.m_Offsets = {
		[407] = {x=0, y=-1.5, z=0},
		[416] = {x=0, y=-1.5, z=0.25},
		[427] = {x=0, y=-1.5, z=0.125},
		[432] = {x=0, y=-1.2, z=0.625},
		[433] = {x=0, y=-1.5, z=0.25},
		[470] = {x=0, y=-0.65, z=0.575},
		[544] = {x=0, y=-2, z=0},
		[560] = {x=0, y=-0.75, z=0.25},
		[601] = {x=0, y=-1.2, z=0.5}
	}

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
		
		if self.m_Offsets[v:getModel()] then
			pos = Vector3(getVehicleComponentPosition(v, "wheel_lb_dummy", "world"))
			pos = pos + v.matrix.right * self.m_Offsets[v:getModel()].x
			pos = pos + v.matrix.forward * self.m_Offsets[v:getModel()].y
			pos = pos + v.matrix.up * self.m_Offsets[v:getModel()].z
			x, y, z = pos.x, pos.y, pos.z
		elseif getVehicleComponentPosition(v, "bump_rear_dummy", "world") then
			x,y,z = getVehicleComponentPosition(v, "bump_rear_dummy", "world")
		else
			x,y,z = getElementPosition(v)
		end

		local dist = getDistanceBetweenPoints2D(x, y, cx, cy)

		if v:getDimension() == localPlayer:getDimension() and v:getInterior() == localPlayer:getInterior() and dist < 7 and isLineOfSightClear(cx, cy, cz, x, y, z, true, true, false, true, false, false, false, v) then  
			local scale = 0.2 + (4 / dist )
			local sx, sy = getScreenFromWorldPosition(x, y, z)
			if sx and sy then
				dxDrawText(mark, sx, sy+1, nil, nil, tocolor(0, 0, 0, 255), scale, "sans")
				dxDrawText(mark, sx, sy, nil, nil, tocolor(255, 255, 255, 255), scale, "sans")
			end
		end
	end
end

function VehicleMark:destructor()
	removeEventHandler("onClientRender", root, self.m_Draw)
	setPedTargetingMarkerEnabled(true)
end
