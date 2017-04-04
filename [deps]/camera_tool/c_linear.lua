function LinearRender()
	if basisPlaat and isElement(tabPannel) and guiGetSelectedTab(tabPannel) == linairTab then
			linearMovingTime = tonumber(guiGetText(editTimeBoxLinear))
		if linearMovingTime then
			if not fakeLinearPoint then
				fakeLinearPoint = createObject(1337, x1, y1, z1, 0, 0, 0 )
				setElementAlpha(fakeLinearPoint,0)
				setElementCollisionsEnabled(fakeLinearPoint,false)
			end
			if not isTimer(fakeLinearTimer) and linearMovingTime > 50 then
				setElementPosition(fakeLinearPoint,x1, y1, z1)
				fakeLinearTimer = setTimer(function()end, linearMovingTime,1)
				moveObject(fakeLinearPoint,linearMovingTime, x2, y2, z2,0,0,0,guiComboBoxGetItemText(linearComboBox, guiComboBoxGetSelected(linearComboBox)))
			end
			local kx,ky,kz = getElementPosition(marker1)
			local drawingDistance = 2
			dxDrawLine3D(kx-drawingDistance,ky,kz,kx+drawingDistance,ky,kz,tocolor(0,255,0,255),6)
			dxDrawLine3D(kx,ky-drawingDistance,kz,kx,ky+drawingDistance,kz,tocolor(0,255,0,255),6)
			dxDrawLine3D(kx,ky,kz-drawingDistance,kx,ky,kz+drawingDistance,tocolor(0,255,0,255),6)
			local kx,ky,kz = getElementPosition(marker2)			
			dxDrawLine3D(kx-drawingDistance,ky,kz,kx+drawingDistance,ky,kz,tocolor(255,0,0,255),6)
			dxDrawLine3D(kx,ky-drawingDistance,kz,kx,ky+drawingDistance,kz,tocolor(255,0,0,255),6)
			dxDrawLine3D(kx,ky,kz-drawingDistance,kx,ky,kz+drawingDistance,tocolor(255,0,0,255),6)
			local kx,ky,kz = getElementPosition(fakeLinearPoint)
			dxDrawLine3D(kx-drawingDistance,ky,kz,kx+drawingDistance,ky,kz,tocolor(0,0,255,255),6)
			dxDrawLine3D(kx,ky-drawingDistance,kz,kx,ky+drawingDistance,kz,tocolor(0,0,255,255),6)
			dxDrawLine3D(kx,ky,kz-drawingDistance,kx,ky,kz+drawingDistance,tocolor(0,0,255,255),6)				
			dxDrawLine3D(kx,ky,kz,x3, y3, z3,tocolor(0,255,255,255),6)
		end
	end
end
addEventHandler ( "onClientRender", getRootElement(), LinearRender)

function setPositionMarker1()
	if source ~= buttonMarker1 then return false end
	x1,y1,z1 = getElementPosition(localPlayer)
	setElementPosition( marker1, x1, y1, z1)
end

function setPositionMarker2()
	if source ~= buttonMarker2 then return false end
	x2,y2,z2 = getElementPosition(localPlayer)
	setElementPosition( marker2, x2, y2, z2)
end

function setPositionMarker3()
	if source ~= buttonMarker3 then return false end
	x3,y3,z3 = getElementPosition(localPlayer)
	setElementPosition( marker3, x3, y3, z3)
end

function stopCamera()
	removeEventHandler("onClientHUDRender", getRootElement(),cameraSetten)
	setCameraTarget(localPlayer)
	setElementAlpha(localPlayer,255)
	showPlayerHudComponent ( "radar", true )
end

function moveCameraWithoutTarget (button)
	if button == "left" and source == buttonMoveCamera then
		a,b,c,cam1,cam2,cam3,fov,thing = getCameraMatrix(localPlayer)
		setElementPosition(cameraPosition,x1,y1,z1)
		checkMovement=moveObject(cameraPosition,outputEditTimeBox,x2,y2,z2,0,0,0,guiComboBoxGetItemText(linearComboBox, guiComboBoxGetSelected(linearComboBox)))
		if not checkMovement then
			outputChatBox("#FF0000[CameraTool]: #FFA500Something went wrong, check your input boxes!",255,255,255,true)
			return false
		end
		addEventHandler("onClientHUDRender", getRootElement(),cameraSetten)
		timer1 = setTimer(stopCamera, outputEditTimeBox, 1)
		cameraMode = 2
		setElementAlpha(localPlayer,0)
		showPlayerHudComponent ( "radar", false )
			linearCamRollTimer = setTimer(function() end,outputEditTimeBox,1)
			linearCamRollStart = guiGetText(editLinearRollStart)
			linearCamRoll = guiGetText(editLinearRoll)
		closeGUI()
	end
end
--camera met target stoppen
function stopCamera2()
	removeEventHandler("onClientHUDRender", getRootElement(),cameraSettenMetTarget)
	setCameraTarget(localPlayer)
	setElementAlpha(localPlayer,255)
	showPlayerHudComponent ( "radar", true )
