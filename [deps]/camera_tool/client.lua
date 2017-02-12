
function allowPlayer()
	marker1 = createMarker(0,0,0,"corona",1,0,0,0,0)
	marker2 = createMarker(0,0,0,"corona",1,0,0,0,0)
	marker3 = createMarker(0,0,0,"corona",1,0,0,0,0)
	cameraPosition = createObject(8558, 0,0,0,0,0,0,true)
	x1,y1,z1=0,0,0
	x2,y2,z2=0,0,0
	x3,y3,z3=0,0,0
	outputEditTimeBox=5000
	setElementAlpha(cameraPosition, 0)
	gui = 0
	a,b,c,cam1,cam2,cam3,fov,thing = 0,0,0,0,0,0,0,0
	kant=1
	roll = 0
	cameraMode = 0
	cirkularDataTable = {30,0,0,5000,0,0,0,1,"Linear"}
	
	outputChatBox("Fast help: press F6 to open/close the menu!", 255,0,0)
	outputChatBox("Fast help: right-click to show/hide the cursor!", 255,0,0)
	outputDebugString("ZenoS cameratool V2 has been started!")
	addCommandHandler("unbug", unbug)
	addCommandHandler("camera", createGui)
	bindKey("F6", "down", closeGUI) 
	bindKey("mouse2","down",showCursor1)
end
addEvent("onAllowPlayer", true)
addEventHandler("onAllowPlayer", root, allowPlayer)

function unbug()
setCameraTarget(localPlayer)
setElementAlpha(localPlayer, 255)
end

cursor = 2
function closeGUI ()
	if gui == 1 then
		destroyElement(basisPlaat)
		showCursor(false)
		cursor = 1
		gui = 0
	elseif gui == 0 then
		createGui()
	end
end

function showCursor1(button,state)
	showCursor( not isCursorShowing() )
	guiGridListSetSelectedItem(pointsList,0,0)
end

