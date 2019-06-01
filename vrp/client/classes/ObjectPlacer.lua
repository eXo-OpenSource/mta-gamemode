-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/ObjectPlacer.lua
-- *  PURPOSE:     Class that simplifies placing objects via mouse (similar to the editor)
-- *
-- ****************************************************************************
ObjectPlacer = inherit(Object)

function ObjectPlacer:constructor(model, callback, hideObject)
	showCursor(true)
	localPlayer.m_ObjectPlacerActive = true
	if model > 312 then
		self.m_Object = createObject(model, localPlayer:getPosition())
	else
		self.m_Object = createPed(model, localPlayer:getPosition())
	end

	self.m_hideObject = hideObject
	self.m_Object:setCollisionsEnabled(false)
	self.m_Object:setInterior(localPlayer:getInterior())
	self.m_Object:setDimension(localPlayer:getDimension())
	self.m_Callback = callback

	if self.m_hideObject then
		self.m_Object:setRotation(0, 0, self.m_hideObject:getRotation().z)
		hideObject:setDimension(PRIVATE_DIMENSION_CLIENT)
	end
	self.m_CursorMove = bind(self.Event_CursorMove, self)
	addEventHandler("onClientCursorMove", root, self.m_CursorMove)

	self.m_MouseWheel = bind(self.Event_MouseWheel, self)
	bindKey("mouse_wheel_down", "down", self.m_MouseWheel)
	bindKey("mouse_wheel_up", "down", self.m_MouseWheel)

	self.m_Click = bind(self.Event_Click, self)
	addEventHandler("onClientClick", root, self.m_Click)
	

	self.m_Key = bind(self.Event_OnKey, self) 
	
	--do not indent as it will destroy the short message design
	if localPlayer:getRank() > 2 then
	addEventHandler("onClientKey", root, self.m_Key)
	self.m_ShortMessage = ShortMessage:new(_[[Bewege das Objekt mit deiner Maus
Weitere Funktionen:
  [Mausrad] - Objekt drehen (10°)
  [Shift] - Objekt schneller drehen (45°)
  [Alt] - Objekt langsamer drehen (5°)
  [W/S] - Auf und Ab 
  [Hoch/Runter/Links/Rechts] - Nach vorne und hinten
Linksklick zum Platzieren
Rechtsklick zum Abbrechen]], "Objektplatzierung", Color.DarkBlue, 0)
	else 
		self.m_ShortMessage = ShortMessage:new(_[[Bewege das Objekt mit deiner Maus
Weitere Funktionen:
  [Mausrad] - Objekt drehen (10°)
  [Shift] - Objekt schneller drehen (45°)
  [Alt] - Objekt langsamer drehen (5°)
Linksklick zum Platzieren
Rechtsklick zum Abbrechen]], "Objektplatzierung", Color.DarkBlue, 0)
	end

end

function ObjectPlacer:destructor()
	if self.m_Object and isElement(self.m_Object) then
		self.m_Object:destroy()
	end
	nextframe(
		function()
			localPlayer.m_ObjectPlacerActive = false
			if self.m_hideObject then
				self.m_hideObject:setDimension(0)
			end
		end
	)
	delete(self.m_ShortMessage)
	unbindKey("mouse_wheel_down", "down", self.m_MouseWheel)
	unbindKey("mouse_wheel_up", "down", self.m_MouseWheel)
	removeEventHandler("onClientCursorMove", root, self.m_CursorMove)
	removeEventHandler("onClientClick", root, self.m_Click)
	removeEventHandler("onClientKey", root, self.m_Key)
end