end
--camera met target bewegen
function moveCameraWithTarget (button)
	if button == "left" and source == buttonMoveCamera2 then
		setElementPosition(cameraPosition,x1,y1,z1)
		checkMovement=moveObject(cameraPosition,outputEditTimeBox,x2,y2,z2,0,0,0,guiComboBoxGetItemText(linearComboBox, guiComboBoxGetSelected(linearComboBox)))
		if not checkMovement then
			outputChatBox("#FF0000[CameraTool]: #FFA500Something went wrong, check your input boxes!",255,255,255,true)
			setCameraTarget(localPlayer)
			setElementAlpha(localPlayer,255)
			showPlayerHudComponent ( "radar", true )
			return false
		end
		addEventHandler("onClientHUDRender", getRootElement(),cameraSettenMetTarget)
		timer2 = setTimer(stopCamera2, outputEditTimeBox, 1)
		cameraMode = 1
		setElementAlpha(localPlayer,0)
		showPlayerHudComponent ( "radar", false )
		
			linearCamRollTimer = setTimer(function() end,outputEditTimeBox,1)
			linearCamRollStart = guiGetText(editLinearRollStart)
			linearCamRoll = guiGetText(editLinearRoll)
			
		closeGUI()
	end
end

function cameraSettenMetTarget()
	x4,y4,z4 = getElementPosition(cameraPosition)
	x5,y5,z5 = getElementPosition(marker3)
	if isTimer(linearCamRollTimer) then
		local timeleft,timesexecuted,totalexecute = getTimerDetails(linearCamRollTimer)
		local progress = timeleft/outputEditTimeBox
		linRoll,__,__ = interpolateBetween(linearCamRoll,0,0,0,0,0,progress,"Linear")
	end
	setCameraMatrix(x4,y4,z4,x5,y5,z5,linearCamRollStart+linRoll)
end

-- camera zonder target
function cameraSetten()
	if isTimer(linearCamRollTimer) then
		local timeleft,timesexecuted,totalexecute = getTimerDetails(linearCamRollTimer)
		local progress = timeleft/outputEditTimeBox
		linRoll,__,__ = interpolateBetween(linearCamRoll,0,0,0,0,0,progress,"Linear")
	end
	if kant == 1 then
		x4,y4,z4 = getElementPosition(cameraPosition)
		setCameraMatrix(x4,y4,z4, 0, 999999, 0,linearCamRollStart+linRoll, 0)
	elseif kant == 2 then 
		x4,y4,z4 = getElementPosition(cameraPosition)
		setCameraMatrix(x4,y4,z4, 0, -999999, 0,linearCamRollStart+linRoll, 0)
	elseif kant == 3 then
		x4,y4,z4 = getElementPosition(cameraPosition)
		setCameraMatrix(x4,y4,z4, -999999, 0, 0,linearCamRollStart+linRoll, 0)
	elseif kant == 4 then
		x4,y4,z4 = getElementPosition(cameraPosition)
		setCameraMatrix(x4,y4,z4, 999999, 0, 0,linearCamRollStart+linRoll, 0)
	end
end

-- rotation scripts
rotatingTime = 5000
rotateCenter = createObject(8558, 0,0,0,0,0,0,true)
rotatingObject = createObject(8558, 0,0,0,0,0,0,true)
rotX, rotY, rotZ = 0,0,90
setElementAlpha(rotateCenter, 0)
setElementAlpha(rotatingObject, 0)

function editTime2()
	rotatingTime=guiGetText(editTimeBox2)
end

-- rotation with target
function stopCamera1()
	removeEventHandler("onClientHUDRender", getRootElement(), rotateCameraWithTarget)
	setCameraTarget(localPlayer)
	setElementAlpha(localPlayer,255)
	showPlayerHudComponent ( "radar", true )
	detachElements(rotatingObject, rotateCenter)
	local x, y, z = getElementPosition(marker1)
	moveObject(rotateCenter,1,x,y,z,0,0,0,guiComboBoxGetItemText(linairComboBox, guiComboBoxGetSelected(linairComboBox)))
end
function rotateCameraWithTarget()
	local x,y,z = getElementPosition(rotatingObject)
	local x1,y2,z2 = getElementPosition(marker3)
	setCameraMatrix(x,y,z, x1, y2, z2, 0, 0)
end
function rotateWithTarget()
	closeGUI()
	a1,a2,a3 = getElementPosition(marker1)
	a4,a5,a6 = getElementPosition(marker2)
	a7,a8,a9 = a1-a4,a2-a5,a3-a6
	setElementPosition(rotateCenter, a1,a2,a3,0,0,0)
	setElementPosition(rotatingObject,a4,a5,a6)
	attachElements(rotatingObject, rotateCenter,a7,a8,a9)
	--outputChatBox("x"..a1.."y"..a2.."z"..a3.."")
	--outputChatBox("x"..a4.."y"..a5.."z"..a6.."")
	henk = moveObject(rotateCenter, rotatingTime,a1,a2,a3, rotX,rotY,90,guiComboBoxGetItemText(linairComboBox, guiComboBoxGetSelected(linairComboBox)))
	if henk then
		addEventHandler("onClientHUDRender", getRootElement(), rotateCameraWithTarget)
		setTimer(stopCamera1, rotatingTime+20, 1)
		setElementAlpha(localPlayer, 0)
		showPlayerHudComponent("radar", false)
	end
	if cursor == 2 then
		showCursor(false)
		cursor = 1
	end
end