movingPathsIndex = 1
timeingsSynced = false
advancedPathTable = {}
movingpaths = {"Linear","InQuad","OutQuad","InOutQuad","OutInQuad","InElastic","OutElastic","InOutElastic","OutInElastic","InBack","OutBack","InOutBack","OutInBack","InBounce","OutBounce","InOutBounce","OutInBounce","SineCurve","CosineCurve"}
function createGui()
	if gui == 0 then
	gui = 1
	local w,h = guiGetScreenSize (localPlayer) 
	basisPlaat = guiCreateWindow(w-400,h-400, 400, 400,"ZenoS camera tool V2", false)
	plaatje = guiCreateStaticImage(10, 20, 70,70,"cameratool.png", false, basisPlaat)
	tabPannel=guiCreateTabPanel(20, 100, 360, 280, false, basisPlaat)
	editTimeBoxText = guiCreateLabel(100, 20,240,20,"Press F2 to open or close this menu", false, basisPlaat)
	editTimeBoxText = guiCreateLabel(100, 40,240,20,"Click your right mouse button to show or ", false, basisPlaat)
	editTimeBoxText = guiCreateLabel(100, 52,240,20,"hide the cursor ", false, basisPlaat)	
	editTimeBoxText = guiCreateLabel(100, 70,240,20,"Open the help menu with f9", false, basisPlaat)	
	linairTab = guiCreateTab("Linear movement", tabPannel)
	-- linair tab
	guiCreateLabel(230, 100,240,20,"Moving path's : ", false, linairTab)
	buttonMarker1 = guiCreateButton(20,10,90,20,"Point A", false, linairTab)
	buttonMarker2 = guiCreateButton(20,40,90,20,"Point B", false, linairTab)
	buttonMarker3 = guiCreateButton(20,70,90,20,"Target point", false, linairTab)
	buttonMoveCamera = guiCreateButton(230,10,120,40,"Move Camera without target", false, linairTab)
	buttonMoveCamera2 = guiCreateButton(230,60,120,40,"Move Camera with target", false, linairTab)
	buttonSaveTime = guiCreateButton(140, 180, 80, 20, "Edit time", false, linairTab)
	editTimeBoxLinear = guiCreateEdit( 20, 180, 120, 20, "5000", false, linairTab)
	
	editLinearRollStart = guiCreateEdit( 120,30,90,20, "0", false, linairTab)
	editTimeBoxText = guiCreateLabel(120,10,90,20,"Cam roll start:", false, linairTab)
	editLinearRoll = guiCreateEdit( 120,70,90,20, "0", false, linairTab)
	editTimeBoxText = guiCreateLabel(120,50,90,20,"Cam roll:", false, linairTab)
	
	editTimeBoxText = guiCreateLabel(20, 160,240,20,"Time in miliseconds (1000ms = 1s)", false, linairTab)
	north = guiCreateButton(20, 220, 50, 20, "North", false, linairTab)
	east = guiCreateButton(70, 220, 50, 20, "East", false, linairTab)
	south = guiCreateButton(120, 220, 50, 20, "South", false, linairTab)
	west = guiCreateButton(170, 220, 50, 20, "West", false, linairTab)
	addEventHandler("onClientGUIClick",buttonMarker1, setPositionMarker1)
	addEventHandler("onClientGUIClick",buttonMarker2, setPositionMarker2)
	addEventHandler("onClientGUIClick",buttonMarker3, setPositionMarker3)
	addEventHandler("onClientGUIClick", buttonMoveCamera, moveCameraWithoutTarget)
	addEventHandler("onClientGUIClick", buttonMoveCamera2, moveCameraWithTarget)
	addEventHandler("onClientGUIClick", buttonSaveTime, function() outputEditTimeBox=guiGetText(editTimeBoxLinear) end)
	addEventHandler("onClientGUIClick", north, function() kant = 1 end)
	addEventHandler("onClientGUIClick", east, function() kant = 4 end)
	addEventHandler("onClientGUIClick", south, function() kant = 2 end)
	addEventHandler("onClientGUIClick", west, function() kant = 3 end)
	
	cirkularTab = guiCreateTab("Circular movement", tabPannel)

	guiCreateLabel( 20, 60, 120, 20, "Circle start:  ", false, cirkularTab)	
	guiCreateLabel( 20, 145, 120, 20, "Radius:  ", false, cirkularTab)
	guiCreateLabel( 20, 35, 120, 20, "Radius:  ", false, cirkularTab)
	guiCreateLabel( 125, 35, 120, 20, "Roll:  ", false, cirkularTab)
	guiCreateLabel( 20, 175, 120, 20, "Z : ", false, cirkularTab)
	guiCreateLabel( 100, 175, 120, 20, "Roll: ", false, cirkularTab)
	guiCreateLabel(20, 80,240,20,"Time in miliseconds (1000ms = 1s)", false, cirkularTab)
	guiCreateLabel(20, 125,240,20,"Extra move distance : ", false, cirkularTab)
	guiCreateLabel(230, 100,240,20,"Moving path's : ", false, cirkularTab)
	guiCreateLabel(20, 200,240,20,"Amount of circle's : ", false, cirkularTab)
	
	cirkularMarker1 = guiCreateButton(20,10,90,20,"Point A", false, cirkularTab)
	cirkularEditRadius = guiCreateEdit(60,35,50,20,tostring(cirkularDataTable[1]), false, cirkularTab)											--!1
	cirkularStartDegrees = guiCreateEdit(85,60,50,20,tostring(cirkularDataTable[2]), false, cirkularTab)										--!2
	cirkularEditRoll = guiCreateEdit(150,35,65,20,tostring(cirkularDataTable[3]), false, cirkularTab)											--!3
	cirkularMarker2 = guiCreateButton(125,10,90,20,"Target point", false, cirkularTab)
	cirkularMoveCamera1 = guiCreateButton(230,10,120,40,"Move Camera without target (change direction in lin. tab)", false, cirkularTab)
	cirkularMoveCamera2 = guiCreateButton(230,60,120,40,"Move Camera with target", false, cirkularTab)
	editTimeBox = guiCreateEdit( 20, 100, 160, 20, tostring(cirkularDataTable[4]), false, cirkularTab)											--!4
	editExtraRad = guiCreateEdit( 60, 145, 120, 20, tostring(cirkularDataTable[5]), false, cirkularTab)											--!5
	editExtraZ = guiCreateEdit( 40, 175, 50, 20, tostring(cirkularDataTable[6]), false, cirkularTab)											--!6
	editExtraRoll = guiCreateEdit( 130, 175, 50, 20, tostring(cirkularDataTable[7]), false, cirkularTab)										--!7
	editAmountCirkels = guiCreateEdit( 20, 220, 160, 20, tostring(cirkularDataTable[8]), false, cirkularTab)									--!8
	cirkularComboBox = guiCreateComboBox ( 230, 120, 120,120, "Linear", false,cirkularTab )														--!9
	linearComboBox = guiCreateComboBox ( 230, 120, 120,120, "Linear", false,linairTab )
	for i,name in ipairs(movingpaths) do
		guiComboBoxAddItem(cirkularComboBox, name)
		guiComboBoxAddItem(linearComboBox, name)
	end
	for i,name in ipairs(movingpaths) do
		if movingpaths == cirkularDataTable[9] then
			guiComboBoxSetSelected(cirkularComboBox,i-1)
		end
	end		
	addEventHandler("onClientGUIClick",cirkularMoveCamera1, startMoving)
	addEventHandler("onClientGUIClick",cirkularMoveCamera2, startMoving)
	addEventHandler("onClientGUIClick",cirkularMarker1, function() 	if source ~= cirkularMarker1 then return false end kx1,ky1,kz1 = getElementPosition(getLocalPlayer()) end)
	addEventHandler("onClientGUIClick",cirkularMarker2, function() 	if source ~= cirkularMarker2 then return false end tx1,ty1,tz1 = getElementPosition(getLocalPlayer()) end)
	
	------------------------------------------------------------------------------------
	------------------------------------------------------------------------------------
	------------------------------------------------------------------------------------
	
	advancedTab = guiCreateTab("Advanced movement", tabPannel)	
	pointsList = guiCreateGridList ( 0, 10, 360, 150, false, advancedTab)
	guiGridListSetSelectionMode(pointsList,2)
	column1 = guiGridListAddColumn( pointsList, "Start point:", 0.45 )
	column2 = guiGridListAddColumn( pointsList, "End point:", 0.45 )
	column3 = guiGridListAddColumn( pointsList, "Curve bend around", 0.3 )
	column4 = guiGridListAddColumn( pointsList, "Path type", 0.3 )
	column5 = guiGridListAddColumn( pointsList, "Move path type", 0.3 )
	
	column6 = guiGridListAddColumn( pointsList, "Target start point:", 0.45 )
	column7 = guiGridListAddColumn( pointsList, "Target end point:", 0.45 )
	column8 = guiGridListAddColumn( pointsList, "Cam curve bend around", 0.3 )
	column9 = guiGridListAddColumn( pointsList, "Cam path type", 0.3 )
	column10 = guiGridListAddColumn( pointsList, "Cam move path type", 0.3 )
	
	column11 = guiGridListAddColumn( pointsList, "Smooth path", 0.3 )
	column12 = guiGridListAddColumn( pointsList, "Move time:", 0.3 )
	column13 = guiGridListAddColumn( pointsList, "Cam roll start", 0.3 )
	column14 = guiGridListAddColumn( pointsList, "Cam roll", 0.3 )
	column15 = guiGridListAddColumn( pointsList, "Cam roll move type", 0.3 )
	
	addPointButton = guiCreateButton(0,160,90,25,"Add new point", false, advancedTab)
	editPointButton = guiCreateButton(90,160,90,25,"Edit point", false, advancedTab)
	removePointButton = guiCreateButton(180,160,90,25,"Delete point", false, advancedTab)
	clearPointButton= guiCreateButton(270,160,90,25,"Clear all points", false, advancedTab)
	setPointButton= guiCreateButton(270,185,90,25,"Set point", false, advancedTab)
	savePointButton= guiCreateButton(270,210,90,25,"Save", false, advancedTab)
	movePointButton= guiCreateButton(270,235,90,25,"Move point up", false, advancedTab)
	syncPointButton= guiCreateButton(180,185,90,25,"Sync", false, advancedTab)
	startCameraMovementButton= guiCreateButton(0,185,180,25,"Move camera!", false, advancedTab)
	advancedEdit3= guiCreateEdit(180,230,90,30,"", false, advancedTab)
	advancedEdit2= guiCreateEdit(90,230,90,30,"", false, advancedTab)
	advancedEdit1= guiCreateEdit(0,230,90,30,"", false, advancedTab)
	advancedLabel3= guiCreateLabel(	185,210, 90, 30, ":  ", false, advancedTab)
	advancedLabel2= guiCreateLabel(	95,210, 90, 30, ":  ", false, advancedTab)
	advancedLabel1= guiCreateLabel( 5,210, 90, 30, ":  ", false, advancedTab)
	
	guiSetInputMode("allow_binds")
	--guiSetInputMode("no_binds_when_editing")
	guiGridListSetSortingEnabled ( pointsList, false) 	
	removeEventHandler ( "onClientRender", getRootElement(),advancedMovingPathRender)
	setCameraTarget(getLocalPlayer())
	if #advancedPathTable > 0 then
		for abkey=1,#advancedPathTable do	
			guiGridListAddRow ( pointsList )
		end
		updateGridList()
	end
	addAdvancedEventHandlers()	
	else
		removeEventHandler("onClientGUIClick",getRootElement(), startMoving)
	end	
