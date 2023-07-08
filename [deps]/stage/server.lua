function stage(player, cmd, pw)
	if pw and pw == "eXoTrailerTeam" then
		outputChatBox("Stage-Tool aktiviert", player, 255, 0, 0)
		triggerClientEvent(player,"doLoadStage", player)
		loadStage()
	else
		outputChatBox("Falsches/Kein Passwort!", player, 255, 0, 0)
	end
end
addCommandHandler("stage", stage)

local stageLoaded = false

function loadStage()
	
	if stageLoaded == true then return end
	stageLoaded = true
	-- Stage resource for MTA:SA
	-- author: vovo4ka   <zolotayapipka@gmail.com>
	--
	-- my youtube channel with tutorials
	-- http://www.youtube.com/user/vovo4kaX
	--
	-- thx for [UA]MacSYS and gephaest for support and inspiration ;)
	-- also respect to Gamesnert and all MTA community for new ideas and tips

	-- change pass
	local pass = "eXoTrailerTeam"


	local recData = {} --
	-- 1.4.5
	local recKeyData = {} -- keyframe chunks

	local rcnt = 1

	local mapResource = nil
	local direct = nil
	local totalkf = 0



	-- (c) Lua-wiki.org
	-- Table serialization/load
	  -- declare local variables
	   --// exportstring( string )
	   --// returns a "Lua" portable version of the string
	   local function exportstring( s )
		  s = string.format( "%q",s )
		  -- to replace
		  s = string.gsub( s,"\\\n","\\n" )
		  s = string.gsub( s,"\r","\\r" )
		  s = string.gsub( s,string.char(26),"\"..string.char(26)..\"" )
		  return s
	   end
	--// The Save Function
	function table.save(  tbl,filename )

		local saveIterLimit = 0
	   
	   local charS,charE = "   ","\n"
	   local file,err
	   -- create a pseudo file that writes to a string and return the string
	   if not filename then
		  file =  { write = function( self,newstr ) self.str = self.str..newstr end, str = "" }
		  charS,charE = "",""
	   -- write table to tmpfile
	   elseif filename == true or filename == 1 then
		  charS,charE,file = "","",io.tmpfile()
	   -- write table to file
	   -- use io.open here rather than io.output, since in windows when clicking on a file opened with io.output will create an error
	   else
		  file,err = io.open( filename, "w" )
		  if err then return _,err end
	   end
	   -- initiate variables for save procedure
	   local tables,lookup = { tbl },{ [tbl] = 1 }
	   file:write( "return {"..charE )
	   for idx,t in ipairs( tables ) do
		  if filename and filename ~= true and filename ~= 1 then
			 file:write( "-- Table: {"..idx.."}"..charE )
		  end
		  file:write( "{"..charE )
		  local thandled = {}
		  for i,v in ipairs( t ) do
			 thandled[i] = true
			 -- escape functions and userdata
			 if type( v ) ~= "userdata" then
				-- only handle value
				if type( v ) == "table" then
				   if not lookup[v] then
					  table.insert( tables, v )
					  lookup[v] = #tables
				   end
				   file:write( charS.."{"..lookup[v].."},"..charE )
				elseif type( v ) == "number" then
				if (math.floor(v)==v) then
					file:write(  charS..tostring(v)..","..charE )
					else
					file:write(  charS.. string.format("%.6f",v)..","..charE )
					end
				elseif type( v ) == "function" then
				   file:write( charS.."loadstring("..exportstring(string.dump( v )).."),"..charE )
				else
				   local value =  ( type( v ) == "string" and exportstring( v ) ) or tostring( v )
				   file:write(  charS..value..","..charE )
				end
			 end
		  end
		  for i,v in pairs( t ) do
			 -- escape functions and userdata
			 if (not thandled[i]) and type( v ) ~= "userdata" then
				-- handle index
				if type( i ) == "table" then
				   if not lookup[i] then
					  table.insert( tables,i )
					  lookup[i] = #tables
				   end
				   file:write( charS.."[{"..lookup[i].."}]=" )
				else
				   local index = ( type( i ) == "string" and "["..exportstring( i ).."]" ) or string.format( "[%d]",i )
				   file:write( charS..index.."=" )
				end
				-- handle value
				if type( v ) == "table" then
				   if not lookup[v] then
					  table.insert( tables,v )
					  lookup[v] = #tables
				   end
				   file:write( "{"..lookup[v].."},"..charE )
				elseif type( v ) == "function" then
				   file:write( "loadstring("..exportstring(string.dump( v )).."),"..charE )
				elseif type( v ) == "number" then
				if (math.floor(v)==v) then
					file:write(  charS..tostring(v)..","..charE )
					else
					file:write(  charS.. string.format("%.6f",v)..","..charE )
					end
				else
				   local value =  ( type( v ) == "string" and exportstring( v ) ) or tostring( v )
				   file:write( value..","..charE )
				end
			 end
			saveIterLimit = saveIterLimit + 1
			if (saveIterLimit>2000) then
				saveIterLimit = 0
				coroutine.yield()
			end
		  end
		  file:write( "},"..charE )
	   end
	   file:write( "}" )
	   -- Return Values
	   -- return stringtable from string
	   if not filename then
		  -- set marker for stringtable
		  return file.str.."--|"
	   -- return stringttable from file
	   elseif filename == true or filename == 1 then
		  file:seek ( "set" )
		  -- no need to close file, it gets closed and removed automatically
		  -- set marker for stringtable
		  return file:read( "*a" ).."--|"
	   -- close file and return 1
	   else
		  file:close()
		  return 1
	   end
	end

	--// The Load Function
	function table.load( sfile )
	   -- catch marker for stringtable
	   tables,err = loadstring( sfile )
	   --[[if string.sub( sfile,-3,-1 ) == "--|" then
		  tables,err = loadstring( sfile )
	   else
		  tables,err = loadfile( sfile )
	   end]]--
	   if err then return _,err
	   end
	   tables = tables()
	   for idx = 1,#tables do
		  local tolinkv,tolinki = {},{}
		  for i,v in pairs( tables[idx] ) do
			 if type( v ) == "table" and tables[v[1]] then
				table.insert( tolinkv,{ i,tables[v[1]] } )
			 end
			 if type( i ) == "table" and tables[i[1]] then
				table.insert( tolinki,{ i,tables[i[1]] } )
			 end
		  end
		  -- link values, first due to possible changes of indices
		  for _,v in ipairs( tolinkv ) do
			 tables[idx][v[1]] = v[2]
		  end
		  -- link indices
		  for _,v in ipairs( tolinki ) do
			 tables[idx][v[2]],tables[idx][v[1]] =  tables[idx][v[1]],nil
		  end
	   end
	   return tables[1]
	end


	----
	local skip_mode = 1
	local skip_fi = 1
	local par1 = 2.0
	local par2 = 3.0
	local par3 = 15.0
	local par4 = 3.0
	local par5 = 2.0

	function validUser(id)
	local res = false
	if (id==direct) then res = true end
	return res
	end

	function syncQuality()
	--triggerClientEvent ( source, "onSetQuality", getRootElement(), skip_mode,skip_fi,par1,par2,par3,par4,par5)
	spawnPlayer (source, 1430, -973, 58, 0, math.random (0,288)) -- spawns player with random skin
	fadeCamera (source, true)
	setCameraTarget (source, source)	
	end
	addEventHandler ( "onPlayerJoin", getRootElement(), syncQuality )

	function SetPedWeap(id)
	--give weapon
	local ped = getElementByID(recData[id]["pedID"])
	for i = 0,12 do
		giveWeapon (ped, recData[id]["init"]["initWeap"][i][1])
		setWeaponAmmo (ped, recData[id]["init"]["initWeap"][i][1], 10000 )--recData[id]["init"]["initWeap"][i][2])
		end
	setElementHealth(ped,  recData[id]["init"]["initHeal"])
	setPedWeaponSlot (ped, recData[id]["init"]["initWeapSlot"])
	end
	--setTimer(ammo, 2000, 1)

	function callServerFunction(funcname, ...)
		local arg = { ... }
		if (arg[1]) then
			for key, value in next, arg do arg[key] = tonumber(value) or value end
		end
		loadstring("return "..funcname)()(unpack(arg))
	end
	addEvent("onClientCallsServerFunction", true)
	addEventHandler("onClientCallsServerFunction", getRootElement() , callServerFunction)

	function warpPed(ped, vehID, seat)
		if (isPedDead(ped)==false) then
		warpPedIntoVehicle ( ped, getElementByID(vehID), seat)
		end
		--outputChatBox (ped)
	end
	addEvent("onWarpPedInVeh", true)
	addEventHandler("onWarpPedInVeh", getRootElement() , warpPed)

	function remPed(ped, px,py,pz)
		--warpPedIntoVehicle ( ped, getElementByID(vehID), seat)
		removePedFromVehicle (ped)
		setElementPosition(ped, px, py, pz ,true)
		--outputChatBox ( "rem!")
	end
	addEvent("onRemPedFromVeh", true)
	addEventHandler("onRemPedFromVeh", getRootElement() , remPed)

	function setQuality(skip_mode0,skip_fi0,par10,par20,par30,par40,par50)
		if (validUser(source)) then
		--triggerClientEvent ( "onSetQuality", getRootElement(), skip_mode,skip_fi,par1,par2,par3,par4,par5)
		skip_mode = skip_mode0
		skip_fi= skip_fi0
		par1= par10
		par2= par20
		par3= par30
		par4= par40
		par5= par50
		else
		outputChatBox ( "Login as director (press Login in Stage menu)", source, 255, 50, 50 )
		end
	end
	addEvent("clientQualitySet", true)
	addEventHandler("clientQualitySet", getRootElement() , setQuality)

	-- 1.4.5
	-- some cheating with execution time limit
	local savingTimer = nil
	local savingProgress = ""
	local savingThread = nil

	function coroutine_resume_manager()
		local state = coroutine.status(savingThread)
		if (state=="dead") then
			killTimer(savingTimer)
			savingTimer = nil
			savingThread = nil
			savingProgress = ""
			--outputChatBox("dead")
		else
			if (state=="suspended") then
			--
				--outputChatBox("resumed!")
				coroutine.resume(savingThread)
				
				savingProgress = savingProgress .. "#"
				if (string.len(savingProgress)>32) then
					savingProgress = "Saving progress: #"
				end
			end
		end
		triggerClientEvent ( "showSavingProgressGUI", getRootElement(), savingProgress)
	end

	function saveToFile(rname,fname,over)
	if (validUser(source))and(fname~="") then
		local tm = {}
		tm[0] = recData
		if (mapResource~=nil)and(mapResource~=true) then
			tm[1] = getResourceName(mapResource)
			end
		tm[2] = rcnt
		tm[3] = recKeyData
		

		local f = nil
		if (rname=="") then
			rname = getResourceName(getThisResource())
			else
			 if ( hasObjectPermissionTo ( getThisResource (), "general.ModifyOtherObjects", true )==false ) then
				outputChatBox ( "Access denied. Configure ACL for write in other resources", source, 255, 50, 50 )
				end
			end
		local f2= fileOpen(":"..rname.."/"..fname..".stagedata")
		if (over==false)and(f2==false) then
			f = fileCreate( ":"..rname.."/"..fname..".stagedata" )
			else
			if (over==true) then
				if (f2~=false) then
					fileClose(f2)
					end
				f = fileCreate( ":"..rname.."/"..fname..".stagedata" )
				else
				outputChatBox ( "File Exists "..fname, source, 255, 50, 50 )
				end
			end
		if (f) then
			-- 1.4.5
				savingThread = coroutine.create(function ()
				outputChatBox ( "Please wait until the data will be saved....")
				local data = table.save(tm)
				fileWrite(f, data)
				fileClose(f)
				outputChatBox ( "Data saved in "..fname, source, 50, 255, 50 )
			end)
			savingProgress = "Saving progress: "
			savingTimer = setTimer (coroutine_resume_manager, 200, 0)
			coroutine.resume(savingThread)
			
			
			else
			outputChatBox ( "Create File error "..fname, source, 255, 50, 50 )
			end
		else
		outputChatBox ( "Login as director (press Login in Stage menu)", source, 255, 50, 50 )
		end
	end
	addEvent("clientWantSave", true)
	addEventHandler("clientWantSave", getRootElement() ,saveToFile)

	function ReCreatePeds()
	for i, par in pairs(recData) do
		local ped = createPed (par["init"]["initSkin"], par["init"]["initPos"][1],par["init"]["initPos"][2],par["init"]["initPos"][3])
		setElementID ( ped, "ped "..i)
		--recData[i]["pedID"] = "ped "..i
		end
	end

	function loadFromFile(rname,fname)
	if (validUser(source))and(fname~="") then
		local f = nil
		if (rname~="") then
			f = fileOpen( ":"..rname.."/"..fname..".stagedata" )
			else
			f = fileOpen(":"..getResourceName(getThisResource()).."/"..fname..".stagedata")
			end
		if (f) then
			local data = fileRead(f,fileGetSize(f))
			local tm = table.load(data)
			if (tm~=nil) then
				if (tm[1]~=nil) then
					local res = getResourceFromName(tm[1])
					if (res) then
						if (getResourceState (res)=="running") then
							mapResource = res
							clearScene(source)
							recData = tm[0]
							rcnt = tm[2]
							recKeyData = tm[3]
							ReCreatePeds()
							outputChatBox ( "Map resource "..tm[1] .. " was selected", thePlayer, 50, 255, 50 )
							outputChatBox ( "Data loaded "..fname, source, 50, 255, 50 )
							else
							outputChatBox ( "Required map resource "..tm[1].." doesn't started. Start resource in server console", thePlayer, 255, 0, 0 )
							end
						else
						outputChatBox ( "WARNING: Map Resource "..tm[1].." doesnt exist", source, 255, 50, 50 )
						end
					else
					clearScene(source)
					recData = tm[0]
					rcnt = tm[2]
					ReCreatePeds()
					outputChatBox ( "Data loaded "..fname, source, 50, 255, 50 )
					fileClose(f)
					end
				else
				outputChatBox ( "unknown format "..fname, source, 255, 50, 50 )
				end
			else
			outputChatBox ( "File not exists "..fname, source, 255, 50, 50 )
			end
		else
		outputChatBox ( "Login as director (press Login in Stage menu)", source, 255, 50, 50 )
		end
	end
	addEvent("clientWantLoad", true)
	addEventHandler("clientWantLoad", getRootElement() , loadFromFile)

	-- 1.4.5
	local sendingIndexes = {}
	local sendingCurrentIndex = 1
	local sendingCurrentValue = 1
	local sendingTimer = nil
	-- for progress visualisation
	local sendingTotalChunks = 0
	local sendingCurrentChunk = 0

	function sendingDataTimerCallback(action1_name, action2_name, ext_data)
		-- 
		local flag_ind = sendingCurrentIndex
		local flag_ind2 = -5
		
		local force_quit = false
		while ((flag_ind~=flag_ind2)and(force_quit==false)) do
			flag_ind2 = flag_ind
			-----------------------------------------
			ind = sendingIndexes[sendingCurrentIndex]
			local tempData = {}
			tempData["target"] = ind
			tempData["data"] = recKeyData[ind][sendingCurrentValue]
			tempData["total"] = sendingTotalChunks
			tempData["curr"] = sendingCurrentChunk
			triggerClientEvent ( "recievKeyframeChunk", getRootElement(), tempData)
			sendingCurrentValue = sendingCurrentValue + 1
			
			sendingCurrentChunk = sendingCurrentChunk + 1	-- progress bar
			if (sendingCurrentValue>#recKeyData[ind]) then
			-- swithing to the next ped
				sendingCurrentValue = 1
				sendingCurrentIndex = sendingCurrentIndex + 1
				-- if all data sent
				if (sendingCurrentIndex>#sendingIndexes) then
					-- sending data complete
					killTimer(sendingTimer)
					sendingTimer = nil
					force_quit = true
					-- triggering client events
					if (action1_name~=nil) then
						triggerClientEvent ( action1_name, getRootElement(), ext_data)
					end
					if (action2_name~=nil) then
						triggerClientEvent ( action2_name, getRootElement(), ext_data)
					end
				end
			end
			flag_ind = sendingCurrentIndex
			--if (flag_ind2 ~= flag_ind)and(force_quit==false) then
			--	outputChatBox("burst download")
			--	else
			--	outputChatBox("default download")
			--end
		end
	end
	-- 1.4.5
	-- send data to all clients and triggerClientActions action1_name and action2_name (may be nil)
	function sendDataAndTriggerClientEvent(action1_name, action2_name, ext_data)
		
		if (sendingTimer~=nil) then
			outputChatBox("WARNING: server: too high sending rate!")
			killTimer(sendingTimer)
		end
		
		-- initialization
		sendingIndexes = {}
		local ind_cnt = 1
		sendingTotalChunks = 0
		
		for i, par in pairs(recKeyData) do
			--outputChatBox("indexes "..i)
			sendingIndexes[ind_cnt] =  i
			sendingTotalChunks = sendingTotalChunks + #recKeyData[i]
			ind_cnt = ind_cnt + 1
			end
				
		triggerClientEvent ( "recieveSceneData", getRootElement(), recData)
		
		if (#sendingIndexes>0) then	
			sendingCurrentIndex = 1
			sendingCurrentValue = 1
			
			sendingCurrentChunk = 1
			
			-- send data
			
			sendingTimer = setTimer ( sendingDataTimerCallback, 60, 0, action1_name, action2_name, ext_data)
		else
			-- triggering client events if there are no data
			if (action1_name~=nil) then
				triggerClientEvent ( action1_name, getRootElement(), ext_data)
			end
			if (action2_name~=nil) then
				triggerClientEvent ( action2_name, getRootElement(), ext_data)
			end	
		end
	end

	function clientWantRecPlay()
		if (validUser(source)) then
		triggerClientEvent ( source, "onSetQuality", getRootElement(), skip_mode,skip_fi,par1,par2,par3,par4,par5)
		ResetScene()
		sendDataAndTriggerClientEvent("onPlay", "onBeginRec", "rec")
		--triggerClientEvent ( "onPlay", getRootElement(), recData)
		--triggerClientEvent ( "onBeginRec", getRootElement())
		else
		outputChatBox ( "Login as director (press Login in Stage menu)", source, 255, 50, 50 )
		end
	end
	addEvent("onClientWantRecPlay", true)
	addEventHandler("onClientWantRecPlay", getRootElement() , clientWantRecPlay)

	function clientWantStopRecPlay()
	if (validUser(source)) then
		triggerClientEvent ( "onStopPlay", getRootElement())
		triggerClientEvent ( "onStopRec", getRootElement())
		ResetScene()
		else
		outputChatBox ( "Login as director (press Login in Stage menu)", source, 255, 50, 50 )
		end
	end
	addEvent("onClientWantStopRecPlay", true)
	addEventHandler("onClientWantStopRecPlay", getRootElement() , clientWantStopRecPlay)


	function clientWantRec()
		if (validUser(source)) then
		triggerClientEvent ( source, "onSetQuality", getRootElement(), skip_mode,skip_fi,par1,par2,par3,par4,par5)
		triggerClientEvent ( "onBeginRec", getRootElement())
		else
		outputChatBox ( "Login as director (press Login in Stage menu)", source, 255, 50, 50 )
		end
	end
	addEvent("onClientWantRec", true)
	addEventHandler("onClientWantRec", getRootElement() , clientWantRec)


	function clientWantStopPlay()
		if (validUser(source)) then
		triggerClientEvent ( "onStopPlay", getRootElement())
		else
		outputChatBox ( "Login as director (press Login in Stage menu)", source, 255, 50, 50 )
		end	
	end
	addEvent("onClientWantStopPlay", true)
	addEventHandler("onClientWantStopPlay", getRootElement() , clientWantStopPlay)

	function clientWantStopRec()
		if (validUser(source)) then
		triggerClientEvent ( "onStopRec", getRootElement())
		else
		outputChatBox ( "Login as director (press Login in Stage menu)", source, 255, 50, 50 )
		end	
	end
	addEvent("onClientWantStopRec", true)
	addEventHandler("onClientWantStopRec", getRootElement() , clientWantStopRec)

	function clientWantPlay()
		if (validUser(source)) then
		ResetScene()
		sendDataAndTriggerClientEvent("onPlay", nil, "play")
		--triggerClientEvent ( "onPlay", getRootElement(), recData) 
		else
		outputChatBox ( "Login as director (press Login in Stage menu)", source, 255, 50, 50 )
		end	
	end
	addEvent("onClientWantPlay", true)
	addEventHandler( "onClientWantPlay", getRootElement() , clientWantPlay)

	function clientLoginCheck(password)
		if (password==pass) then
			direct = source
			triggerClientEvent ( source, "onLogin", getRootElement(), true)
			else
			triggerClientEvent ( source, "onLogin", getRootElement(), false)
			end
	end
	addEvent("clientWantLogin", true)
	addEventHandler("clientWantLogin", getRootElement(), clientLoginCheck)

	function clearScene(par)
	if (source==direct)or(par==direct) then
		for i, par in pairs(recData) do
			if (getElementByID(recData[i]["pedID"])~=nil) then
				destroyElement(getElementByID(recData[i]["pedID"]))
				end
			end
			
		-- 1.4.5
		recData = {}
		recKeyData = {}
		rcnt = 1
		
		outputChatBox ( "Scene cleared", source, 50, 255, 50 )
		else
		outputChatBox ( "Login as director (in Stage menu press login)", source, 255, 50, 50 )
		end
	end
	addEvent("clientWantClear", true)
	addEventHandler("clientWantClear", getRootElement(), clearScene)

	function SelectMap(val)
	 setMap(source,nil,val)
	end
	addEvent("clientSelectMap", true)
	addEventHandler("clientSelectMap", getRootElement(), SelectMap)

	------------------------------------------------
	-- 1.4.5

	local recievingQuery = {}

	function RecieveRecData(data)
		--outputChatBox ( "Thx for data!")
		--triggerClientEvent ( "onPlay", getRootElement())
		recData[rcnt] = data
		local ped = createPed ( data["init"]["initSkin"], data["init"]["initPos"][1],data["init"]["initPos"][2],data["init"]["initPos"][3])
		setElementID ( ped, "ped "..rcnt)
		setPedRotation(ped, data["init"]["initRot"])
		setElementInterior(ped, data["init"]["initInt"])
		setElementDimension(ped,  data["init"]["initDim"])
		setElementHealth(ped,  data["init"]["initHeal"])
		--setElementID(ped, 'stage'..rcnt)
		recData[rcnt]["ped"] = ped
		recData[rcnt]["pedID"] = "ped "..rcnt
		setTimer(SetPedWeap, 100, 1, rcnt)
		totalkf = totalkf + data["kfrm"]["km"] -- + 1 --???
		
		-- 1.4.5
		-- add to recieving query
		if (recievingQuery[source]~=nil) then
			outputChatBox("WARNING: server: something wrong in data sync!")
		end
		recKeyData[rcnt] = {}
		recievingQuery[source] = {}
		recievingQuery[source]["target"] = rcnt
		recievingQuery[source]["size"] = 0
		recievingQuery[source]["chunk"] = 1
		------------
		rcnt = rcnt + 1

		--ResetScene()
		--setElementVelocity(ped, tmpRec["initSpeed"])
		--setPedArmor(ped, tmpRec["initArm"])
		--local tm = table.save(recData)
		--outputConsole ( tm )
		--recData = table.load(tm)
		triggerClientEvent ("onSetKFCnt", getRootElement(), totalkf)
	end
	addEvent("onClientSendRecData", true)
	addEventHandler("onClientSendRecData", getRootElement() , RecieveRecData)

	-- 1.4.5
	function RecieveRecKeyData(data)
		
		if (recievingQuery[source]==nil) then
			outputChatBox("WARNING: server: something wrong in data sync!")
		else
			-- it it faster to use ind instead of recievingQuery[source]?
			local ind = recievingQuery[source]["target"]
			-- merging tables
			recKeyData[ind][recievingQuery[source]["chunk"]] = data["data"]
			recievingQuery[source]["size"] = recievingQuery[source]["size"] + data["size"]
			recievingQuery[source]["chunk"] = recievingQuery[source]["chunk"] + 1
			--outputChatBox("data rcv "..data["size"])
			-- is upload finished?
			if (recievingQuery[source]["size"]>=recData[ind]["kfrm"]["km"]) then
				--
				--outputChatBox("upload complete. chunk cnt "..#recKeyData[ind])
				recievingQuery[source] = nil
			end
		end
	end
	addEvent("onClientSendRecKeyData", true)
	addEventHandler("onClientSendRecKeyData", getRootElement() , RecieveRecKeyData)

	function printtbl( t,tab,lookup )
		local lookup = lookup or { [t] = 1 }
		local tab = tab or ""
		for i,v in pairs( t ) do
			print( tab..tostring(i), v )
			if type(i) == "table" and not lookup[i] then
				lookup[i] = 1
				print( tab.."Table: i" )
				printtbl( i,tab.."\t",lookup )
			end
			if type(v) == "table" and not lookup[v] then
				lookup[v] = 1
				print( tab.."Table: v" )
				printtbl( v,tab.."\t",lookup )
			end
		end
	end

	function RemovePed(id)
	if (source==direct) then
		local pedid = tonumber(string.sub(id,4, -1))
			destroyElement(recData[pedid]["ped"])
			recData[pedid]= nil
			-- 1.4.5
			recKeyData[pedid] = nil
			ResetScene()
			outputChatBox ( "Ped removed", source, 50, 255, 50 )
		else
		outputChatBox ( "Login as director (in Stage menu press login)", source, 255, 50, 50 )
		end
	end
	addEvent("onClientWantKill", true)
	addEventHandler("onClientWantKill", getRootElement() , RemovePed)

	function setMap(playerSource, commandName, val)
	if (playerSource==direct) then
		if (mapResource~=nil) then
			--stopResource (mapResource)
			end
		 if ( hasObjectPermissionTo ( getThisResource (), "function.restartResource", true )==false ) then
				outputChatBox ( "Access denied. Configure ACL for enable restartResource function", source, 255, 50, 50 )
				else
				
		if (getResourceFromName(val)) then
			mapResource = true
			end
		--local start = startResource ( mapResource ) -- Start the resource
			if ( mapResource ) then 
				if (getResourceState(getResourceFromName(val))=="running") then
					outputChatBox ( val .. " was selected", thePlayer, 50, 255, 50 )
					mapResource = getResourceFromName(val)
					else
					outputChatBox ( "This resource doesn't started. Start resource in server console", thePlayer, 255, 0, 0 )
					end
			else 
				outputChatBox ( "This resource doesn't exist.", thePlayer, 255, 50, 50 )
			end
		end
		else
		outputChatBox (  "Login as director (in Stage menu press login)",playerSource, 255, 50, 50)
		end
	end
	addCommandHandler("map", setMap)

	function consoleSetHealth(playerSource, commandName, health)
		setElementHealth(playerSource, tonumber(health))
	end
	addCommandHandler("sethealth", consoleSetHealth)

	function InitPed(arg)
	local i = arg[1]
	local ped1 = arg[2]

	--	local peds = getElementsByType ( "ped" )
	--	for theKey,thePed in ipairs(peds) do
	--	if (getElementData ( thePed, "stagepedid")==i) then
	--		
	--		end
	--	
	--	end
			setElementID ( ped1, "ped "..i)
			setPedRotation(ped1, recData[i]["init"]["initRot"])
			setElementInterior(ped1, recData[i]["init"]["initInt"])
			setElementDimension(ped1,  recData[i]["init"]["initDim"])
			setElementHealth(ped1,  recData[i]["init"]["initHeal"])
			if (recData[i]["init"]["initIsInCar"]==true) then
				-- warp into veh
				warpPedIntoVehicle ( ped1, getElementByID(recData[i]["init"]["initCar"]), par["init"]["initSeat"])
				--outputChatBox(recData[i]["init"]["initCar"])
				end
			-- give ammo with delay
			recData[i]["ped"] = ped1
			--setTimer(SetPedWeap, 50, 1, i)
	end
	addEvent("onInitPed", true)
	addEventHandler("onInitPed", getRootElement() , InitPed)

	function ResetScene()
		totalkf = 0
		-- restart map-resource
		-- we need to remember players seats
		local players = getElementsByType ( "player" ) 
		local warps = {}
		for theKey,thePlayer in ipairs(players) do 
		if ( isPedInVehicle ( thePlayer ) ) then 
			--outputChatBox ( getPlayerName ( thePlayer ) .. " is in a vehicle" )
			warps[thePlayer]={}
			warps[thePlayer]["car"] = getElementID(getPedOccupiedVehicle(thePlayer))
			warps[thePlayer]["seat"] = getPedOccupiedVehicleSeat(thePlayer)
			end
		end
		--
		if (mapResource~=nil) then
			restartResource (mapResource)-- getResourceFromName("mymap") )
			end
		-- reset peds
		-- warp players(not peds) into vehicles
		for thePlayer,value in pairs(warps) do 
			--outputChatBox ("put ".. getPlayerName ( thePlayer ) .. " in a vehicle "..value["car"] )
			if (getElementByID(value["car"])==false) then
				outputChatBox ("put error")
				end
			setTimer(warpPed, 50, 1, thePlayer, value["car"], value["seat"])
		end	
		
		for i, par in pairs(recData) do
		-- re-creating peds
			totalkf = totalkf + par["kfrm"]["km"] --- + 1
			--setTimer(SetPedParam, 50, 1, i)
		
			if (getElementByID(recData[i]["pedID"])) then
				destroyElement(getElementByID(recData[i]["pedID"]))
				end
			local ped = createPed ( par["init"]["initSkin"], par["init"]["initPos"][1],par["init"]["initPos"][2],par["init"]["initPos"][3])
			--triggerClientEvent ( "onCreatePed", getRootElement(), i, par["init"]["initSkin"], par["init"]["initPos"][1],par["init"]["initPos"][2],par["init"]["initPos"][3])
			setElementID ( ped, "ped "..i)
			setPedRotation(ped, par["init"]["initRot"])
			setElementInterior(ped, par["init"]["initInt"])
			setElementDimension(ped,  par["init"]["initDim"])
			setElementHealth(ped,  par["init"]["initHeal"])
			if (par["init"]["initIsInCar"]==true) then
				-- warp into veh
				warpPedIntoVehicle ( ped, getElementByID(par["init"]["initCar"]), par["init"]["initSeat"])
				--outputChatBox(par["init"]["initCar"])
				end
			-- give ammo with delay
			recData[i]["ped"] = ped
			setTimer(SetPedWeap, 80, 1, i)	
		end
		triggerClientEvent ("onSetKFCnt", getRootElement(), totalkf)
	end

	function dummy()
			setElementID ( ped, "ped "..i)
			setPedRotation(ped, par["init"]["initRot"])
			setElementInterior(ped, par["init"]["initInt"])
			setElementDimension(ped,  par["init"]["initDim"])
			setElementHealth(ped,  par["init"]["initHeal"])
			if (par["init"]["initIsInCar"]==true) then
				-- warp into veh
				warpPedIntoVehicle ( ped, getElementByID(par["init"]["initCar"]), par["init"]["initSeat"])
				--outputChatBox(par["init"]["initCar"])
				end
			-- give ammo with delay
			recData[i]["ped"] = ped
			setTimer(SetPedWeap, 100, 1, i)
			
	end

	function ResetScene2()
	if (source==direct) then
		ResetScene()
		else
		outputChatBox ( "Login as director (press Login in Stage menu)", source, 255, 50, 50 )
		end	
		--if (mapResource~=nil) then
			--stopResource(mapResource)
			
			--startResource(mapResource)
		--	restartResource (mapResource)-- getResourceFromName("mymap") )
		--	end
	end
	addEvent("onClientWantReset", true)
	addEventHandler("onClientWantReset", getRootElement() , ResetScene2)




	--function sync1()
	--setPedRotation(ped12,getPedRotation(getPlayerFromName('vovo4ka')))
	--triggerClientEvent ( "onPed", getRootElement(), ped) -- I'm not sure what it's good idea
	--end
	--setTimer(sync1 ,1000,1)
	--setTimer(giveWeapon ,100,1,ped, 31, 1000, true)
	--startResource ( getResourceFromName("mymap") )
end