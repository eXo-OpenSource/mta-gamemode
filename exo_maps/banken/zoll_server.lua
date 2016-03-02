local mautSchranken = {}
local mautPed = {}
local mautCol = {}

local schrankenX,schrankenY,schrankenZ = 0,0,0
local schrankenRY,schrankenRZ = 0,0
local schrankenArt = ""

local mautI = 1

function spawnMautPed(ID,pedX,pedY,pedZ,pedRZ)
	if isElement(mautPed[ID]) then destroyElement(mautPed[ID]) end
	mautPed[ID] = createPed(71,pedX,pedY,pedZ,pedRZ)
	
	setPedAnimation(mautPed[ID], "cop_ambient", "Coplook_loop",-1,true,false,true)
	setElementFrozen(mautPed[ID],true)
	addEventHandler("onClientPedDamage", mautPed[ID], function()
		setPedAnimation(mautPed[ID], "cop_ambient", "Coplook_loop",-1,true,false,true)
	end)
	
	addEventHandler("onPedWasted",mautPed[ID],function(ammo,killer)
		suspect_server_func(killer,"Mord")
		suspect_server_func(killer,"Mord")
		suspect_server_func(killer,"Mord")
		setTimer(spawnMautPed,1000*60*5,1,ID,pedX,pedY,pedZ,pedRZ)
	end)

end

function createMautStation(name,richtung,schrankenX,schrankenY,schrankenZ,schrankenRY,schrankenRZ,schrankenDrehung,pedX,pedY,pedZ,pedRZ,colX,colY,colZ)
	mautSchranken[mautI] = createObject(968,schrankenX,schrankenY,schrankenZ,0,schrankenRY,schrankenRZ)
	spawnMautPed(mautI,pedX,pedY,pedZ,pedRZ)
	
	mautCol[mautI] = createColSphere(colX,colY,colZ,3)
	
	setElementData(mautSchranken[mautI] ,"block",0)
	setElementData(mautSchranken[mautI] ,"closed",1)
	setElementData(mautSchranken[mautI] ,"closedRotY",schrankenRY)
	setElementData(mautSchranken[mautI] ,"Drehung",schrankenDrehung)
	
	setElementData(mautCol[mautI],"ID",mautI)
	setElementData(mautCol[mautI],"Drehung",schrankenDrehung)
	setElementData(mautCol[mautI],"Name",name)
	setElementData(mautCol[mautI],"Richtung",richtung)
	
	addEventHandler("onColShapeHit",mautCol[mautI],onMautColHit)
	addEventHandler("onColShapeLeave",mautCol[mautI],onMautColLeave)
	mautI = mautI+1
end

function openAllMautSchranken()
	local mautanzahl = mautI-1
	for ID = 0,mautanzahl,1 do
		local schranke = mautSchranken[ID]
		if isElement(schranke) then
			local art = getElementData(schranke,"Drehung")
			openMautSchranke(player,schranke,art)
		end
	end
end

function closeAllMautSchranken()
	local mautanzahl = mautI-1
	for ID = 0,mautanzahl,1 do
		local schranke = mautSchranken[ID]
		if isElement(schranke) then
			local art = getElementData(schranke,"Drehung")
			closeMautSchranke(player,schranke,art)
		end
	end
end

function onMautColHit(player,dim)
	if dim then
		if getElementType(player) == "player" then
			if isPedInVehicle(player) then
				if getPedOccupiedVehicleSeat(player) == 0 then
					local ID = getElementData(source,"ID")
					local art = getElementData(source,"Drehung")
					if getElementData(mautSchranken[ID],"closed") == 1 then
						exoSetElementData(player,"mautschranke",ID)
						--outputChatBox(art)
						outputChatBox("",player,255,0,0)
						--outputChatBox("Willkommen bei der Mautstation "..getElementData(source,"Name").." Richtung: "..getElementData(source,"Richtung").."!",player,255,0,0)
						local mautpass =  exports.exo_inventar:getPlayerItemAnzahl (player,"Mautpass")
						
						if isFDuty(player) then
							openMaut(player,ID,art)
						else
							if mautpass > 0 then
								triggerClientEvent ( player, "showDrawnText", getRootElement(), "Willkommen bei der Mautstation "..getElementData(source,"Name").."!\nDu hast einen Mautpass, du kannst kostenlos passieren!\n\n\n", 3500, 0, 255, 0)
								openMaut(player,ID,art)
							else
								triggerClientEvent ( player, "showDrawnText", getRootElement(), "Willkommen bei der Mautstration "..getElementData(source,"Name").."!\nDrücke auf Z oder tippe /maut um ein Ticket zu kaufen!\n\n\n", 5000, 0, 255, 0)
								infobox(player,"Info: Du kannst am 24/7 einen Mautpass erwerben, dann fährst du kostenlos und unkompliziert durch die Stationen!",5000,50,200,255)
								bindKey(player,"z","down",buymaut)
							end
						end
					end
				end
			end
		end
	end
