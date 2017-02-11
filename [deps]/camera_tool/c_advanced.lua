function addAdvancedEventHandlers()	
	function syncAllPoints(player)
		if source == syncPointButton or player == getLocalPlayer() then
			if #advancedPathTable == 0 then outputChatBox("#FF0000[CameraTool]: #FFA500Something went wrong, check your input boxes!(No path('s))",255,255,255,true) return false end
				timeingsSynced = false
				if advancedPathTable[1][11] == true then calculateSmoothCamPoints() end
				for _key,row in ipairs(advancedPathTable) do
					totalMovingTime = 0
					totalMoveDistance = 0
					if advancedPathTable[_key][20] == 0 then
						outputChatBox("#FF0000[CameraTool]: #FFA500Something went wrong.(No move distance this one is skipped!)",255,255,255,true)
					else
						setToSpeed = round((advancedPathTable[1][20]/(advancedPathTable[1][12]/1000)),2)
						for _key,row in ipairs(advancedPathTable) do
							if _key ~= 1 then
								advancedPathTable[_key][12] = math.floor(advancedPathTable[_key][20]/setToSpeed*1000)
							end
							totalMovingTime = totalMovingTime + advancedPathTable[_key][12]
						end
					if advancedPathTable[_key][21] ~= 0 then
						for _key,row in ipairs(advancedPathTable) do
							totalMoveDistance = totalMoveDistance + advancedPathTable[_key][21]
						end
						for _key,row in ipairs(advancedPathTable) do
							advancedPathTable[_key][19] = advancedPathTable[_key][21]/totalMoveDistance*totalMovingTime
						end
						timeingsSynced = true	
					end
				end
			end
			if timeingsSynced == false then
				outputChatBox("#FF0000[CameraTool]: #FFA500Something went wrong.(No cam move distance, this one is skipped!)",255,255,255,true)
			end
		end
		updateGridList()		
	end
	addEventHandler("onClientGUIClick",syncPointButton,syncAllPoints)
	
	addEventHandler("onClientGUIClick",clearPointButton, function() 
		if source ~= clearPointButton then return false end
		guiGridListClear ( pointsList )
		advancedPathTable = {}
	end)
	
	addEventHandler("onClientGUIClick",movePointButton, function()
		if source ~= movePointButton then return false end
		local row, column = guiGridListGetSelectedItem ( pointsList )
		local row,column = row+1,column
		shiftPoint = advancedPathTable[row-1]
		advancedPathTable[row-1] = advancedPathTable[row]
		advancedPathTable[row] = shiftPoint
		updateGridList()
		
	end)
	
	addEventHandler("onClientGUIClick",addPointButton, function() 
		if source ~= addPointButton then return false end
		local row = guiGridListAddRow ( pointsList )
		guiGridListSetItemText ( pointsList, row, 1, "0,0,0", false, false )	--x,y,z start
		guiGridListSetItemText ( pointsList, row, 2, "0,0,0", false, false )	--x,y,z end
		guiGridListSetItemText ( pointsList, row, 3, "0,0,0", false, false )	--bend around
		guiGridListSetItemText ( pointsList, row, 4, "curved", false, false )	--bend type
		guiGridListSetItemText ( pointsList, row, 5, "Linear", false, false )	--move type
		guiGridListSetItemText ( pointsList, row, 6, "0,0,0", false, false )    --cam x,y,z start
		guiGridListSetItemText ( pointsList, row, 7, "0,0,0", false, false )	--cam x,y,z end
		guiGridListSetItemText ( pointsList, row, 8, "0,0", false, false )		--cam bend around
		guiGridListSetItemText ( pointsList, row, 9, "curved", false, false )	--cam bend type
		guiGridListSetItemText ( pointsList, row, 10, "Linear", false, false )	--cam move type
		guiGridListSetItemText ( pointsList, row, 11, "true", false, false )	--cam smoothenpoints		
		guiGridListSetItemText ( pointsList, row, 12, "5000", false, false )	--moveingtime	
		guiGridListSetItemText ( pointsList, row, 13, "0", false, false )		--camroll start
		guiGridListSetItemText ( pointsList, row, 14, "0", false, false )		--camroll
		guiGridListSetItemText ( pointsList, row, 15, "Linear", false, false )	--camroll move type
		--19 -> Moving time cam
		--20 -> Total move distance normal paht
		--21 -> Total move distance Cam
		
		table.insert(advancedPathTable,{{0,0,0},{0,0,0},{0,0,0},"curved","Linear",{0,0,0},{0,0,0},{0,0,0},"curved","Linear",true,5000,0,0,"Linear"})
		advancedPathTable[#advancedPathTable][19],advancedPathTable[#advancedPathTable][20],advancedPathTable[#advancedPathTable][21] = 0,0,0
		timeingsSynced = false
		updateGridList()
	end)
	
	addEventHandler("onClientGUIClick",editPointButton, function()
		if source ~= editPointButton then return false end
		local row, column = guiGridListGetSelectedItem ( pointsList )
			if row ~= -1 and column ~= -1 then
				local row,column = row+1,column
				if type(advancedPathTable[row][column]) == "table" then
					guiSetText(advancedEdit1,advancedPathTable[row][column][1])
					guiSetText(advancedEdit2,advancedPathTable[row][column][2])
					if #advancedPathTable[row][column] == 3 then
						guiSetText(advancedEdit3,advancedPathTable[row][column][3])
					end
					guiSetText(advancedLabel1,"X:") guiSetText(advancedLabel2,"Y:") guiSetText(advancedLabel3,"Z:")
				elseif (type(advancedPathTable[row][column]) == "number" or type(advancedPathTable[row][column]) == "string") then
					guiSetText(advancedLabel1,tostring(type(advancedPathTable[row][column]))..":") guiSetText(advancedLabel2,":") guiSetText(advancedLabel3,":")
					guiSetText(advancedEdit1,advancedPathTable[row][column])
					guiSetText(advancedEdit2,"")
					guiSetText(advancedEdit3,"")
				elseif type(advancedPathTable[row][column]) == "boolean" then
					guiSetText(advancedLabel1,tostring(type(advancedPathTable[row][column]))..":") guiSetText(advancedLabel2,":") guiSetText(advancedLabel3,":")
					guiSetText(advancedEdit1,tostring(advancedPathTable[row][column]))
					guiSetText(advancedEdit2,"")
					guiSetText(advancedEdit3,"")
				end
			else
				outputChatBox("#FF0000[CameraTool]: #FFA500Something went wrong.(No gridlist item selected.)",255,255,255,true)
			end		
	end)
	
	addEventHandler("onClientGUIClick",savePointButton, function()
		if source ~= savePointButton then return false end
		local row, column = guiGridListGetSelectedItem ( pointsList )
		if row ~= -1 and column ~= -1 then
			local row,column = row+1,column
			if type(advancedPathTable[row][column]) == "table" then
				advancedPathTable[row][column][1]= guiGetText(advancedEdit1)
				advancedPathTable[row][column][2]= guiGetText(advancedEdit2)
				if 	string.find(guiGetText(advancedEdit1),"%a") or string.find(guiGetText(advancedEdit1),"%z") or guiGetText(advancedEdit1) == "" then advancedPathTable[row][column][1] = 0 end
				if string.find(guiGetText(advancedEdit2),"%a") or string.find(guiGetText(advancedEdit2),"%z") or guiGetText(advancedEdit2) == "" then advancedPathTable[row][column][2] = 0 end
				if #advancedPathTable[row][column] == 3 then			
					advancedPathTable[row][column][3]= guiGetText(advancedEdit3)
					if string.find(guiGetText(advancedEdit3),"%a") or string.find(guiGetText(advancedEdit3),"%z") or guiGetText(advancedEdit3) == "" then advancedPathTable[row][column][3] = 0 end
				end
			elseif type(advancedPathTable[row][column]) == "string" and guiGetText(advancedEdit1) ~= "" then
				advancedPathTable[row][column]= guiGetText(advancedEdit1)
			elseif type(advancedPathTable[row][column]) == "number" and guiGetText(advancedEdit1) ~= "" then
				advancedPathTable[row][column]= tonumber(guiGetText(advancedEdit1))
			elseif type(advancedPathTable[row][column]) == "boolean" and guiGetText(advancedEdit1) ~= "" then
				advancedPathTable[row][column]= toboolean(guiGetText(advancedEdit1))
			end
		else
			outputChatBox("#FF0000[CameraTool]: #FFA500Something went wrong.(No gridlist item selected.)",255,255,255,true)
		end
		updateGridList()
	end)	
	
	addEventHandler("onClientGUIClick",removePointButton, function()
		if source ~= removePointButton then return false end
		local row, column = guiGridListGetSelectedItem ( pointsList )
		if row ~= -1 and column ~= -1 then
			guiGridListRemoveRow(pointsList,row)
			table.remove(advancedPathTable,row+1)		
			updateGridList()
		else
		outputChatBox("#FF0000[CameraTool]: #FFA500Something went wrong.(No gridlist item selected.)",255,255,255,true)
		end
	end)
	
	addEventHandler("onClientGUIClick",setPointButton, function()
		if source ~= setPointButton then return false end
		local row, column = guiGridListGetSelectedItem ( pointsList )
		if row ~= -1 and column ~= -1 then
			if type(advancedPathTable[row+1][column]) == "table" then
				local x,y,z = getElementPosition(getLocalPlayer())
				if #advancedPathTable[row+1][column] == 3 then
					advancedPathTable[row+1][column] = {round(x,1),round(y,1),round(z,1)}
				else
					advancedPathTable[row+1][column] = {round(x,1),round(y,1)}
				end
				updateGridList()
			else
				outputChatBox("#FF0000[CameraTool]: #FFA500Something went wrong, check your input boxes!(String where table needs to be)",255,255,255,true)
			end
		else
			outputChatBox("#FF0000[CameraTool]: #FFA500Something went wrong.(No gridlist item selected.)",255,255,255,true)
		end		
	end)
	
	addEventHandler("onClientGUIClick",startCameraMovementButton, function()
		if source ~= startCameraMovementButton then return false end
		if #advancedPathTable <= 0 then outputChatBox("#FF0000[CameraTool]: #FFA500Something went wrong, check your input boxes!(No path('s))",255,255,255,true)return false end
		closeGUI()
		for _key,row in ipairs(advancedPathTable) do
			if advancedPathTable[_key][21] <= 0 or advancedPathTable[_key][19] <= 50 then
				advancedPathTable[_key][19] = advancedPathTable[_key][12]
			end
		end
		amountOfPoints = 1
		amountOfCamPoints = 1
		advancedMovementTimer = setTimer(function()end,advancedPathTable[amountOfPoints][12],1)
		advancedCamMovementTimer = setTimer(function()end,advancedPathTable[amountOfCamPoints][19],1)
		addEventHandler ( "onClientRender", getRootElement(),advancedMovingPathRender)
		removeEventHandler ( "onClientRender", getRootElement(), drawVisablePath)
		setElementAlpha(localPlayer, 0)
	end)
end
	
totalCamRoll = 0
lastCamRoll = 0

function advancedMovingPathRender()
	if amountOfCamPoints and isTimer(advancedCamMovementTimer) then
		local x1,y1,z1 = advancedPathTable[amountOfCamPoints][6][1],advancedPathTable[amountOfCamPoints][6][2],advancedPathTable[amountOfCamPoints][6][3]
		local x2,y2,z2 = advancedPathTable[amountOfCamPoints][7][1],advancedPathTable[amountOfCamPoints][7][2],advancedPathTable[amountOfCamPoints][7][3]
		local bx,by,bz = advancedPathTable[amountOfCamPoints][8][1],advancedPathTable[amountOfCamPoints][8][2],advancedPathTable[amountOfCamPoints][8][3]

		local x1,y1,z1 = x1-bx,y1-by,z1-bz
		local x2,y2,z2 = x2-bx,y2-by,z2-bz
		local delta_a = math.pi*0.0625
		local math_sin,math_cos = math.sin,math.cos		
			timeleft1,timesexecuted1,totalexecute1 = getTimerDetails(advancedCamMovementTimer)
			progress1 = 1-timeleft1/advancedPathTable[amountOfCamPoints][19]
			b,__,__ = interpolateBetween(0,0,0,(math.pi+delta_a)*0.5-(4*delta_a/8),0,0,progress1,advancedPathTable[amountOfCamPoints][10])
			local sina,cosa = math_sin(b),math_cos(b)
		if string.lower(advancedPathTable[amountOfCamPoints][9]) ~= "curved" then
			tx,ty,tz = interpolateBetween(x1,y1,z1,x2,y2,z2,progress1,advancedPathTable[amountOfCamPoints][10])
		else
			tx,ty,tz = bx+x1*cosa+x2*sina,by+y1*cosa+y2*sina,bz+z1*cosa+z2*sina
		end
	else
		if amountOfCamPoints < #advancedPathTable then
			amountOfCamPoints = amountOfCamPoints + 1
			advancedCamMovementTimer = setTimer(function()end,advancedPathTable[amountOfCamPoints][19],1)
		else
			amountOfCamPoints = 0
		end
	end
	if amountOfPoints and isTimer(advancedMovementTimer) then
		local x1,y1,z1 = advancedPathTable[amountOfPoints][1][1],advancedPathTable[amountOfPoints][1][2],advancedPathTable[amountOfPoints][1][3]
		local x2,y2,z2 = advancedPathTable[amountOfPoints][2][1],advancedPathTable[amountOfPoints][2][2],advancedPathTable[amountOfPoints][2][3]
		local bx,by,bz = advancedPathTable[amountOfPoints][3][1],advancedPathTable[amountOfPoints][3][2],advancedPathTable[amountOfPoints][3][3]			
		--local bz = (z1+z2)*0.5			
		local x1,y1,z1 = x1-bx,y1-by,z1-bz
		local x2,y2,z2 = x2-bx,y2-by,z2-bz			
		local math_sin,math_cos = math.sin,math.cos
		local delta_a = math.pi*0.0625			
			timeleft,timesexecuted,totalexecute = getTimerDetails(advancedMovementTimer)
			progress = 1-timeleft/advancedPathTable[amountOfPoints][12]		
			__,CamRoll,__ = interpolateBetween(0,0,0,0,advancedPathTable[amountOfPoints][14],0,progress,advancedPathTable[amountOfPoints][15])		
			a,__,__ = interpolateBetween(0,0,0,math.pi*0.5,0,0,progress,advancedPathTable[amountOfPoints][5])
		local sina,cosa = math_sin(a),math_cos(a)
	
		if string.lower(advancedPathTable[amountOfPoints][4]) ~= "curved" then
			local x,y,z = interpolateBetween(advancedPathTable[amountOfPoints][1][1],advancedPathTable[amountOfPoints][1][2],advancedPathTable[amountOfPoints][1][3],advancedPathTable[amountOfPoints][2][1],advancedPathTable[amountOfPoints][2][2],advancedPathTable[amountOfPoints][2][3],progress,advancedPathTable[amountOfPoints][5])
			setCameraMatrix(x,y,z,tx,ty,tz,lastCamRoll+advancedPathTable[1][13]+CamRoll)
		else				
			setCameraMatrix(bx+x1*cosa+x2*sina,by+y1*cosa+y2*sina,bz+z1*cosa+z2*sina,tx,ty,tz,lastCamRoll+advancedPathTable[1][13]+CamRoll)
		end			
	else
		if amountOfPoints < #advancedPathTable then
			lastCamRoll = lastCamRoll + CamRoll
			amountOfPoints = amountOfPoints + 1
			advancedMovementTimer = setTimer(function()end,advancedPathTable[amountOfPoints][12],1)
		else
			removeEventHandler ( "onClientRender", getRootElement(),advancedMovingPathRender)
			amountOfPoints = 0
			lastCamRoll = 0
			addEventHandler ( "onClientRender", getRootElement(), drawVisablePath)
			unbug()
		end
	end		
end

function updateGridList()
	if basisPlaat and isElement(tabPannel) then
		for _key,row in ipairs(advancedPathTable) do
			for __key,value in ipairs(row) do
				if type(value) == "table" then
					if #value == 2 then
						guiGridListSetItemText(pointsList,_key-1,__key,tostring(round(value[1],1)..","..round(value[2],1)),false,false)
					else
						guiGridListSetItemText(pointsList,_key-1,__key,tostring(round(value[1],1)..","..round(value[2],1)..","..round(value[3],1)),false,false)
					end
				else
					guiGridListSetItemText(pointsList,_key-1,__key,tostring(value),false,false)
				end
				if #advancedPathTable > 1 and (_key) > 1 then
					guiGridListSetItemText( pointsList, _key-1,11,"-----",false,false)
					guiGridListSetItemColor( pointsList, _key-1,11, 255, 0, 0 )
					guiGridListSetItemText( pointsList, _key-1,13,"-----",false,false)
					guiGridListSetItemColor( pointsList, _key-1,13, 255, 0, 0 )
				end	
			end
		end
	end
end

function drawConnectionBend(bx,by,x1,y1,z1,x2,y2,z2,color,curveType,key)	
	if basisPlaat and isElement(tabPannel) and guiGetSelectedTab(tabPannel) == advancedTab then
		if string.lower(advancedPathTable[key][9]) == "curved" then
			local x1,y1,z1,x2,y2,z2 = 	advancedPathTable[key][6][1],advancedPathTable[key][6][2],advancedPathTable[key][6][3],
										advancedPathTable[key][7][1],advancedPathTable[key][7][2],advancedPathTable[key][7][3]
			local bx,by,bz = advancedPathTable[key][8][1],advancedPathTable[key][8][2],advancedPathTable[key][8][3]
			dxDrawLine3D(x1,y1,z1,bx,by,bz,tocolor(255,0,255,255),3)
			dxDrawLine3D(x2,y2,z2,bx,by,bz,tocolor(255,0,255,255),3)
			local x1,y1,z1 = x1-bx,y1-by,z1-bz
			local x2,y2,z2 = x2-bx,y2-by,z2-bz
			local math_sin,math_cos = math.sin,math.cos
			local delta_a = math.pi*0.0625
			distance3d = 0
			for a = delta_a/8,math.pi*0.5,delta_a/8 do
				local sina,cosa = math_sin(a),math_cos(a)
				local sinb,cosb = math_sin(a-delta_a/8),math_cos(a-delta_a/8)
				dxDrawLine3D(bx+x1*cosa+x2*sina,by+y1*cosa+y2*sina,bz+z1*cosa+z2*sina,
							bx+x1*cosb+x2*sinb,by+y1*cosb+y2*sinb,bz+z1*cosb+z2*sinb,tocolor(0,0,255,255),6)		
				distance3d = distance3d + getDistanceBetweenPoints3D(bx+x1*cosa+x2*sina,by+y1*cosa+y2*sina,bz+z1*cosa+z2*sina,bx+x1*cosb+x2*sinb,by+y1*cosb+y2*sinb,bz+z1*cosb+z2*sinb)
				advancedPathTable[key][21]=distance3d
			end
		else
			local x1,y1,z1,x2,y2,z2 = 	advancedPathTable[key][6][1],advancedPathTable[key][6][2],advancedPathTable[key][6][3],
										advancedPathTable[key][7][1],advancedPathTable[key][7][2],advancedPathTable[key][7][3]	
			dxDrawLine3D(x1,y1,z1,x2,y2,z2,tocolor(0,0,255,255),6)
			distance3d = getDistanceBetweenPoints3D(x1,y1,z1,x2,y2,z2)
			advancedPathTable[key][21]=distance3d
		end
		if string.lower(curveType) == "curved" then
			bz = advancedPathTable[key][3][3]
			dxDrawLine3D(x1,y1,z1,bx,by,bz,color,3)
			dxDrawLine3D(x2,y2,z2,bx,by,bz,color,3)
			x1,y1,z1 = x1-bx,y1-by,z1-bz
			x2,y2,z2 = x2-bx,y2-by,z2-bz
			local math_sin,math_cos = math.sin,math.cos
			local delta_a = math.pi*0.0625
			distance3d = 0

			for a = delta_a/8,math.pi*0.5,delta_a/8 do
				local sina,cosa = math_sin(a),math_cos(a)
				local sinb,cosb = math_sin(a-delta_a/8),math_cos(a-delta_a/8)
				dxDrawLine3D(bx+x1*cosa+x2*sina,by+y1*cosa+y2*sina,bz+z1*cosa+z2*sina,
							bx+x1*cosb+x2*sinb,by+y1*cosb+y2*sinb,bz+z1*cosb+z2*sinb,tocolor(0,255,0,255),6)		
				distance3d = distance3d + getDistanceBetweenPoints3D(bx+x1*cosa+x2*sina,by+y1*cosa+y2*sina,bz+z1*cosa+z2*sina,bx+x1*cosb+x2*sinb,by+y1*cosb+y2*sinb,bz+z1*cosb+z2*sinb)
				advancedPathTable[key][20]=distance3d
			end
			
		elseif string.lower(curveType) == "linear" then
			dxDrawLine3D(x1,y1,z1,x2,y2,z2,tocolor(0,255,0,255),6)
			distance3d = getDistanceBetweenPoints3D(x1,y1,z1,x2,y2,z2)
			advancedPathTable[key][20]=distance3d
		end
		------------------------------------------------------------------------------------------------
		x1,y1,z1,x2,y2,z2 = 	advancedPathTable[key][1][1],advancedPathTable[key][1][2],advancedPathTable[key][1][3],
									advancedPathTable[key][2][1],advancedPathTable[key][2][2],advancedPathTable[key][2][3]
		bz = advancedPathTable[key][3][3]
		x1,y1,z1 = x1-bx,y1-by,z1-bz
		x2,y2,z2 = x2-bx,y2-by,z2-bz									
		local sx2,sy2 = getScreenFromWorldPosition(advancedPathTable[key][1][1],advancedPathTable[key][1][2],advancedPathTable[key][1][3],0x7FFFFFFF)
		if sx2 and sy2 then
			sina,cosa = math.cos(math.pi*0.0625/8),math.sin(math.pi*0.0625/8)
			dxDrawText("p "..key.." start m: "..round(distance3d,1).."  m/s:"..round(distance3d/(advancedPathTable[key][12]/1000),2).."\nSlope X: "..round(x1*-cosa+x2*sina,1).."\nSlope Y: "..round(y1*-cosa+y2*sina,1).."\nSlope Z: "..round(z1*-cosa+z2*sina,1),sx2,sy2+10)
		end
		local sx4,sy4 = getScreenFromWorldPosition(advancedPathTable[key][2][1],advancedPathTable[key][2][2],advancedPathTable[key][2][3],0x7FFFFFFF)
		if sx4 and sy4 then
			sina,cosa = math.cos(math.pi*0.5),math.sin(math.pi*0.5)
			dxDrawText("End p "..key.." \nSlope X: "..round(x1*-cosa+x2*sina,1).."\nSlope Y: "..round(y1*-cosa+y2*sina,1).."\nSlope Z: "..round(z1*-cosa+z2*sina,1),sx4,sy4-80)
		end	
		---------------------------------------------------------------------------------------------------
		local sx3,sy3 = getScreenFromWorldPosition(advancedPathTable[key][6][1],advancedPathTable[key][6][2],advancedPathTable[key][6][3],0x7FFFFFFF)
		if sx3 and sy3 then
			if timeingsSynced == true and advancedPathTable[key][19] ~= 0 then
				dxDrawText("cam p "..key.." start, m: "..round(advancedPathTable[key][21],1).."  m/s:"..round(advancedPathTable[key][21]/(advancedPathTable[key][19]/1000),2),sx3,sy3)
			else
				dxDrawText("cam p "..key.." start, m: "..round(advancedPathTable[key][21],1).."  m/s:"..round(advancedPathTable[key][21]/(advancedPathTable[key][12]/1000),2),sx3,sy3)
			end
		end
	end	
end

function drawVisablePath()
	if #advancedPathTable > 0 then
		for _key,row in ipairs(advancedPathTable) do
			drawConnectionBend(advancedPathTable[_key][3][1],advancedPathTable[_key][3][2],advancedPathTable[_key][1][1],advancedPathTable[_key][1][2],advancedPathTable[_key][1][3],advancedPathTable[_key][2][1],advancedPathTable[_key][2][2],advancedPathTable[_key][2][3],tocolor(255,0,0,255),advancedPathTable[_key][4],_key)
		end
	end
end
addEventHandler ( "onClientRender", getRootElement(), drawVisablePath)

function scrollTruwOptions(key,keyState)
	if basisPlaat and isElement(tabPannel) and guiGetSelectedTab(tabPannel) == advancedTab then
		local row, column = guiGridListGetSelectedItem ( pointsList )
		if row ~= -1 and column ~= -1 then
			if column == 5 or column == 10 or column == 15 then
				if key == "mouse_wheel_up" then
					if movingPathsIndex - 1 < 1 then
						movingPathsIndex = #movingpaths
					else
						movingPathsIndex = movingPathsIndex - 1
					end
				elseif key == "mouse_wheel_down" then
					if movingPathsIndex + 1 > #movingpaths then
						movingPathsIndex = 1
					else
						movingPathsIndex = movingPathsIndex + 1
					end
				end
				advancedPathTable[row+1][column] = movingpaths[movingPathsIndex]
				updateGridList()
			elseif column == 4 or column == 9 then
				if string.lower(advancedPathTable[row+1][column]) == "curved" then
					advancedPathTable[row+1][column] = "linear"
				else
					advancedPathTable[row+1][column] = "curved"
				end
				updateGridList()			
			end
		end
	end
end

bindKey("mouse_wheel_up","both",scrollTruwOptions)
bindKey("mouse_wheel_down","down",scrollTruwOptions)

function calculateSmoothCamPoints()
	if #advancedPathTable > 1 then
		for key,pathData in ipairs(advancedPathTable) do
			if key < #advancedPathTable then
			x1,y1,z1,x2,y2,z2,bx,by,bz = 		advancedPathTable[key][1][1],advancedPathTable[key][1][2],advancedPathTable[key][1][3],
											advancedPathTable[key][2][1],advancedPathTable[key][2][2],advancedPathTable[key][2][3],
											advancedPathTable[key][3][1],advancedPathTable[key][3][2],advancedPathTable[key][3][3]
			x3,y3,z3,x4,y4,z4,bx1,by1  = 	advancedPathTable[key+1][1][1],advancedPathTable[key+1][1][2],advancedPathTable[key+1][1][3],
											advancedPathTable[key+1][2][1],advancedPathTable[key+1][2][2],advancedPathTable[key+1][2][3],
											advancedPathTable[key+1][3][1],advancedPathTable[key+1][3][2]
				if math.abs(x2-x3) < 0.1 and math.abs(y2-y3) < 0.1 and math.abs(z2-z3) < 0.1 then
					advancedPathTable[key+1][3][1],advancedPathTable[key+1][3][2],advancedPathTable[key+1][3][3] = gslope(bx,x1,x2,x3,x4),gslope(by,y1,y2,y3,y4),gslope(bz,z1,z2,z3,z4)
				else
					outputChatBox("#FF0000[CameraTool]: #FFA500Something went wrong.(Some path's may not be smoothed.)",255,255,255,true)
				end
			end
		end
	end
end
		function fbase(a,b,c,d,e) f = 	(b - a)*(-math.sin(math.pi*0.5)) + 
										(c - a)*math.cos(math.pi*0.5) 
										return f end
		function gslope(a,b,c,d,e) g = (fbase(a,b,c,d,e) + 
										d*math.sin(math.pi*0.0625/8) - 
										e*math.cos(math.pi*0.0625/8)) / 
										(math.sin(math.pi*0.0625/8) - math.cos(math.pi*0.0625/8)) 
										return g end