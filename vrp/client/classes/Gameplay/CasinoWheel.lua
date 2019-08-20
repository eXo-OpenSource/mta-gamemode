-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Minigames/CasinoWheel.lua
-- *  PURPOSE:     CasinoWheel
-- *
-- ****************************************************************************

CasinoWheel = inherit(Singleton) 


addRemoteEvents{"CasinoWheel:sendTableObjects", "CasinoWheel:sendTableObject", "CasinoWheel:startSpin", "CasinoWheel:clickWheel", "CasinoWheel:spinWheel",
				"CasinoWheel:reset", "CasinoWheel:lockBet", "CasinoWheel:acceptBet"}
local oldX, oldY, oldZ, oldLookX, oldLookY, oldLookZ, progress, alternateClicker, oldClickerRot
function CasinoWheel:constructor() 
	self.m_OnStreamBind = bind(self.Event_onElementStreamIn, self)
	self.m_OnStreamOutBind = bind(self.Event_onElementStreamOut, self)
	self.m_OnDestroyBind = bind(self.Event_onElementDestroy, self)

	self.m_Streamed = {}
	self.m_Table = {}

	self.m_RenderBind = bind(self.renderMovement, self)
	self.m_ClickerBind = bind(self.checkClicker, self)

	addEventHandler("CasinoWheel:sendTableObjects", localPlayer, bind(self.Event_onReceiveMap, self))
	addEventHandler("CasinoWheel:sendTableObject", localPlayer, bind(self.Event_onWheelCreated, self))

	addEventHandler("CasinoWheel:clickWheel", localPlayer, bind(self.Event_onClickWheel, self))
	addEventHandler("CasinoWheel:spinWheel", localPlayer, bind(self.Event_onSpinWheel, self))

	addEventHandler("CasinoWheel:reset", localPlayer, bind(self.Event_onReset, self))
	addEventHandler("CasinoWheel:lockBet", localPlayer, bind(self.Event_onLockBet, self))
	addEventHandler("CasinoWheel:acceptBet", localPlayer, bind(self.Event_onAcceptBet, self))

	addEventHandler("onClientRender", root, bind(self.onRender, self))

	triggerServerEvent("CasinoWheel:requestMap", localPlayer)

	
end

function CasinoWheel:Event_onClickWheel(obj) 
	self.m_CurrentWheel = obj
	if self.m_CurrentWheel and isValidElement(self.m_CurrentWheel, "object") then
		if CasinoWheelBet:isInstantiated() then 
			delete(CasinoWheelBet:getSingleton())
		end
		CasinoWheelBet:new()
		self:moveCamera(obj)
	end
end

function CasinoWheel:Event_onReset(win, turntime) 
	if self.m_CurrentWheel and isValidElement(self.m_CurrentWheel, "object") then
		if CasinoWheelBet:isInstantiated() then 
			CasinoWheelBet:getSingleton():reset(win, turntime)
		end
	end
end

function CasinoWheel:Event_onLockBet() 
	if self.m_CurrentWheel and isValidElement(self.m_CurrentWheel, "object") then
		if CasinoWheelBet:isInstantiated() then 
			CasinoWheelBet:getSingleton():lockBet()
		end
	end
end

function CasinoWheel:Event_onAcceptBet() 
	if self.m_CurrentWheel and isValidElement(self.m_CurrentWheel, "object") then
		if CasinoWheelBet:isInstantiated() then 
			CasinoWheelBet:getSingleton():activateRedraw()
		end
	end
end

function CasinoWheel:Event_onSpinWheel(obj, clicker, time) 
	if self.m_CurrentWheel == obj then
		if CasinoWheelBet:isInstantiated() then 
			if CasinoWheelBet:getSingleton().m_CountDown then
				CasinoWheelBet:getSingleton().m_CountDown:delete()
			end
		end
		if CasinoWheelBet:isInstantiated() then 
			self:moveCamera(self.m_CurrentWheel, true)
		else 
			self.m_CurrentWheel = nil 
		end
		self:moveClicker(clicker)
		self.m_ClickerDuration = time
		self.m_StartClicker = getTickCount()
		self.m_StopTimer = getTickCount() + time
		self.m_LastClickMove = getTickCount()
	end
end

function CasinoWheel:moveClicker(clicker)
	self.m_Clicker = clicker
	self.m_AlternateClicker = false
	removeEventHandler("onClientPreRender", root, self.m_ClickerBind)
	addEventHandler("onClientPreRender", root, self.m_ClickerBind)
end

function CasinoWheel:applyTexture(object)
	local ped = object:getData("CasinoWheel:ped") 
	if ped and isValidElement(ped, "ped") then
		object.m_Ped = FileTextureReplacer:new(ped, "BlackJack/sbmyst.jpg", "sbmyst", {}, true, true)
		local cone = ped:getData("CasinoWheel:cone")
		if cone and isValidElement(cone, "object") then
			object.m_Cone = FileTextureReplacer:new(cone, "BlackJack/redwhite_stripe.jpg", "redwhite_stripe", {}, true, true)
		end
	end
end

function CasinoWheel:checkClicker() 
	if self.m_Clicker then 
		local prog = (getTickCount() - self.m_StartClicker) / self.m_ClickerDuration
		local factor = interpolateBetween(20, 0, 0, 90, 0, 0, prog, "OutQuad")
		if getTickCount() - self.m_LastClickMove > factor then 
			self.m_AlternateClicker = not self.m_AlternateClicker
			self.m_Clicker:move(factor, self.m_Clicker.position.x, self.m_Clicker.position.y, self.m_Clicker.position.z, 0, self.m_AlternateClicker and -10 or 10, 0, "Linear")
			self.m_LastClickMove = getTickCount()
		end
		if getTickCount() > self.m_StopTimer then 
			self.m_Clicker:stop()
			self.m_Clicker:setRotation(self.m_Clicker.rotation.x, 0, self.m_Clicker.rotation.z) 
			removeEventHandler("onClientPreRender", root, self.m_ClickerBind)
			self.m_MoveBackTimer = setTimer(function() self:moveCamera(self.m_CurrentWheel) end, 4000, 1)
		end
	end
