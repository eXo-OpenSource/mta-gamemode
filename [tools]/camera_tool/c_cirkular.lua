function startMoving()
	if source == cirkularMoveCamera1 or source == cirkularMoveCamera2 then	
		if tonumber(kx1) == nil then
			outputChatBox("#FF0000[CameraTool]: #FFA500Something went wrong, check your input boxes!",255,255,255,true)
			return false 
		end
		if tonumber(guiGetText(cirkularEditRoll)) == nil then
			outputChatBox("#FF0000[CameraTool]: #FFA500Something went wrong, check your input boxes!",255,255,255,true)
			return false
		else
			amountOfRoll = tonumber(guiGetText(cirkularEditRoll)) 
		end
		if tonumber(guiGetText(cirkularStartDegrees)) == nil then
			outputChatBox("#FF0000[CameraTool]: #FFA500Something went wrong, check your input boxes!",255,255,255,true)
			return false
		end
		if tonumber(guiGetText(editAmountCirkels)) == nil then
			outputChatBox("#FF0000[CameraTool]: #FFA500Something went wrong, check your input boxes!",255,255,255,true)
			return false
		else
			amountCirkels = tonumber(guiGetText(editAmountCirkels)) 
		end
		if editTimeBox and editExtraZ and editExtraRad then
			movingStartDegrees = tonumber(guiGetText(cirkularStartDegrees)) 
			movingTime = tonumber(guiGetText(editTimeBox))
			movingExtraRad = tonumber(guiGetText(editExtraRad))
			movingExtraZ = tonumber(guiGetText(editExtraZ))
			movingExtraRoll = tonumber(guiGetText(editExtraRoll))
			if movingTime == nil or movingTime <= 0 then
				outputChatBox("#FF0000[CameraTool]: #FFA500Something went wrong, check your input boxes!",255,255,255,true)
				return false
			end
			if movingExtraRoll == nil then
				outputChatBox("#FF0000[CameraTool]: #FFA500Something went wrong, check your input boxes!",255,255,255,true)
				return false
			end
			if movingExtraRad == nil then
				outputChatBox("#FF0000[CameraTool]: #FFA500Something went wrong, check your input boxes!",255,255,255,true)
				return false
			end
			if movingExtraZ == nil then
				outputChatBox("#FF0000[CameraTool]: #FFA500Something went wrong, check your input boxes!",255,255,255,true)
				return false
			end
		else
			outputChatBox("#FF0000[CameraTool]: #FFA500Something went wrong, check your input boxes!",255,255,255,true)
			return false
		end
		if not isElement(kern) or not isElement(camera) then
			kern = createObject(1337, kx1,ky1,kz1, 0, 0, movingStartDegrees )
			camera = createObject( 1337, kx1,ky1,kz1)
			setElementAlpha(camera,0)
			setElementAlpha(kern,0)
			attachElements ( camera, kern, guiGetText(cirkularEditRadius), 0, 0 )
		else
			setElementPosition(kern,kx1,ky1,kz1)
		end
		if source == cirkularMoveCamera1 then
			local item = guiComboBoxGetSelected(cirkularComboBox)
			text = guiComboBoxGetItemText(cirkularComboBox, item)
			moveObject(kern,movingTime,kx1,ky1,kz1+movingExtraZ,0,0,360*amountCirkels,text)
			addEventHandler("onClientHUDRender", getRootElement(), cirkularCameraWithoutTarget)
			setTimer(function() removeEventHandler("onClientHUDRender", getRootElement(), cirkularCameraWithoutTarget) end,movingTime,1)
		elseif source == cirkularMoveCamera2 then
			local item = guiComboBoxGetSelected(cirkularComboBox)
			text = guiComboBoxGetItemText(cirkularComboBox, item)
			moveObject(kern,movingTime,kx1,ky1,kz1+movingExtraZ,0,0,360*amountCirkels,text)
			addEventHandler("onClientHUDRender", getRootElement(), cirkularCameraWithTarget)
			setTimer(function() removeEventHandler("onClientHUDRender", getRootElement(), cirkularCameraWithTarget) end,movingTime,1)			
		end
		
		distance = tonumber(guiGetText(cirkularEditRadius))
		addEventHandler("onClientHUDRender", getRootElement(), closerRender)
		timer = setTimer(function() removeEventHandler("onClientHUDRender", getRootElement(), closerRender)end, movingTime,1)
		
		setTimer(function() setCameraTarget(getLocalPlayer()) destroyElement(kern) destroyElement(camera) createGui() setElementAlpha(localPlayer, 255) end,movingTime+50,1)
		setElementAlpha(localPlayer, 0)
		closeGUI()
	end
end