function ObjectPlacer:Event_CursorMove(cursorX, cursorY, absX, absY, worldX, worldY, worldZ)
	local camX, camY, camZ = getCameraMatrix()
	local surfaceFound, surfaceX, surfaceY, surfaceZ, element, nx, ny, nz, materialID = processLineOfSight(camX, camY, camZ, worldX, worldY, worldZ, true,
		true, true, true, true, true, false, true, localPlayer, false, true)
	if surfaceFound then
		local groundZ = getGroundPosition(surfaceX, surfaceY, surfaceZ + 2)
		if groundZ > surfaceZ then return end -- just stop the object if if would spawn underground

		self.m_Object:setPosition(surfaceX, surfaceY, surfaceZ + self.m_Object:getDistanceFromCentreOfMassToBaseOfModel())
		self.m_HitElement = element

		--[[dxDrawLine3D(surfaceX + 1, surfaceY, surfaceZ, surfaceX - 1, surfaceY, surfaceZ, tocolor(200, 0, 0), 2)
		dxDrawLine3D(surfaceX, surfaceY + 1, surfaceZ, surfaceX, surfaceY - 1, surfaceZ, tocolor(200, 0, 0), 2)
		dxDrawLine3D(surfaceX, surfaceY, surfaceZ + 1, surfaceX, surfaceY, surfaceZ - 1, tocolor(200, 0, 0), 2)]]
	end
end

function ObjectPlacer:Event_MouseWheel(button, state)
	local offset = 10
	if getKeyState("lshift") or getKeyState("rshift") then offset = 45 end
	if getKeyState("lalt") then offset = 5 end
	if button == "mouse_wheel_down" and state == "down" then
		self.m_Object:setRotation(0, 0, self.m_Object:getRotation().z - offset)
	else
		self.m_Object:setRotation(0, 0, self.m_Object:getRotation().z + offset)
	end
end

function ObjectPlacer:Event_OnKey( key, state ) 
	if state then
		local offset = 10
		local position = self.m_Object:getPosition()
		if getKeyState("lshift") or getKeyState("rshift") then offset = 45 end
		if getKeyState("lalt") then offset = 5 end
		offset = offset/50
		if key == "arrow_u" then 
			self.m_Object:setPosition(position.x, position.y + offset, position.z)
		elseif key == "arrow_d" then 
			self.m_Object:setPosition(position.x, position.y - offset, position.z)
		elseif key == "arrow_r" then 
			self.m_Object:setPosition(position.x + offset, position.y, position.z)
		elseif key == "arrow_l" then 
			self.m_Object:setPosition(position.x - offset, position.y, position.z)
		elseif key == "w" then 
			self.m_Object:setPosition(position.x, position.y, position.z + offset)
		elseif key == "s" then 
			self.m_Object:setPosition(position.x, position.y, position.z - offset)
		end
	end
end

function ObjectPlacer:Event_Click(btn, state)
	if state ~= "up" then return false end

	if btn == "left" then
		if self.m_HitElement and isElement(self.m_HitElement) and (self.m_HitElement:getType() == "player" or self.m_HitElement:getType() == "ped") then
			return ErrorBox:new(_"Du kannst Objekte nicht an Spielern platzieren.")
		end
		if self.m_HitElement and isElement(self.m_HitElement) and self.m_HitElement:getType() == "vehicle" then
			return ErrorBox:new(_"Du kannst Objekte nicht an Fahrzeugen platzieren.")
		end
		if self.m_Callback then
			if (self.m_Object:getPosition() - localPlayer:getPosition()).length > 20 then
				ErrorBox:new(_"Du musst in der Nähe der Zielposition sein!")
				return
			end
			self.m_Callback(self.m_Object:getPosition(), self.m_Object:getRotation().z)
		end
	else
		self.m_Callback(false)
	end
	-- Self-destruct
	delete(self)
end

addEvent("objectPlacerStart", true)
addEventHandler("objectPlacerStart", root,
	function(model, callbackEvent, hideObject, doNotShowInventory)
		InventoryOld:getSingleton():hide()
		nextframe(
			function(model,callbackEvent)
				local objectPlacer = ObjectPlacer:new(model,
					function(position, rotation)
						if position then
							triggerServerEvent(callbackEvent, localPlayer, position.x, position.y, position.z, rotation, hideObject)
						else
							triggerServerEvent(callbackEvent, localPlayer, false)
						end
						nextframe(
							function()
								if not hideObject and not doNotShowInventory then --if no object was moved
									InventoryOld:getSingleton():show()
								end
							end
						)
					end, hideObject
				)
			end, model, callbackEvent
		)
	end
)