end

function round(num, idp)
  return tonumber(string.format("%." .. (idp or 0) .. "f", num))
end

------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------

function toboolean(v)
    return (type(v) == "string" and v == "true") or (type(v) == "number" and v ~= 0) or (type(v) == "boolean" and v)
end

addEventHandler("onClientGUIChanged", getRootElement(), function(element) 
	if source == cirkularEditRadius 
	or source == cirkularStartDegrees 
	or source == cirkularEditRoll
	or source == editTimeBox 
	or source == editExtraRad 
	or source == editExtraZ 
	or source == editExtraRoll 
	or source == editAmountCirkels 
	or source == cirkularComboBox then
		cirkularDataTable = {tonumber(guiGetText(cirkularEditRadius)),tonumber(guiGetText(cirkularStartDegrees)),tonumber(guiGetText(cirkularEditRoll)),tonumber(guiGetText(editTimeBox)),tonumber(guiGetText(editExtraRad)),tonumber(guiGetText(editExtraZ)),tonumber(guiGetText(editExtraRoll)),tonumber(guiGetText(editAmountCirkels)),tostring(guiComboBoxGetItemText(cirkularComboBox, guiComboBoxGetSelected(cirkularComboBox)))}
		if isTimer(fakeTimer) then
			killTimer(fakeTimer)
		end
	elseif source == editTimeBoxLinear then
		if isTimer(fakeLinearTimer) then
			killTimer(fakeLinearTimer)
		end		
	end		
end)
 addEventHandler ( "onClientGUIClick", getRootElement(), function() 
	if source == cirkularMarker1 or source == cirkularMarker2 then 
		if isTimer(fakeTimer) then
			killTimer(fakeTimer)
		end
	elseif source == buttonMarker1 or source == buttonMarker2 or source == buttonMarker3 or source == buttonSaveTime then
		if isTimer(fakeLinearTimer) then
			killTimer(fakeLinearTimer)
		end		
	end
end)
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