function cirkularCameraWithoutTarget()
	local x,y,z = getElementPosition(camera)
	if kant == 1 then
		setCameraMatrix(x,y,z,0,999999,0,amountOfRoll+roll)
	elseif kant == 2 then 
		setCameraMatrix(x,y,z,0,-999999,0,amountOfRoll+roll)
	elseif kant == 3 then
		setCameraMatrix(x,y,z,-999999,0,0,amountOfRoll+roll)
	elseif kant == 4 then
		setCameraMatrix(x,y,z,999999,0,0,amountOfRoll+roll)
	end
end
function cirkularCameraWithTarget()
	local x,y,z = getElementPosition(camera)
	setCameraMatrix(x,y,z,tx1,ty1,tz1,amountOfRoll+roll)
end

function cirkularMovementRender()
	if basisPlaat and isElement(tabPannel) and guiGetSelectedTab(tabPannel) == cirkularTab then
		movingTime = tonumber(guiGetText(editTimeBox))
		movingExtraRad = tonumber(guiGetText(editExtraRad))
		movingExtraZ = tonumber(guiGetText(editExtraZ))
		movingCirkels = tonumber(guiGetText(editAmountCirkels))
		movingRadius = tonumber(guiGetText(cirkularEditRadius))
		movingStartDegrees = tonumber(guiGetText(cirkularStartDegrees)) 
		if movingTime and movingExtraRad and movingExtraZ and tonumber(kx1) and movingCirkels and movingRadius and tonumber(tx1) and movingStartDegrees then
			if not fakeKern then
				fakeKern = createObject(1337, kx1,ky1,kz1, 0, 0, movingStartDegrees )
				fakeCamera = createObject( 1337, kx1,ky1,kz1)
				setElementAlpha(fakeKern,0)
				setElementAlpha(fakeCamera,0)
				setElementCollisionsEnabled(fakeKern,false)
				setElementCollisionsEnabled(fakeCamera,false)
				attachElements ( fakeCamera, fakeKern, movingRadius, 0, 0 )
			end
			if not isTimer(fakeTimer) and movingTime > 50 then
				setElementPosition(fakeKern,kx1,ky1,kz1)
				setElementRotation(fakeKern,0,0,movingStartDegrees)
				fakeTimer = setTimer(function()end, movingTime,1)
				moveObject(fakeKern,movingTime,kx1,ky1,kz1+movingExtraZ,0,0,360*movingCirkels,guiComboBoxGetItemText(cirkularComboBox, guiComboBoxGetSelected(cirkularComboBox)))
			end
			if movingRadius and isTimer(fakeTimer) then
				local timeleft,timesexecuted,totalexecute = getTimerDetails(fakeTimer)
				local progress = timeleft/movingTime
				fakeAttachoffset,__,__ = interpolateBetween(movingRadius+movingExtraRad,0,0,movingRadius,0,0,progress,"Linear")
				setElementAttachedOffsets(fakeCamera, fakeAttachoffset, 0, 0 )		
			end
			local kx,ky,kz = getElementPosition(fakeKern)
			local drawingDistance = 2
			dxDrawLine3D(kx-drawingDistance,ky,kz,kx+drawingDistance,ky,kz,tocolor(0,0,255,255),6)
			dxDrawLine3D(kx,ky-drawingDistance,kz,kx,ky+drawingDistance,kz,tocolor(0,0,255,255),6)
			dxDrawLine3D(kx,ky,kz-drawingDistance,kx,ky,kz+drawingDistance,tocolor(0,0,255,255),6)
			local kx,ky,kz = getElementPosition(fakeCamera)			
			dxDrawLine3D(kx-drawingDistance,ky,kz,kx+drawingDistance,ky,kz,tocolor(0,255,0,255),6)
			dxDrawLine3D(kx,ky-drawingDistance,kz,kx,ky+drawingDistance,kz,tocolor(0,255,0,255),6)
			dxDrawLine3D(kx,ky,kz-drawingDistance,kx,ky,kz+drawingDistance,tocolor(0,255,0,255),6)
			dxDrawLine3D(kx,ky,kz,tx1,ty1,tz1,tocolor(0,255,255,255),6)
		end
	end
end
addEventHandler ( "onClientRender", getRootElement(), cirkularMovementRender)

function closerRender()
	if distance and isTimer(timer) then
		local timeleft,timesexecuted,totalexecute = getTimerDetails(timer)
		local progress = timeleft/movingTime
		attachoffset,roll,__ = interpolateBetween(distance+movingExtraRad,0,0,distance,movingExtraRoll,0,progress,text)
		roll = roll - movingExtraRoll
		setElementAttachedOffsets(camera, attachoffset, 0, 0 )		
	end
end