end

function onMautColLeave(player,dim)
	if dim then
		if getElementType(player) == "player" then
			if isPedInVehicle(player) then
				if getPedOccupiedVehicleSeat(player) == 0 then
					setTimer(function(player)
						exoSetElementData(player,"mautschranke",0)
						unbindKey(player,"z","down",buymaut)
					end,5000,1,player)
				end
			end
		end
	end
end

function buymaut(player)
		
		local ID = exoGetElementData(player,"mautschranke")
		--outputChatBox(ID)
		if ID then
			if ID > 0 then
				local sx,sy,sz = getElementPosition(mautSchranken[ID])
				local x,y,z = getElementPosition(player)
				if getDistanceBetweenPoints3D(sx,sy,sz,x,y,z) < 10 then
					if exoGetElementData(player,"money") >= 25 then
						if getElementData(mautSchranken[ID],"closed") == 1 then
							local art = getElementData(mautSchranken[ID],"Drehung")
							takePlayerSaveMoney(player,25)
							setPedAnimation(player, "CAR", "Sit_relaxed", -1, true, false, false)
							setTimer(setPedAnimation,3000,1,player)
							openMaut(player,ID,art)
							unbindKey(player,"z","down",buymaut)
							outputChatBox("Vielen Dank! Sie dürfen passieren!",player,0,255,0)
							exoGetElementData(player,"mautschranke",0)
						end
					else
						outputChatBox("Du hast nicht genug Geld! (25$)",player,255,0,0)
					end
				else
					outputChatBox("Du bist an keiner Mautstation! 1",player,255,0,0)
				end
			else
				outputChatBox("Du bist an keiner Mautstation! 2",player,255,0,0)
			end
		else
			outputChatBox("Du bist an keiner Mautstation! 3",player,255,0,0)
		end
	exoGetElementData(player,"mautschranke",0)
end
addCommandHandler("maut",buymaut)


function openMaut(player,ID,art)
	if getElementData(mautSchranken[ID],"closed") == 1 then
		openMautSchranke(player,mautSchranken[ID],art)
		setTimer(function()
			if getElementData(mautSchranken[ID],"closed") == 0 then
				closeMautSchranke(player,mautSchranken[ID],art)
			end
		end,5500,1)
	end
end

schrankenX,schrankenY,schrankenZ = 49.2002,-1527.7998,4.85
schrankenRY,schrankenRZ = 90,83.749
pedX,pedY,pedZ,pedRZ = 53.22265625,-1529.474609375,5.2642478942871,350
colX,colY,colZ = 54.904296875,-1524.8759765625,5.0139408111572
schrankenArt = "gedreht"
createMautStation("LS-Bridge","out",schrankenX,schrankenY,schrankenZ,schrankenRY,schrankenRZ,schrankenArt,pedX,pedY,pedZ,pedRZ,colX,colY,colZ)

schrankenX,schrankenY,schrankenZ = 51.2002,-1535.4004,4.8
schrankenRY,schrankenRZ = 270,83.749
pedX,pedY,pedZ,pedRZ =  47.08203125,-1532.78515625,5.3329129219055,171.57
colX,colY,colZ = 44.822265625,-1538.171875,5.1842360496521
schrankenArt = "normal"
createMautStation("LS-Bridge","in",schrankenX,schrankenY,schrankenZ,schrankenRY,schrankenRZ,schrankenArt,pedX,pedY,pedZ,pedRZ,colX,colY,colZ)

schrankenX,schrankenY,schrankenZ = -10.59961,-1360.2998,10.61
schrankenRY,schrankenRZ = 90,309.298
pedX,pedY,pedZ,pedRZ =  -8.6279296875,-1368.779296875,11.0703125,37
colX,colY,colZ =  -12.6552734375,-1366.685546875,10.844497680664
schrankenArt = "gedreht"
createMautStation("Highway West","in",schrankenX,schrankenY,schrankenZ,schrankenRY,schrankenRZ,schrankenArt,pedX,pedY,pedZ,pedRZ,colX,colY,colZ)