end


function CasinoWheel:stop() 
	if self.m_MoveBackTimer and isTimer(self.m_MoveBackTimer) then 
		killTimer(self.m_MoveBackTimer)
	end
	self.m_CurrentWheel = nil
	triggerServerEvent("CasinoWheel:onPlayerStop", localPlayer)
end

function CasinoWheel:moveCamera(obj, spinCam)
	if obj and isValidElement(obj, "object") then
		removeEventHandler("onClientPreRender", root, self.m_RenderBind)
    	oldX, oldY, oldZ, oldLookX, oldLookY, oldLookZ = getCameraMatrix()
    	progress = 0

		if not spinCam then
			self.m_CamPos =  obj.matrix:transformPosition(Vector3(0, -2, 0.5))
		else 
			self.m_CamPos =  obj.matrix:transformPosition(Vector3(0, -1, 0.8))
		end

		if not spinCam then 
			self.m_LookPos = obj:getPosition()
		else 
			self.m_LookPos = Vector3(obj:getPosition().x, obj:getPosition().y, obj:getPosition().z+0.5)
		end

		addEventHandler("onClientPreRender", root, self.m_RenderBind)
	end
end

function CasinoWheel:renderMovement(deltaTime) 
	if CasinoWheelBet:isInstantiated() then
		progress = progress + deltaTime * 0.0006
		local x, y, z = interpolateBetween(oldX, oldY, oldZ, self.m_CamPos, progress, "Linear")
		local lx, ly, lz = interpolateBetween(oldLookX, oldLookY, oldLookZ, self.m_LookPos, progress, "Linear")
		setCameraMatrix(x, y, z, lx, ly, lz)
		if progress >= 1 then
			removeEventHandler("onClientPreRender", root, self.m_RenderBind)
		end
	else
		removeEventHandler("onClientPreRender", root, self.m_RenderBind)
	end
end

function CasinoWheel:Event_onElementStreamIn() 
	self.m_Streamed[source] = true
end

function CasinoWheel:Event_onElementStreamOut() 
	self.m_Streamed[source] = nil
end

function CasinoWheel:Event_onWheelCreated(obj)
	if not self.m_Table[obj] then 
		self.m_Table[obj] = true
		addEventHandler("onClientElementStreamedIn", obj, self.m_OnStreamBind)
		addEventHandler("onClientElementStreamedOut", obj, self.m_OnStreamOutBind)
		addEventHandler("onClientElementDestroy", obj, self.m_OnDestroyBind)
		self:checkIfStreamed(obj)
		self:applyTexture(obj)
	end
end

function CasinoWheel:Event_onReceiveMap(tbl)
	for obj, k in pairs(tbl) do 
		if isValidElement(obj, "object") then
			self.m_Table[obj] = true
			addEventHandler("onClientElementStreamedIn", obj, self.m_OnStreamBind)
			addEventHandler("onClientElementStreamedOut", obj, self.m_OnStreamOutBind)
			addEventHandler("onClientElementDestroy", obj, self.m_OnDestroyBind)
			self:checkIfStreamed(obj)
			self:applyTexture(obj)
		end
	end
end

function CasinoWheel:Event_onElementDestroy() 
	self.m_Table[source] = nil
	self.m_Streamed[source] = nil
	self:removeTexture(source)
end


function CasinoWheel:onRender() 
	if not localPlayer.m_LoggedIn then return end
	for obj, k in pairs(self.m_Streamed) do 
		if isValidElement(obj, "object") then
			local ped = obj:getData("CasinoWheel:ped") and isValidElement(obj:getData("CasinoWheel:ped"), "ped") and obj:getData("CasinoWheel:ped")
			local x, y, z = getPedBonePosition(ped, 2)
			local lx, ly = getElementPosition(localPlayer)
			local dist = getDistanceBetweenPoints2D(x, y, lx, ly)
			if dist < 1 then dist = 1 end
			local distModifier = (0.7+ .3*(1/dist))
			
			local th = dxGetFontHeight(1.4, "sans") * distModifier
			if dist < 10 then
				local sx, sy = getScreenFromWorldPosition(x, y, z+.2)
				if isElementOnScreen(obj) and sx and sy then
					if obj:getData("CasinoWheel:WheelInfo") then 
						local text = ("%s"):format(convertNumber(obj:getData("CasinoWheel:WheelInfo")))
						local tw = dxGetTextWidth(text, 1.4, "sans") * distModifier

						dxDrawBoxShape(sx-tw*0.55, sy-th*0.05, tw*1.1, th*1.1)
						dxDrawBoxShape((sx-tw*0.55)+1, (sy-th*0.05)+1, tw*1.1, th*1.1, Color.Black)
						dxDrawText(text, (sx-tw*0.5)+1, sy+1, sx+tw*0.5, sy, Color.Black, 1.4 * distModifier, "sans")
						dxDrawText(text, sx-tw*0.5, sy, sx+tw*0.5, sy, Color.White, 1.4 * distModifier, "sans")
					end
				end
			end
		end
	end	
end

function CasinoWheel:checkIfStreamed(obj) 
	self.m_Streamed[obj] = isElementStreamedIn(obj)
end