schrankenX,schrankenY,schrankenZ = -24.6,-1349.3,10.8
schrankenRY,schrankenRZ = 90,125.548
pedX,pedY,pedZ,pedRZ =  -26.7607421875,-1340.541015625,11.0703125,221
colX,colY,colZ =  -22.8759765625,-1342.8603515625,10.966299057007
schrankenArt = "gedreht"
createMautStation("Highway West","out",schrankenX,schrankenY,schrankenZ,schrankenRY,schrankenRZ,schrankenArt,pedX,pedY,pedZ,pedRZ,colX,colY,colZ)

schrankenX,schrankenY,schrankenZ = 1746.4,519,27.9
schrankenRY,schrankenRZ = 90,161.241
pedX,pedY,pedZ,pedRZ =   1735.3134765625,511.05078125,28.936729431152,249.38
colX,colY,colZ =  1740.29296875,513.5400390625,28.395584106445
schrankenArt = "gedreht"
createMautStation("Las Venturas - 1","out",schrankenX,schrankenY,schrankenZ,schrankenRY,schrankenRZ,schrankenArt,pedX,pedY,pedZ,pedRZ,colX,colY,colZ)

schrankenX,schrankenY,schrankenZ = 1748,518.40002,27.9
schrankenRY,schrankenRZ = 90,340.499
pedX,pedY,pedZ,pedRZ =   1744.3662109375,507.87109375,28.939765930176,249.38
colX,colY,colZ =  1748.802734375,508.3525390625,28.524265289307
schrankenArt = "gedreht"
createMautStation("Las Venturas - 2","out",schrankenX,schrankenY,schrankenZ,schrankenRY,schrankenRZ,schrankenArt,pedX,pedY,pedZ,pedRZ,colX,colY,colZ)

schrankenX,schrankenY,schrankenZ = 1727.4,514.5,28.7
schrankenRY,schrankenRZ = 90,339.736
pedX,pedY,pedZ,pedRZ =   1737.7568359375,522.5888671875,28.321184158325,71.39
colX,colY,colZ =  1733.033203125,520.7373046875,28.151374816895
schrankenArt = "gedreht"
createMautStation("Las Venturas - 1","in",schrankenX,schrankenY,schrankenZ,schrankenRY,schrankenRZ,schrankenArt,pedX,pedY,pedZ,pedRZ,colX,colY,colZ)

schrankenX,schrankenY,schrankenZ = 1725.9,515,28.7
schrankenRY,schrankenRZ = 90,159.244
pedX,pedY,pedZ,pedRZ =   1729.7880859375,525.5390625,28.317928314209,71.39
colX,colY,colZ =  1725.921875,525.330078125,28.030838012695
schrankenArt = "gedreht"
createMautStation("Las Venturas - 2","in",schrankenX,schrankenY,schrankenZ,schrankenRY,schrankenRZ,schrankenArt,pedX,pedY,pedZ,pedRZ,colX,colY,colZ)

schrankenX,schrankenY,schrankenZ = 523.5,468.2,18.7
schrankenRY,schrankenRZ = 270,35.25
pedX,pedY,pedZ,pedRZ =   520.26953125,471.259765625,18.9296875,124,67
colX,colY,colZ =  516.5751953125,471.66015625,18.9296875
schrankenArt = "normal"
createMautStation("Fallow-Bridge","in",schrankenX,schrankenY,schrankenZ,schrankenRY,schrankenRZ,schrankenArt,pedX,pedY,pedZ,pedRZ,colX,colY,colZ)

schrankenX,schrankenY,schrankenZ = 518.7002,474.7998,18.6
schrankenRY,schrankenRZ = 270,213.992
pedX,pedY,pedZ,pedRZ =   522.11328125,472.4873046875,18.9296875,303
colX,colY,colZ =   524.4921875,473.197265625,18.9296875
schrankenArt = "normal"
createMautStation("Fallow-Bridge","out",schrankenX,schrankenY,schrankenZ,schrankenRY,schrankenRZ,schrankenArt,pedX,pedY,pedZ,pedRZ,colX,colY,colZ)

schrankenX,schrankenY,schrankenZ = -179.8,323.5,11.8
schrankenRY,schrankenRZ = 270,344.75
pedX,pedY,pedZ,pedRZ =   -179.25390625,327.5732421875,12.078125,54
colX,colY,colZ =   -181.5615234375,328.9677734375,12.078125
schrankenArt = "normal"
createMautStation("Martin-Bridge","in",schrankenX,schrankenY,schrankenZ,schrankenRY,schrankenRZ,schrankenArt,pedX,pedY,pedZ,pedRZ,colX,colY,colZ)

schrankenX,schrankenY,schrankenZ = -177.39999,331.39999,11.8
schrankenRY,schrankenRZ = 270,163.748
pedX,pedY,pedZ,pedRZ =   -177.1640625,326.9453125,12.078125,252
colX,colY,colZ =    -175.345703125,323.70703125,12.078125
schrankenArt = "normal"
createMautStation("Martin-Bridge","out",schrankenX,schrankenY,schrankenZ,schrankenRY,schrankenRZ,schrankenArt,pedX,pedY,pedZ,pedRZ,colX,colY,colZ)

schrankenX,schrankenY,schrankenZ = -966.29999,-334.29999,36.2
schrankenRY,schrankenRZ = 90,169
pedX,pedY,pedZ,pedRZ =    -966.1669921875,-330.16796875,36.302635192871,79
colX,colY,colZ = -968.2548828125,-327.6416015625,36.358531951904
schrankenArt = "gedreht"
createMautStation("Red County","in",schrankenX,schrankenY,schrankenZ,schrankenRY,schrankenRZ,schrankenArt,pedX,pedY,pedZ,pedRZ,colX,colY,colZ)

schrankenX,schrankenY,schrankenZ = -963.70001,-326.20001,36.1
schrankenRY,schrankenRZ = 90,348.99
pedX,pedY,pedZ,pedRZ =     -964.0576171875,-330.31640625,36.251399993896,256
colX,colY,colZ =  -961.896484375,-333.7998046875,36.150726318359
schrankenArt = "gedreht"
createMautStation("Red County","out",schrankenX,schrankenY,schrankenZ,schrankenRY,schrankenRZ,schrankenArt,pedX,pedY,pedZ,pedRZ,colX,colY,colZ)

schrankenX,schrankenY,schrankenZ = -74,-890.5,15.5
schrankenRY,schrankenRZ = 90,155.25
pedX,pedY,pedZ,pedRZ =     -73.494140625,-886.1689453125,15.470561027527,65.5
colX,colY,colZ = -75.3134765625,-883.4052734375,15.38240814209
schrankenArt = "gedreht"
createMautStation("Flint County","out",schrankenX,schrankenY,schrankenZ,schrankenRY,schrankenRZ,schrankenArt,pedX,pedY,pedZ,pedRZ,colX,colY,colZ)

schrankenX,schrankenY,schrankenZ = -70.75999,-882.90002,15.1
schrankenRY,schrankenRZ = 90,333.248
pedX,pedY,pedZ,pedRZ =      -71.646484375,-887.166015625,15.469886779785,241
colX,colY,colZ =  -70.4169921875,-889.560546875,15.554614067078
schrankenArt = "gedreht"
createMautStation("Flint County","in",schrankenX,schrankenY,schrankenZ,schrankenRY,schrankenRZ,schrankenArt,pedX,pedY,pedZ,pedRZ,colX,colY,colZ)

function openMautSchranke(player,barrier,art)
	local grad=0
	if art == "gedreht" then
		grad = -90
	else
		grad = 90
	end

	local blockFunction = getElementData(barrier,"block")
	if not blockFunction then blockFunction = 0 end
	if(getTickCount() - blockFunction > 3050) then 
		local tx,ty,tz = getElementPosition(barrier)
		moveObject (barrier, 3000, tx,ty,tz, 0, grad, 0, "OutBounce")
		setElementData(barrier,"block",getTickCount())
		setElementData(barrier,"closed",0)
   end
end


function closeMautSchranke(player,barrier,art)
local grad=0
	if art == "gedreht" then
		grad = 90
	else
		grad = -90
	end
	local blockFunction = getElementData(barrier,"block")
	if not blockFunction then blockFunction = 0 end
	if(getTickCount() - blockFunction > 3050) then 
		local tx,ty,tz = getElementPosition(barrier)
		moveObject (barrier, 3000, tx,ty,tz, 0, grad, 0, "InOutQuad")
		setElementData(barrier,"closed",1)
		setElementData(barrier,"block",getTickCount())
		
		setTimer(function()
			local rx,ry,rz = getElementRotation(barrier)
			setElementRotation(barrier,rx,getElementData(barrier,"closedRotY"),rz)
		end,3100,1)
		
		
    end
end
--[[
" rotX="0" rotY="
" rotX="0" rotY=",
]]
