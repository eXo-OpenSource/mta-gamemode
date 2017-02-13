
addEvent("doLoadStage", true)
addEventHandler("doLoadStage", root, function()


-- Stage resource for MTA:SA
-- autor: vovo4ka   <zolotayapipka@gmail.com>
--
-- my youtube channel with tutorials
-- http://www.youtube.com/user/vovo4kaX
--
-- thx for [UA]MacSYS and gephaest for support and inspiration ;)
--

local locPlr = getLocalPlayer()

local px1,py1,pz1 = 0,0,0
local px2,py2,pz2 = 0,0,0

local trace = {}
local tracecnt = 0
local tracec = tocolor ( 0, 255, 0, 230 )
local traced = 0.1
local smooth = true
-- some constants
local cmSpect = 1
local cmFP = 2
local cmDefault = 4
local cmFixed = 8
local cmDirector = 16

local pmFree = 1
local pmRotation = 2
local pmToPoint = 4
local pmStatic = 8
--local pmSManual = 8

local camFreeze = false

-- temporary arrays
local tmpKeyRec = {}
local tmpKeyFrame = {}
local tmpSpecEvents = {}
local tmpInitData = {}
local tmpWayPts = {}
local tmpFirePts = {}

local tmpData = {} -- tmp for server data

local camData = {}

local showHUD = false

local campx, campy, campz, camtx, camty, camtz = 0

local camLen = 6
local rotA = 0 -- rotate cam angles
local rotB = 0 
local camMode = cmDefault
local cTime = 0
local Time = 0

local dR1 = 0 -- cam point rotation
local dP1 = 0
local dR2 = 0 -- cam target rotation
local dP2 = 0

local sensRX = 0.9 -- mouse rotation sensivity
local sensRY = 0.9
local camSpeed = 0.5

local kfcnt = 0 -- key frame counter
--local Pkfcnt = 0 -- key frame player counter --old version
local kcnt = 0 -- key event counter
local secnt = 0 -- special event counter
local wpcnt = 0 -- way point counter
local fpcnt = 0 -- fire points cnt
local Pfpcnt = 0 -- play fire points cnt
local kwrite = false

local startTime = 0 -- rec starttime

local skipF = 0 -- current value
local skipFi = 0 -- init value for frameskip
local skipFMode = 0 -- 1 for adaptive
local skipAd = 1.0 -- ped
local skipAd10 = 5.0
local skipAd20 = 20
local skipAdA = 1.0 -- veh
local skipAdA5 = 2.0

local AdLast = {}
local AdCurr = {}
local ksaver = nil
local kplayer = nil
local wplayer = nil
local wsaver = nil
local lookat = nil
local ftimer = nil

local isRec = false
local isPlay = false
local isFire = false
local isDirector = false
local isElemSelect = false
local isKill = false
local logged = false
local isSoundEnable = true
local ElemEdit = nil

local lastCar = nil
local lastSeat = nil

local dd = 0

local KFRate = 50
local FTRate = 50 -- fire timer

local HotKeys = {}
local saveHK = false

local timerShow = true
local timerGo = false
local timerStart = 0
local timerValue = 0
local isShowKFR = true
local cam = {}
local CC = ""

local lastx, lasty, lastz = 0
local isHide = false

local totalkf = 0

local speedLimit = 0

local weapdis = {}-- correction disabled
weapdis[28] = true 
weapdis[32] = true 
weapdis[22] = true 

local screenWidth, screenHeight = guiGetScreenSize()
math.pi2 = math.pi / 2

local matX, matY, matZ = 0 -- matrix coeff

GUIEditor_Window = {}
GUIEditor_TabPanel = {}
GUIEditor_Tab = {}
GUIEditor_Button = {}
GUIEditor_Checkbox = {}
GUIEditor_Label = {}
GUIEditor_Edit = {}
GUIEditor_Radio = {}

function Send(arg)
triggerServerEvent("onInitPed", getLocalPlayer() , arg)
end

function createNewPed(id, skin, posX, posY, posZ)
	local ped = createPed ( skin, posX, posY, posZ)		
	outputChatBox ( "This "..id)
	arg = {}
	arg[1] = id
	setElementData ( ped, "stagepedid", id)
	arg[2] = ped
	Send(arg)
end
addEvent( "onCreatePed", true )
addEventHandler( "onCreatePed", getRootElement(), createNewPed)

function setQuality(skip_mode,skip_fi,par1,par2,par3,par4,par5)
skipFMode = skip_mode
skipFi = skip_fi
skipAd = par1
skipAd10 = par2
skipAd20 = par3
skipAdA = par4
skipAdA5 = par5
--outputChatBox ( "Rec settings changed", 50, 100, 50 )
end
addEvent( "onSetQuality", true )
addEventHandler( "onSetQuality", getRootElement(), setQuality)

function kWriteT()
kwrite = true
end

function SetKFCnt(val)
totalkf = val
end
addEvent( "onSetKFCnt", true )
addEventHandler( "onSetKFCnt", getRootElement(), SetKFCnt)

function callServerFunction(funcname, ...)
    local arg = { ... }
    if (arg[1]) then
        for key, value in next, arg do
            if (type(value) == "number") then arg[key] = tostring(value) end
        end
    end
    -- If the serverside event handler is not in the same resource, replace 'resourceRoot' with the appropriate element
    triggerServerEvent("onClientCallsServerFunction", getLocalPlayer() , funcname, unpack(arg))
end

function ShowHUD()
showPlayerHudComponent ( "ammo", showHUD )
showPlayerHudComponent ( "area_name", showHUD )
showPlayerHudComponent ( "armour", showHUD )
showPlayerHudComponent ( "breath", showHUD )
showPlayerHudComponent ( "clock", showHUD )
showPlayerHudComponent ( "health", showHUD )
showPlayerHudComponent ( "money", showHUD )
showPlayerHudComponent ( "radar", showHUD )
showPlayerHudComponent ( "vehicle_name", showHUD )
showPlayerHudComponent ( "weapon", showHUD )
showChat(showHUD)

if (showHUD==false) then
	showHUD = true
	else
	showHUD = false
	end
guiCheckBoxSetSelected(shud, showHUD)
end

function ShowHUDGUI()
showHUD = guiCheckBoxGetSelected(shud)

showPlayerHudComponent ( "ammo", showHUD )
showPlayerHudComponent ( "area_name", showHUD )
showPlayerHudComponent ( "armour", showHUD )
showPlayerHudComponent ( "breath", showHUD )
showPlayerHudComponent ( "clock", showHUD )
showPlayerHudComponent ( "health", showHUD )
showPlayerHudComponent ( "money", showHUD )
showPlayerHudComponent ( "radar", showHUD )
showPlayerHudComponent ( "vehicle_name", showHUD )
showPlayerHudComponent ( "weapon", showHUD )
showChat(showHUD)
end

function SoundsEnable()
isSoundEnable = guiCheckBoxGetSelected(ssnd)
end
function ShowKFrate()
isShowKFR = guiCheckBoxGetSelected(skfrate)
end

function Rec()
	if (isRec==false) then
	if (isDirector==false) then
		triggerServerEvent("onClientWantRec", getLocalPlayer() )
		else
		outputChatBox ("You cannot start record peds motion in Director mode")
		end
	else
	triggerServerEvent("onClientWantStopRec", getLocalPlayer() )
	end
end

function RecPlay()
	if (isRec==false) then
	if (isDirector==false) then
		triggerServerEvent("onClientWantRecPlay", getLocalPlayer() )
		else
		outputChatBox ("You cannot start record peds motion in Director mode")
		end
	else
	triggerServerEvent("onClientWantStopRecPlay", getLocalPlayer() )
	end
end

function Stop()
if (isRec==true)and(isPlay==true) then
	triggerServerEvent("onClientWantStopRecPlay", getLocalPlayer() )
	elseif (isRec==true) then
	triggerServerEvent("onClientWantStopRec", getLocalPlayer() )
	elseif (isPlay==true) then
	triggerServerEvent("onClientWantStopPlay", getLocalPlayer() )
	end
end

function Play()
	if (isPlay==false) then
	triggerServerEvent("onClientWantPlay", getLocalPlayer() )
	else
	triggerServerEvent("onClientWantStopPlay", getLocalPlayer() )
	--triggerServerEvent("onClientWantStopRec", getRootElement() )
	end
end

function KeyHandle(k, ks)
--outputChatBox ("key")
tmpKeyRec[kcnt] = {}
tmpKeyRec[kcnt][1] = (getTickCount()-startTime)
tmpKeyRec[kcnt][2] = k
if (ks=="down") then
	tmpKeyRec[kcnt][3] = true
	else
	tmpKeyRec[kcnt][3] = false
	end
kcnt = kcnt + 1
end

function correct(a)
--[[local ca = 0
if (a>=20) and (a<=90) then
	ca = a+238
elseif (a>90) and (a<152) then
	ca = a-39
elseif (a>=194) and (a<216) then
	ca = a-118
elseif (a>=216) and (a<270) then
	ca = a-135
elseif (a>=270) and (a<336) then
	ca = a-38
else
	ca = a
	end

return ca]]--
return a
end

function SaveFirePts()	
	if ((getControlState("aim_weapon")==false) and (getControlState("fire")==false)) then
		outputChatBox ("timer error!")-- debug ()
		else
		local cn = tmpFirePts[fpcnt]["n"]
		tmpFirePts[fpcnt]["p"][cn] = {}
		tmpFirePts[fpcnt]["p"][cn][1],tmpFirePts[fpcnt]["p"][cn][2],tmpFirePts[fpcnt]["p"][cn][3] = getPedTargetCollision(locPlr)
		if (tmpFirePts[fpcnt]["p"][cn][1]==false) then
			tmpFirePts[fpcnt]["p"][cn][1],tmpFirePts[fpcnt]["p"][cn][2],tmpFirePts[fpcnt]["p"][cn][3] = getPedTargetEnd(locPlr)
			end
		local we = getPedWeapon(locPlr)
		if (we>21)and(weapdis[we]==nil) then
			tmpFirePts[fpcnt]["p"][cn][4] = correct(getPedRotation(locPlr))
		else
			tmpFirePts[fpcnt]["p"][cn][4] = getPedRotation(locPlr)
			end
		tmpFirePts[fpcnt]["p"][cn]["d"] = (getTickCount()-startTime)
		tmpFirePts[fpcnt]["n"] = cn + 1		
		end
end

function PlayFirePts(id, cnt)
--outputChatBox ("AIM!")
tmpData[id]["fp"][cnt]["n"] = 1
if (tmpData[id]["fp"][cnt]["p"][0][1]~=nil) then
	local x = tmpData[id]["fp"][cnt]["p"][0][1]
	local y = tmpData[id]["fp"][cnt]["p"][0][2]
	local z = tmpData[id]["fp"][cnt]["p"][0][3]
	if (x~=nil)and(y~=nil)and(z~=nil) then
		setPedAimTarget ( tmpData[id]["ped"], tmpData[id]["fp"][cnt]["p"][0][1], tmpData[id]["fp"][cnt]["p"][0][2], tmpData[id]["fp"][cnt]["p"][0][3])
		--tmpData[id]["fp"][cnt]["p"]
		--setElementPosition(tmpobj, tmpData[id]["fp"][cnt]["p"][0][1], tmpData[id]["fp"][cnt]["p"][0][2], tmpData[id]["fp"][cnt]["p"][0][3])
		setPedRotation ( tmpData[id]["ped"], tmpData[id]["fp"][cnt]["p"][0][4])
		end
	end
tmpData[id]["fp"][cnt]["tmr"] = setTimer(TimerPlayFirePts, FTRate, 0, id, cnt)
setTimer(StopFirePts, tmpData[id]["fp"][cnt]["en"], 1, id, cnt)
end

function StopFirePts(id, cnt)
if (isTimer(tmpData[id]["fp"][cnt]["tmr"])) then
	killTimer(tmpData[id]["fp"][cnt]["tmr"])
	end
--outputChatBox ("stop AIM!")
end

function TimerPlayFirePts(id, cnt)
	local cn = tmpData[id]["fp"][cnt]["n"]
	local cn1 = 0
	local nt = 0
	local dt = 0
	local data = tmpData[id]["fp"][cnt]["p"]
	nt = getTickCount()-tc
	if (nt>data[cn]["d"]) then
		while ((nt-data[cn]["d"]>FTRate)and(data[cn+1]~=nil)) do
			cn = cn + 1
			end
		if (data[cn+1]==nil) then
			cn1 = cn
			--outputChatBox ("must stop")
			dt = 0.0001
			else
			cn1 = cn + 1
			dt = (data[cn+1]["d"]-data[cn]["d"])
			end						
		else
		while (((data[cn]["d"]-nt)>FTRate)and(cn>1)) do
			cn = cn - 1
			end	
		cn1 = cn + 1
		dt = (data[cn+1]["d"]-data[cn]["d"])
		end
		
	--if (tmpData[id]["fp"][cnt]["p"][cn]~=nil) then
		--local x = data[cn][1]
		--local y = data[cn][2]
		--local z = data[cn][3]
		--local k = (nt-data[cn]["d"])/dt
		--local x,y,z = vi(k, data[cn][1], data[cn][2], data[cn][3], data[cn1][1], data[cn1][2], data[cn1][3])
		--if (x~=nil)and(y~=nil)and (z~=nil) then
			--setPedAimTarget ( tmpData[id]["ped"],x,y,z)
			setPedAimTarget ( tmpData[id]["ped"], data[cn][1], data[cn][2], data[cn][3]+0.01)
			setPedRotation (tmpData[id]["ped"],data[cn][4])
			--setElementPosition(tmpobj, x, y, z)
			--setPedRotation ( tmpData[id]["ped"], tmpData[id]["fp"][cnt]["p"][cn][4])
			--setPedRotation ( tmpData[id]["ped"], math.random(360))
		--	end
	--	else
		--outputChatBox ("timer error 2!")-- debug ()
	--	end
	tmpData[id]["fp"][cnt]["n"] = cn
end

function damageEvent( attacker, weapon, bodypart )
if (isRec==true) then
	tmpSpecEvents[secnt] = {}
	tmpSpecEvents[secnt][1] = "he"
	tmpSpecEvents[secnt][2] = getTickCount() - startTime
	tmpSpecEvents[secnt][3] = getElementHealth(locPlr)
	secnt = secnt + 1
	end
end
addEventHandler ( "onClientPlayerDamage", locPlr, damageEvent)

function getPedRotationEx()
	local cx, cy, cz, ctx, cty, ctz = getCameraMatrix()
	local rot = math.atan2(cty-cy,ctx-cx)
	return (-rot+math.pi2)*180/math.pi
end

function FireKeyHandle(k, ks)
a = getControlState("aim_weapon")
b = getControlState("fire")
-- tmpFirePts
-- fpcnt
if (a or b) then
	if (isFire==false) then
		-- if begin aiming or fire
		if (isTimer(ftimer)) then
			killTimer(ftimer)
			end
		ftimer = setTimer(SaveFirePts, FTRate, 0)
		tmpFirePts[fpcnt] = {}
		tmpFirePts[fpcnt]["st"] = (getTickCount()-startTime) --start time
		tmpFirePts[fpcnt]["en"] = 0 -- aiming time
		tmpFirePts[fpcnt]["n"] = 1 -- current pointer
		tmpFirePts[fpcnt]["tmr"] = 0 -- timer
		tmpFirePts[fpcnt]["p"] = {} -- points
		
		tmpFirePts[fpcnt]["p"][0] = {}
		tmpFirePts[fpcnt]["p"][0][1],tmpFirePts[fpcnt]["p"][0][2],tmpFirePts[fpcnt]["p"][0][3] = getPedTargetEnd(locPlr)
		local we = getPedWeapon(locPlr)
		if (we>21)and(weapdis[we]==nil) then
			tmpFirePts[fpcnt]["p"][0][4] = correct(getPedRotation(locPlr))
			else
			tmpFirePts[fpcnt]["p"][0][4] = getPedRotation(locPlr)
			end
		tmpFirePts[fpcnt]["p"][0]["d"] = (getTickCount()-startTime)
		isFire = true
		else
		-- 
		
		end
	else
	isFire = false
	if (isTimer(ftimer)) then
		killTimer(ftimer)
		end
	tmpFirePts[fpcnt]["en"] = (getTickCount()-startTime) --end time
	fpcnt = fpcnt + 1
	end
end

abz = 0
abzSt = 0
abz1 = 0
function KFrmSaver() -- saving camera rotation for accuracy movement
--abz = getTickCount() - abz0
--abz0 = getTickCount()
--abz1 = abz
	if (isPedInVehicle (locPlr)==false) then-- on foot
		local cx, cy, cz, ctx, cty, ctz = getCameraMatrix()
		local rot = math.atan2(cty-cy,ctx-cx)
		tmpKeyFrame[kfcnt] = {}
		tmpKeyFrame[kfcnt]["d"] = (getTickCount()-startTime)
		tmpKeyFrame[kfcnt][1] = (-rot+math.pi2)*180/math.pi
		tmpKeyFrame[kfcnt][2] = ctx+20*(ctx-cx)
		tmpKeyFrame[kfcnt][3] = cty+20*(cty-cy)
		tmpKeyFrame[kfcnt][4] = ctz+20*(ctz-cz)
		tmpKeyFrame[kfcnt][5],tmpKeyFrame[kfcnt][6],tmpKeyFrame[kfcnt][7] = getElementPosition(locPlr)
		tmpKeyFrame[kfcnt][8],tmpKeyFrame[kfcnt][9],tmpKeyFrame[kfcnt][10] =  getElementVelocity(locPlr)
		tmpKeyFrame[kfcnt][11]=getPedControlState( locPlr, "crouch" )
		tmpKeyFrame[kfcnt][12]=getPedRotation(locPlr)
		--if (getControlState("aim_weapon")==true) then
			--tmpKeyFrame[kfcnt][8] = getPedRotation(locPlr)
			--outputChatBox ("aim")
		--	else
			--tmpKeyFrame[kfcnt][8] = nil
		--	end
	else
		tmpKeyFrame[kfcnt] = {}
		tmpKeyFrame[kfcnt]["d"] = (getTickCount()-startTime)
		tmpKeyFrame[kfcnt][1] = false
		-- if driver
		local veh = getPedOccupiedVehicle (locPlr)
		local occ = getVehicleOccupant ( veh, 0 )
		if (occ==locPlr) then
			tmpKeyFrame[kfcnt][2] = getElementID(veh)
			tmpKeyFrame[kfcnt][3],tmpKeyFrame[kfcnt][4],tmpKeyFrame[kfcnt][5] = getElementRotation (veh)
			tmpKeyFrame[kfcnt][6],tmpKeyFrame[kfcnt][7],tmpKeyFrame[kfcnt][8] = getVehicleTurnVelocity (veh)
			tmpKeyFrame[kfcnt][9],tmpKeyFrame[kfcnt][10],tmpKeyFrame[kfcnt][11] = getElementVelocity (veh)
			tmpKeyFrame[kfcnt][12],tmpKeyFrame[kfcnt][13],tmpKeyFrame[kfcnt][14] = getElementPosition(veh)
			--tmpKeyFrame[kfcnt][15]=getPedControlState ( locPlr, "accelerate" )
			--tmpKeyFrame[kfcnt][16]=getPedControlState ( locPlr, "brake_reverse" )
			--tmpKeyFrame[kfcnt][17]=getPedControlState ( locPlr, "handbrake" )
			--tmpKeyFrame[kfcnt][18]=getPedControlState ( locPlr, "vehicle_left" )
			--tmpKeyFrame[kfcnt][19]=getPedControlState ( locPlr, "vehicle_right" )
			--tmpKeyFrame[kfcnt][20]=getPedControlState ( locPlr, "horn" )
			--local t = getVehicleType(veh)
			--if (t=="BMX") then
			--tmpKeyFrame[kfcnt][21]=getPedControlState ( locPlr, "vehicle_secondary_fire" )
			--	end
			--tmpKeyFrame[kfcnt][22]=getPedControlState ( locPlr, "steer_forward" )
			--tmpKeyFrame[kfcnt][23]=getPedControlState ( locPlr, "steer_back" )
			
			else
			tmpKeyFrame[kfcnt][2] = false
			end
	end
	kfcnt = kfcnt + 1
end

function WayPtsSaver() -- saving player position
	local x, y, z = getElementPosition(locPlr)
	tmpWayPts[wpcnt] = {}
	tmpWayPts[wpcnt][1] = x
	tmpWayPts[wpcnt][2] = y
	tmpWayPts[wpcnt][3] = z
	wpcnt = wpcnt + 1
end

-- vector linear interpolate
function vi(k,x1,y1,z1,x2,y2,z2)
return x1+(x2-x1)*k,y1+(y2-y1)*k,z1+(z2-z1)*k
end
--
function si(k,x1,x2)
if (x1-x2>180) then
	x2 = x2 + 360
elseif (x2-x1>180) then
	x1 = x1 + 360
	end
return x1+(x2-x1)*k
end
--
-- angle
function ai(k,x1,y1,z1,x2,y2,z2)

if (x1-x2>180) then
	x2 = x2 + 360
elseif (x2-x1>180) then
	x1 = x1 + 360
	end
if (y1-y2>180) then
	y2 = y2 + 360
elseif (y2-y1>180) then
	y1 = y1 + 360
	end
if (z1-z2>180) then
	z2 = z2 + 360
elseif (z2-z1>180) then
	z1 = z1 + 360
	end
return x1+(x2-x1)*k,y1+(y2-y1)*k,z1+(z2-z1)*k

end

function KFrmPlayer() -- playing camera rotation
--abz = getTickCount() - abz0
--abz0 = getTickCount()
	local playend = true
	for i, par in pairs(tmpData) do
	if (getElementHealth(par["ped"])>0) then
	local Pkfcnt = par["kfrm"]["k"]
	local Pkfcnt1 = 0
	local nt = 0
	local ion = true
	local dt = 0
		if (par["kfrm"][Pkfcnt]~=nil ) then
		-- time
		nt = getTickCount()-tc
		if (nt>par["kfrm"][Pkfcnt]["d"]) then
			while ((nt>par["kfrm"][Pkfcnt]["d"])and(Pkfcnt<par["kfrm"]["km"])) do
				Pkfcnt = Pkfcnt + 1
				end
			if (Pkfcnt==par["kfrm"]["km"]) then
				Pkfcnt1 = Pkfcnt
				outputChatBox ("must stop")
				dt = 0.0001
				else
				Pkfcnt1 = Pkfcnt + 1
				playend = false
				dt = (par["kfrm"][Pkfcnt1]["d"]-par["kfrm"][Pkfcnt]["d"])
				end						
			else
			while ((par["kfrm"][Pkfcnt]["d"]>nt)and(Pkfcnt>0)) do
				Pkfcnt = Pkfcnt - 1
				end	
			Pkfcnt1 = Pkfcnt + 1
			playend = false
			dt = (par["kfrm"][Pkfcnt1]["d"]-par["kfrm"][Pkfcnt]["d"])
			end
			
			if (type(par["kfrm"][Pkfcnt][1])~=type(par["kfrm"][Pkfcnt1][1])) then
				Pkfcnt1 = Pkfcnt
				dt = 0.0001
				--outputChatBox ("diff type")
				end
			
			if (par["kfrm"][Pkfcnt][1]~=false) then -- on foot
			local k = (nt-par["kfrm"][Pkfcnt]["d"])/dt
			local x,y,z = vi(k, par["kfrm"][Pkfcnt][5], par["kfrm"][Pkfcnt][6], par["kfrm"][Pkfcnt][7], par["kfrm"][Pkfcnt1][5], par["kfrm"][Pkfcnt1][6], par["kfrm"][Pkfcnt1][7])
			local an = si(k, par["kfrm"][Pkfcnt][1], par["kfrm"][Pkfcnt1][1])
			--local an2 = si(k, par["kfrm"][Pkfcnt][12], par["kfrm"][Pkfcnt1][12])
			local vx,vy,vz = vi(k, par["kfrm"][Pkfcnt][8], par["kfrm"][Pkfcnt][9], par["kfrm"][Pkfcnt][10], par["kfrm"][Pkfcnt1][8], par["kfrm"][Pkfcnt1][9], par["kfrm"][Pkfcnt1][10])
		
			--if (smooth==true) then
				setPedCameraRotation ( par["ped"],an)
				setElementPosition ( par["ped"], x, y, z, false)
				setElementVelocity (par["ped"], vx, vy, vz)
			--else
			--	setPedCameraRotation ( par["ped"], par["kfrm"][Pkfcnt][1])
			--	setElementPosition(par["ped"], par["kfrm"][Pkfcnt][5], par["kfrm"][Pkfcnt][6],par["kfrm"][Pkfcnt][7], false)
			--	setElementVelocity (par["ped"], par["kfrm"][Pkfcnt][8],par["kfrm"][Pkfcnt][9],par["kfrm"][Pkfcnt][10])	
			--end
			--	abz1 = getPedRotation(locPlr)
				--set
				
				setPedControlState ( par["ped"], "crouch", par["kfrm"][Pkfcnt][11] )
				
			else -- vehicle
				if (par["kfrm"][Pkfcnt][2]~=false) then
				local k = (nt-par["kfrm"][Pkfcnt]["d"])/dt
				local x,y,z = vi(k, par["kfrm"][Pkfcnt][12], par["kfrm"][Pkfcnt][13], par["kfrm"][Pkfcnt][14], par["kfrm"][Pkfcnt1][12], par["kfrm"][Pkfcnt1][13], par["kfrm"][Pkfcnt1][14])
				--abz1 = par["kfrm"][Pkfcnt][3]--tostring(k)
				local rx,ry,rz = ai(k, par["kfrm"][Pkfcnt][3], par["kfrm"][Pkfcnt][4], par["kfrm"][Pkfcnt][5], par["kfrm"][Pkfcnt1][3], par["kfrm"][Pkfcnt1][4], par["kfrm"][Pkfcnt1][5])
				local vx,vy,vz = vi(k, par["kfrm"][Pkfcnt][9], par["kfrm"][Pkfcnt][10], par["kfrm"][Pkfcnt][11], par["kfrm"][Pkfcnt1][9], par["kfrm"][Pkfcnt1][10], par["kfrm"][Pkfcnt1][11])
				local tvx,tvy,tvz = vi(k, par["kfrm"][Pkfcnt][6], par["kfrm"][Pkfcnt][7], par["kfrm"][Pkfcnt][8], par["kfrm"][Pkfcnt1][6], par["kfrm"][Pkfcnt1][7], par["kfrm"][Pkfcnt1][8])
								
				local veh = getElementByID(par["kfrm"][Pkfcnt][2])
				--if (smooth==false) then
				--	setVehicleTurnVelocity (veh,par["kfrm"][Pkfcnt][6],par["kfrm"][Pkfcnt][7],par["kfrm"][Pkfcnt][8])
				--	setElementVelocity (veh,par["kfrm"][Pkfcnt][9],par["kfrm"][Pkfcnt][10],par["kfrm"][Pkfcnt][11])
				--	setElementPosition (veh,par["kfrm"][Pkfcnt][12],par["kfrm"][Pkfcnt][13],par["kfrm"][Pkfcnt][14], false)
				--	setElementRotation (veh,par["kfrm"][Pkfcnt][3],par["kfrm"][Pkfcnt][4],par["kfrm"][Pkfcnt][5])
			
				--	else
					setElementPosition (veh, x,y,z)
					setElementVelocity (veh, vx,vy,vz)
					setVehicleTurnVelocity (veh, tvx,tvy,tvz)
					setElementRotation (veh, rx,ry,rz)
				--	end

				--setElementRotation (veh, rx,ry,rz)
				--setPedControlState ( par["ped"], "accelerate", par["kfrm"][Pkfcnt][15] )
				--setPedControlState ( par["ped"], "brake_reverse", par["kfrm"][Pkfcnt][16] )
				--setPedControlState ( par["ped"], "handbrake", par["kfrm"][Pkfcnt][17] )
				--setPedControlState ( par["ped"], "vehicle_left", par["kfrm"][Pkfcnt][18] )
				--setPedControlState ( par["ped"], "vehicle_right", par["kfrm"][Pkfcnt][19] )
				--setPedControlState ( par["ped"], "horn", par["kfrm"][Pkfcnt][20] )
				--setPedControlState ( par["ped"], "vehicle_secondary_fire", par["kfrm"][Pkfcnt][21] )
				--setPedControlState ( par["ped"], "steer_forward", par["kfrm"][Pkfcnt][22] )
				--setPedControlState ( par["ped"], "steer_back", par["kfrm"][Pkfcnt][23] )
				end
			end
			tmpData[i]["kfrm"]["k"] = Pkfcnt
			end
		end
	end
	if (playend==true) then
		killTimer(kplayer)
		isPlay = false
		if (isRec==false) then
			timerGo = false
			end
		--outputChatBox ("Playback ended "..Pkfcnt.." frames")
		end
	--Pkfcnt = Pkfcnt + 1
end

function WayPtsPlayer() -- playing ped position
	local playend = true
	for i, par in pairs(tmpData) do
		if (par["wp"][wpcnt]~=nil ) then
			setElementPosition ( par["ped"], par["wp"][wpcnt][1], par["wp"][wpcnt][2], par["wp"][wpcnt][3] , false)
			playend = false
			end
		end
	if (playend==true) then
		killTimer(wplayer)
		--outputChatBox ("Playback ended "..wpcnt.." way points")
		end
	wpcnt = wpcnt + 1
end

function beginRec(ext_data)
if (isSoundEnable)and(ext_data=="rec") then
	local snd = playSound ( "client/sounds/recstart.wav", false )
	setSoundVolume ( snd, 0.5)
	end

if (camMode~=cmSpect) then
	tmpKeyRec = {} -- cleanup rec arrays
	tmpKeyFrame = {}
	tmpSpecEvents = {}
	tmpInitData = {}
	--tmpWayPts = {}
	tmpFirePts = {}
	timerGo = true
	timerStart = getTickCount()
	
	abzSt = getTickCount()
	--giveWeapon(myPed, 35, 500, true)
	setTimer(kWriteT, 700, 0)
	
	kfcnt = 0
	secnt = 0
	kcnt = 0
	wpcnt = 0
	fpcnt = 0
	
	skipF = 0
	
	AdLast[1] = -1000
	
	local pl = getLocalPlayer()
	local x,y,z = getElementPosition(pl)
	tmpInitData = {}
	tmpInitData["initPos"] = {}
	tmpInitData["initPos"][1] = x 
	tmpInitData["initPos"][2] = y
	tmpInitData["initPos"][3] = z 
	tmpInitData["initDim"] = getElementDimension(pl)
	tmpInitData["initInt"] = getElementInterior(pl)
	tmpInitData["initSkin"] = getElementModel(pl)
	--tmpInitData["initArm"] = getPedArmor(pl)
	tmpInitData["initHeal"] = getElementHealth(pl)
	--tmpInitData["initSpeed"] = getElementVelocity( pl)
	tmpInitData["initRot"] = getPedRotation(pl)
	tmpInitData["initIsInCar"] = isPedInVehicle(pl)
	if (tmpInitData["initIsInCar"] ==true) then
		--outputChatBox ( "veh")
		tmpInitData["initCar"] = lastCar
		tmpInitData["initSeat"] = lastSeat
		end
	-- weapon data
	tmpInitData["initWeapSlot"] = getPedWeaponSlot(pl)
	tmpInitData["initWeap"] = {}
	for i = 0,12 do
		tmpInitData["initWeap"][i] = {}
		tmpInitData["initWeap"][i][1] = getPedWeapon (pl, i)
		tmpInitData["initWeap"][i][2] =	getPedTotalAmmo (pl, i)
		end
	
	
	isRec = true
	startTime = getTickCount()
	--wsaver = setTimer ( WayPtsSaver, 1000, 0)
	-- binding controls
	--toggleAllControls ( true, true)
	
	bindKey ( "fire", "both", FireKeyHandle)
	bindKey ( "aim_weapon", "both", FireKeyHandle)
	
	bindKey ( "forwards", "both", KeyHandle)
	bindKey ( "backwards", "both", KeyHandle)
	bindKey ( "left", "both", KeyHandle)
	bindKey ( "right", "both", KeyHandle)
	bindKey ( "fire", "both", KeyHandle)
	bindKey ( "next_weapon", "both", KeyHandle)
	bindKey ( "previous_weapon", "both", KeyHandle)
	bindKey ( "jump", "both", KeyHandle)
	bindKey ( "sprint", "both", KeyHandle)
	bindKey ( "look_behind", "both", KeyHandle)
	bindKey ( "crouch", "both", KeyHandle)
	bindKey ( "walk", "both", KeyHandle)
	bindKey ( "enter_exit", "both", KeyHandle) -- (-_-)
	bindKey ( "aim_weapon", "both", KeyHandle)
	-- car
	bindKey ( "accelerate", "both", KeyHandle)
	bindKey ( "brake_reverse", "both", KeyHandle)
	bindKey ( "handbrake", "both", KeyHandle)
	bindKey ( "vehicle_left", "both", KeyHandle)
	bindKey ( "vehicle_right", "both", KeyHandle)
	bindKey ( "horn", "both", KeyHandle)
	bindKey ( "vehicle_fire", "both", KeyHandle)
	bindKey ( "vehicle_secondary_fire", "both", KeyHandle)
	bindKey ( "steer_forward", "both", KeyHandle)
	bindKey ( "steer_back", "both", KeyHandle)
	bindKey ( "vehicle_look_left", "both", KeyHandle)
	bindKey ( "vehicle_look_right", "both", KeyHandle)
	bindKey ( "vehicle_look_behind", "both", KeyHandle)
	bindKey ( "special_control_left", "both", KeyHandle)
	bindKey ( "special_control_right", "both", KeyHandle)
	bindKey ( "special_control_up", "both", KeyHandle)
	bindKey ( "special_control_down", "both", KeyHandle)
	
    --outputChatBox ( "Rec began! ")
	--ksaver = setTimer ( KFrmSaver, KFRate, 0)
	ksaver = true
	lookat = setTimer ( LookAt, 200, 0)	
end
end
addEvent( "onBeginRec", true )
addEventHandler( "onBeginRec", getRootElement(), beginRec )

-- 1.4.5
local isSendingInProgress = false;
local currentSendingCount = 0;
local totalSendingCount = 0;

local maxSendingValue = 256;
local sendingTimer = nil

-- some useful func
function subtable(_table, _start, _end)
	_res = {}
	for i=_start,_end-1,1 do
		_res[i] = _table[i]
	end
	outputChatBox(#_table)
	return _res
end

-- sending data step
function sendDataTimer()
	-- sending data size calculation
	local val = maxSendingValue
	if (val + currentSendingCount>totalSendingCount) then
		val = totalSendingCount - currentSendingCount
	end
	--
	if (val>0) then
		-- subtable obtaining
		local tempTable = {} --subtable(tmpKeyData, currentSendingCount, currentSendingCount+val)
		tempTable["size"] = val
		tempTable["data"] = {}
		
		for i=currentSendingCount,currentSendingCount+val-1,1 do
			tempTable["data"][i] = tmpKeyFrame[i]
			--outputChatBox("sending "..i)
		end
		
		--outputChatBox("sending "..currentSendingCount.. "   "..currentSendingCount+val)
		-- sending subtable
		triggerServerEvent("onClientSendRecKeyData", getLocalPlayer(), tempTable )
		-- increase data count
		currentSendingCount = currentSendingCount + val
	end
	
	if (val<maxSendingValue) then
	-- release timer if all data was sent
		killTimer(sendingTimer)
		sendingTimer = nil
	end
	
end

function stopRec()
if(isRec==true) then
	isRec = false
	-- stop keyframe saver
	if (isTimer(ksaver)) then
		--killTimer(ksaver)
		
		end
	ksaver = false
	if (isTimer(lookat)) then
		killTimer(lookat)
		end
	if (isPlay==false) then
		timerGo = false
		if (isSoundEnable) then
			local snd = playSound ( "client/sounds/stop.wav", false )
			setSoundVolume ( snd, 0.3)
			end
		end
	--tmpKeyFrame["km"] = kfcnt - 1
	--killTimer(wsaver)
	-- unbinding controls
	unbindKey ( "forwards")
	unbindKey ( "backwards")
	unbindKey ( "left")
	unbindKey ( "right")
	unbindKey ( "fire")
	unbindKey ( "next_weapon")
	unbindKey ( "previous_weapon")
	unbindKey ( "jump")
	unbindKey ( "sprint")
	unbindKey ( "look_behind")
	unbindKey ( "crouch")
	unbindKey ( "walk")
	unbindKey ( "enter_exit")
	unbindKey ( "aim_weapon")
	
	unbindKey ( "accelerate")
	unbindKey ( "brake_reverse")
	unbindKey ( "handbrake")
	unbindKey ( "vehicle_left")
	unbindKey ( "vehicle_right")
	unbindKey ( "horn")
	unbindKey ( "vehicle_fire")
	unbindKey ( "vehicle_secondary_fire")
	unbindKey ( "steer_forward")
	unbindKey ( "steer_back")
	unbindKey ( "vehicle_look_left")
	unbindKey ( "vehicle_look_right")
	unbindKey ( "vehicle_look_behind")
	unbindKey ( "special_control_left")
	unbindKey ( "special_control_right")
	unbindKey ( "special_control_up")
	unbindKey ( "special_control_down")	

	
	--outputChatBox ( "Record Stopped! ")
	local data = {}
	data["init"] = tmpInitData
	data["key"] = tmpKeyRec
	data["kfrm"] = {} --tmpKeyFrame
	data["kfrm"]["km"] = kfcnt - 1
	--data["wp"] = tmpWayPts
	data["se"] = tmpSpecEvents
	data["fp"] = tmpFirePts
	outputChatBox ("Recording stopped "..(kfcnt - 1).." frames and "..fpcnt.." fire points")
	-- since 1.4.5:
	-- the new idea for uploading is to send separate keyframes data by timer event
	totalSendingCount = #tmpKeyFrame --kfcnt - 1
	currentSendingCount = 0

	
	if (sendingTimer~=nil) then
		killTimer(sendingTimer)
		outputChatBox("WARNING: client: something wrong in data sync!")
	end
	
	sendingTimer = setTimer ( sendDataTimer, 60+math.random(0, 15), 0 )
	
	--local tmp123 = subtable(tmpKeyFrame, 0, 2)
		
	--[[for i, par in pairs(tmpKeyFrame) do
		outputChatBox("client "..i)
		end]]
	
	triggerServerEvent("onClientSendRecData", getLocalPlayer(), data )
end
end
addEvent( "onStopRec", true )
addEventHandler( "onStopRec", getRootElement(), stopRec )

function Reset()
	triggerServerEvent("onClientWantReset", getLocalPlayer())
	timerValue = 0
end

-- 1.4.5
local recievingProgressBar = nil
local recievingLabel = nil
local total_size = 0

function recieveSceneData(data)
	tmpData = data
	if (recievingProgressBar==nil) then
		if ((#tmpData>10)or(totalkf>1000)) then
			recievingProgressBar = guiCreateProgressBar( 0.7, 0.9, 0.2, 0.05, true, nil )
			recievingLabel = guiCreateLabel  ( 0.71, 0.95, 0.1, 0.1, "Downloading data: 0%", true, nil )
			guiProgressBarSetProgress(recievingProgressBar, 0)
		end
	end
end
addEvent( "recieveSceneData", true )
addEventHandler( "recieveSceneData", getRootElement(), recieveSceneData )

function recieveKeyframeData(data)
	-- merging arrays
	for i, par in pairs(data["data"]) do
		tmpData[data["target"]]["kfrm"][i] = par
		end
	-- gui update
	if (recievingProgressBar~=nil) then
		guiProgressBarSetProgress(recievingProgressBar, data["curr"]*100.0/data["total"])
		guiSetText (recievingLabel, "Downloading data: "..data["curr"]*100.0/data["total"].."%")
	end
end
addEvent( "recievKeyframeChunk", true )
addEventHandler( "recievKeyframeChunk", getRootElement(), recieveKeyframeData)

-- 1.4.5
-- text progressbar indicator
local savingIndicator = nil
function setSavingProgressGUI(value)
	if (value~="") then
		if (savingIndicator==nil) then
			savingIndicator = guiCreateLabel(0.25, 0.95, 0.9, 0.1, value,true,nil)
		else
			guiSetText ( savingIndicator, value )
		end
	else
		if (savingIndicator~=nil) then
			destroyElement(savingIndicator)
			savingIndicator = nil
		end
	end
end
addEvent( "showSavingProgressGUI", true )
addEventHandler( "showSavingProgressGUI", getRootElement(), setSavingProgressGUI)

-- 1.4.5
function beginPlay(ext_data) --data
-- remove progressbar gui
if (recievingProgressBar~=nil) then
	-- remove progressbar
	destroyElement(recievingProgressBar)
	recievingProgressBar = nil
end
if (recievingLabel~=nil) then
	destroyElement(recievingLabel)
	recievingLabel = nil
end

if (isSoundEnable)and(ext_data=="play") then
	local snd = playSound ( "client/sounds/playstart.wav", false )
	setSoundVolume ( snd, 0.5)
	end

tracec = tocolor ( math.random(255), math.random(255), math.random(255), 255 )
traced = traced + 0.1

abzSt = getTickCount()
--tmpData = data
	--Pkfcnt = 0 --old version
	for i, par in pairs(tmpData) do
		tmpData[i]["kfrm"]["k"]=0
		tmpData[i]["kfrm"]["km"] = tmpData[i]["kfrm"]["km"]-1 --stop play criteria
		end
	--wpcnt = 0
	--secntP = 0
	tc = getTickCount()
	
	tdelay = 0
	isPlay = true
	timerGo = true
	timerStart = getTickCount()
	
	
	--local ped = getElementByID(recData["rec"]["pedID"])
	for i, par in pairs(tmpData) do --data
		-- fire pts
		--par["ped"] = getElementByID(par["pedID"])
		for j, par2 in pairs(par["fp"]) do
			setTimer (PlayFirePts, par2["st"], 1, i, j) 
			tdelay = tdelay + dd
			end
		for j, par2 in pairs(par["key"]) do
			setTimer ( setPedControlState, par2[1] - tdelay, 1, par["ped"], par2[2], par2[3])
			tdelay = tdelay + dd
			end
		-- special events
		for j, par2 in pairs(par["se"]) do
			if (par2[1]=="veh") then
				setTimer ( triggerServerEvent, par2[2]- tdelay, 1, "onWarpPedInVeh", getLocalPlayer(),par["ped"], par2[3], par2[4])
			elseif (par2[1]=="vehe") then
				--outputChatBox ( "VEHEXIT")
				setTimer ( triggerServerEvent, par2[2]- tdelay, 1, "onRemPedFromVeh", getLocalPlayer(),par["ped"], par2[3], par2[4], par2[5])
				--setTimer ( setElementPosition, par2[2], 1, par["ped"], par2[3], par2[4], par2[5], false)
			elseif (par2[1]=="we") then
				setTimer ( setPedWeaponSlot, par2[2]- tdelay, 1, par["ped"], par2[3])
			elseif (par2[1]=="an") then
				setTimer ( setPedAnimation, par2[2]- tdelay, 1, par["ped"], par2[3], par2[4], -1, par2[5])
			elseif (par2[1]=="ran") then
				setTimer ( setPedAnimation, par2[2]- tdelay, 1, par["ped"])
			elseif (par2[1]=="lgh") then
				setTimer (  setVehicleOverrideLightsEx, par2[2]- tdelay, 1, par2[3], par2[4])
			elseif (par2[1]=="elgh") then
				setTimer (  setVehicleEmerLightsEx, par2[2]- tdelay, 1, par2[3], par2[4])	
			elseif (par2[1]=="he") then
				setTimer ( setElementHealth, par2[2]- tdelay, 1, par["ped"], par2[3])			
			end	
			tdelay = tdelay + dd
		end
	end
	--kplayer = setTimer ( KFrmPlayer, KFRate, 0)
	kplayer = true
	--wplayer = setTimer ( WayPtsPlayer, 1000, 0)

	--outputChatBox ( "Playback!")--"..tc.." j "..getTickCount())
end
addEvent( "onPlay", true )
addEventHandler( "onPlay", getRootElement(), beginPlay )

function setVehicleOverrideLightsEx(vehid, lst)
	setVehicleOverrideLights(getElementByID(vehid), lst)
end

function setVehicleEmerLightsEx(vehid, lst)
	call ( getResourceFromName ( "emerlights" ), "setStroboLightsOn", getElementByID(vehid), lst)
end

function StopPlay()
	timers = getTimers ()
	for timerKey, timerValue in ipairs(timers) do
		killTimer ( timerValue )
		end
	if (isRec==false) then
		timerGo = false
		if (isSoundEnable) then
			local snd = playSound ( "client/sounds/stop.wav", false )
			setSoundVolume ( snd, 0.3)
			end
	outputChatBox ("Playback aborted")
	end
	--outputChatBox ( "The server says Stop Play! "..Pkfcnt.." keyframes played")
	isPlay = false
	kplayer = false
end
addEvent( "onStopPlay", true )
addEventHandler( "onStopPlay", getRootElement(), StopPlay )

function delay(cname, val)
setElementHealth(locPlr, val)
 outputChatBox ( "health: "..val)
end
addCommandHandler("health", delay)

function optim(cname, val)
skipFMode = tonumber(val)
 outputChatBox ( "variable: "..val)
end
addCommandHandler("optim", optim)

function kfskip(cname, val)
skipFi = tonumber(val)
 outputChatBox ( "Save every "..val.." frame")
end
addCommandHandler("kfrate", kfskip)

function delay(cname, val)
if (val=="0") then
	smooth = false
	else
	smooth = true
	end
 outputChatBox ( "smooth: "..val)
end
addCommandHandler("smooth", delay)

function delay(cname, val)
sensRX = val
sensRY = val
 outputChatBox ( "sens: "..val)
end
addCommandHandler("sens", delay)

function delay(cname, val)
sensRX = val
 outputChatBox ( "sensX: "..val)
end
addCommandHandler("sensX", delay)

function delay(cname, val)
sensRY = val
 outputChatBox ( "sensY: "..val)
end
addCommandHandler("sensY", delay)

function delay(cname, val)
setMinuteDuration ( val )
 outputChatBox ( "minute duration: "..val)
end
addCommandHandler("minute", delay)

function delay(cname, val)
 dd = val
 outputChatBox ( "key delay: "..dd)
end
addCommandHandler("dd", delay)

function FreeCam2()
--local localPlayer = getLocalPlayer()
--local x,y,z = getElementPosition( localPlayer )
if (camMode~=cmFixed) then
	--outputChatBox ( "free mode 2!")
	camMode = cmFixed
	cam = {}
	cam[1] = {}
	cam[1][1],cam[1][2],cam[1][3] = getElementPosition(locPlr)
	cam[2] = {}
	cam[2][1],cam[2][2],cam[2][3] = getElementPosition(locPlr)
	cam[3] = 0
	
	else
	camMode = cmDefault
	--setElementCollisionsEnabled ( getLocalPlayer(), true )
	setElementAlpha (getLocalPlayer(), 255 )
	end
end

function FreeCam()
if (isRec==false) then
--local localPlayer = getLocalPlayer()
--local x,y,z = getElementPosition( localPlayer )
if (camMode~=cmSpect) then
	campx, campy, campz, camtx, camty, camtz = getCameraMatrix()
	---setCameraMatrix (campx, campy, campz, camtx, camty, camtz)
	rotA = math.atan2(camty-campy,camtx-campx)
	rotB = math.atan2(math.sqrt(math.pow(camtx-campx,2)+math.pow(camty-campy,2)),camtz-campz)

	--toggleAllControls ( false, true)
	lastx, lasty, lastz = getElementPosition(locPlr)
	outputChatBox ( "free mode!")
	--camMode = cmFree1 
	camMode = cmSpect 
	--setElementCollisionsEnabled ( getLocalPlayer(), false ) -- hide player ped
	--setElementAlpha (getLocalPlayer(), 0 )
	if (isHide==false) then
		lastx, lasty, lastz = getElementPosition(locPlr)
		isHide = true
		end
	
	else
	if (isDirector==false) then
		camMode = cmDefault
		--setElementCollisionsEnabled ( getLocalPlayer(), true )
		--setElementAlpha (getLocalPlayer(), 255 )
		if (isHide==true) then
			lastx, lasty, lastz = getElementPosition(locPlr)
			isHide = false
			setElementPosition(locPlr, getCameraMatrix())
			end
		setCameraTarget(getLocalPlayer())
		end
	end
end
end

function sign(x)
if (x>0) then return 1
elseif (x<0) then return -1
else return 0
end
end

function PreRender()

if (getKeyState("space")==true) then
		dP2 = -0.001
	end

if (camMode==cmDirector) then
if (cam[CC]["freeze"]==false) then
	local Time = (getTickCount() - cTime)/1000
	
	if (cam[CC]["pm"] == pmToPoint) then
		if (math.sqrt(math.pow(cam[CC]["p"]["spx"]-cam[CC]["px"],2)+math.pow(cam[CC]["p"]["spy"]-cam[CC]["py"],2)+math.pow(cam[CC]["p"]["spz"]-cam[CC]["pz"],2))<cam[CC]["p"]["mlen"]) then
			cam[CC]["p"]["ssp"] = cam[CC]["p"]["ssp"] + cam[CC]["p"]["sax"]
		else
			local s = sign(cam[CC]["p"]["ssp"])
			cam[CC]["p"]["ssp"] = cam[CC]["p"]["ssp"] + cam[CC]["p"]["sdx"]*sign(cam[CC]["p"]["ssp"])
			if (sign(cam[CC]["p"]["ssp"])~=s) then cam[CC]["p"]["ssp"]=0 end		
			end
		
		if (cam[CC]["p"]["ssp"]>cam[CC]["p"]["smaxs"]) then
			cam[CC]["p"]["ssp"]=cam[CC]["p"]["smaxs"]
		elseif (cam[CC]["p"]["ssp"]<cam[CC]["p"]["smins"]) then
			cam[CC]["p"]["ssp"]=cam[CC]["p"]["smins"]
			end
			
		cam[CC]["px"] = cam[CC]["px"] + cam[CC]["p"]["ssp"]*cam[CC]["p"]["stx"]
		cam[CC]["py"] = cam[CC]["py"] + cam[CC]["p"]["ssp"]*cam[CC]["p"]["sty"]
		cam[CC]["pz"] = cam[CC]["pz"] + cam[CC]["p"]["ssp"]*cam[CC]["p"]["stz"]
		end
	if (cam[CC]["tm"] == pmToPoint) then
		if (math.sqrt(math.pow(cam[CC]["t"]["spx"]-cam[CC]["tx"],2)+math.pow(cam[CC]["t"]["spy"]-cam[CC]["ty"],2)+math.pow(cam[CC]["t"]["spz"]-cam[CC]["tz"],2))<cam[CC]["t"]["mlen"]) then
			cam[CC]["t"]["ssp"] = cam[CC]["t"]["ssp"] + cam[CC]["t"]["sax"]
		else
			local s = sign(cam[CC]["t"]["ssp"])
			cam[CC]["t"]["ssp"] = cam[CC]["t"]["ssp"] + cam[CC]["t"]["sdx"]*sign(cam[CC]["t"]["ssp"])
			if (sign(cam[CC]["t"]["ssp"])~=s) then cam[CC]["t"]["ssp"]=0 end		
			end
		
		if (cam[CC]["t"]["ssp"]>cam[CC]["t"]["smaxs"]) then
			cam[CC]["t"]["ssp"]=cam[CC]["t"]["smaxs"]
		elseif (cam[CC]["t"]["ssp"]<cam[CC]["t"]["smins"]) then
			cam[CC]["t"]["ssp"]=cam[CC]["t"]["smins"]
			end
			
		cam[CC]["tx"] = cam[CC]["tx"] + cam[CC]["t"]["ssp"]*cam[CC]["t"]["stx"]
		cam[CC]["ty"] = cam[CC]["ty"] + cam[CC]["t"]["ssp"]*cam[CC]["t"]["sty"]
		cam[CC]["tz"] = cam[CC]["tz"] + cam[CC]["t"]["ssp"]*cam[CC]["t"]["stz"]
		end	
	if (cam[CC]["pm"] == pmRotation) then
		if (cam[CC]["p"]["rotcur"]<cam[CC]["p"]["rotlen"]) then
			cam[CC]["p"]["rots"] = cam[CC]["p"]["rots"] + cam[CC]["p"]["rotta"]
		else
			local s = sign(cam[CC]["p"]["rots"])
			cam[CC]["p"]["rots"] = cam[CC]["p"]["rots"] + cam[CC]["p"]["rottd"]*sign(cam[CC]["p"]["rots"])
			if (sign(cam[CC]["p"]["rots"])~=s) then cam[CC]["p"]["rots"]=0 end
			end
		if (cam[CC]["p"]["rots"]>cam[CC]["p"]["rottmaxs"]) then
			cam[CC]["p"]["rots"]=cam[CC]["p"]["rottmaxs"]
		elseif (cam[CC]["p"]["rots"]<cam[CC]["p"]["rottmins"]) then
			cam[CC]["p"]["rots"]=cam[CC]["p"]["rottmins"]
			end
		cam[CC]["p"]["rot"] = cam[CC]["p"]["rot"] +cam[CC]["p"]["rotc"]*cam[CC]["p"]["rots"]
		cam[CC]["p"]["rotcur"] = cam[CC]["p"]["rotcur"] + math.abs(cam[CC]["p"]["rots"])
		if (cam[CC]["p"]["pitcur"]<cam[CC]["p"]["pitlen"]) then
			cam[CC]["p"]["pits"] = cam[CC]["p"]["pits"] + cam[CC]["p"]["pitta"]
		else
			local s = sign(cam[CC]["p"]["pits"])
			cam[CC]["p"]["pits"] = cam[CC]["p"]["pits"] + cam[CC]["p"]["pittd"]*sign(cam[CC]["p"]["pits"])
			if (sign(cam[CC]["p"]["pits"])~=s) then cam[CC]["p"]["pits"]=0 end
			end
		if (cam[CC]["p"]["pits"]>cam[CC]["p"]["pittmaxs"]) then
			cam[CC]["p"]["pits"]=cam[CC]["p"]["pittmaxs"]
		elseif (cam[CC]["p"]["pits"]<cam[CC]["p"]["pittmins"]) then
			cam[CC]["p"]["pits"]=cam[CC]["p"]["pittmins"]
			end
		cam[CC]["p"]["pit"] = cam[CC]["p"]["pit"] -cam[CC]["p"]["pitc"]*cam[CC]["p"]["pits"]
		cam[CC]["p"]["pitcur"] = cam[CC]["p"]["pitcur"] + math.abs(cam[CC]["p"]["pits"])
		
		if (cam[CC]["p"]["discur"]<cam[CC]["p"]["dislen"]) then
			cam[CC]["p"]["diss"] = cam[CC]["p"]["diss"] + cam[CC]["p"]["dista"]
		else
			local s = sign(cam[CC]["p"]["diss"])
			cam[CC]["p"]["diss"] = cam[CC]["p"]["diss"] + cam[CC]["p"]["distd"]*sign(cam[CC]["p"]["diss"])
			if (sign(cam[CC]["p"]["diss"])~=s) then cam[CC]["p"]["diss"]=0 end
			end
		if (cam[CC]["p"]["diss"]>cam[CC]["p"]["distmaxs"]) then
			cam[CC]["p"]["diss"]=cam[CC]["p"]["distmaxs"]
		elseif (cam[CC]["p"]["diss"]<cam[CC]["p"]["distmins"]) then
			cam[CC]["p"]["diss"]=cam[CC]["p"]["distmins"]
			end
		cam[CC]["l"] = cam[CC]["l"] +cam[CC]["p"]["disc"]*cam[CC]["p"]["diss"]
		cam[CC]["p"]["discur"] = cam[CC]["p"]["discur"] + math.abs(cam[CC]["p"]["diss"])
				
		if (cam[CC]["p"]["pit"]>math.pi-0.1) then cam[CC]["p"]["pit"]=math.pi-0.1
			elseif (cam[CC]["p"]["pit"]<0.1) then cam[CC]["p"]["pit"]=0.1
			end
		if (cam[CC]["p"]["rot"]>math.pi*2) then cam[CC]["p"]["rot"]=cam[CC]["p"]["rot"]-math.pi*2
			elseif(cam[CC]["p"]["rot"]<0) then cam[CC]["p"]["rot"] = cam[CC]["p"]["rot"]+math.pi*2
			end
		
		cam[CC]["px"] = cam[CC]["tx"] + cam[CC]["l"]*math.cos(cam[CC]["p"]["rot"])*math.sin(cam[CC]["p"]["pit"])
		cam[CC]["py"] = cam[CC]["ty"] + cam[CC]["l"]*math.sin(cam[CC]["p"]["rot"])*math.sin(cam[CC]["p"]["pit"])
		cam[CC]["pz"] = cam[CC]["tz"] + cam[CC]["l"]*math.cos(cam[CC]["p"]["pit"])
		
		cam[CC]["t"]["rot"] = cam[CC]["p"]["rot"] + math.pi
		cam[CC]["t"]["pit"] = math.pi-cam[CC]["p"]["pit"] 		
		end
	if (cam[CC]["tm"] == pmRotation) then
		if (cam[CC]["t"]["rotcur"]<cam[CC]["t"]["rotlen"]) then
			cam[CC]["t"]["rots"] = cam[CC]["t"]["rots"] + cam[CC]["t"]["rotta"]
		else
			local s = sign(cam[CC]["t"]["rots"])
			cam[CC]["t"]["rots"] = cam[CC]["t"]["rots"] + cam[CC]["t"]["rottd"]*sign(cam[CC]["t"]["rots"])
			if (sign(cam[CC]["t"]["rots"])~=s) then cam[CC]["t"]["rots"]=0 end
			end
		if (cam[CC]["t"]["rots"]>cam[CC]["t"]["rottmaxs"]) then
			cam[CC]["t"]["rots"]=cam[CC]["t"]["rottmaxs"]
		elseif (cam[CC]["t"]["rots"]<cam[CC]["t"]["rottmins"]) then
			cam[CC]["t"]["rots"]=cam[CC]["t"]["rottmins"]
			end
		cam[CC]["t"]["rot"] = cam[CC]["t"]["rot"] +cam[CC]["t"]["rotc"]*cam[CC]["t"]["rots"]
		cam[CC]["t"]["rotcur"] = cam[CC]["t"]["rotcur"] + math.abs(cam[CC]["t"]["rots"])
		if (cam[CC]["t"]["pitcur"]<cam[CC]["t"]["pitlen"]) then
			cam[CC]["t"]["pits"] = cam[CC]["t"]["pits"] + cam[CC]["t"]["pitta"]
		else
			local s = sign(cam[CC]["t"]["pits"])
			cam[CC]["t"]["pits"] = cam[CC]["t"]["pits"] + cam[CC]["t"]["pittd"]*sign(cam[CC]["t"]["pits"])
			if (sign(cam[CC]["t"]["pits"])~=s) then cam[CC]["t"]["pits"]=0 end
			end
		if (cam[CC]["t"]["pits"]>cam[CC]["t"]["pittmaxs"]) then
			cam[CC]["t"]["pits"]=cam[CC]["t"]["pittmaxs"]
		elseif (cam[CC]["t"]["pits"]<cam[CC]["t"]["pittmins"]) then
			cam[CC]["t"]["pits"]=cam[CC]["t"]["pittmins"]
			end
		cam[CC]["t"]["pit"] = cam[CC]["t"]["pit"] -cam[CC]["t"]["pitc"]*cam[CC]["t"]["pits"]
		cam[CC]["t"]["pitcur"] = cam[CC]["t"]["pitcur"] + math.abs(cam[CC]["t"]["pits"])
		if (cam[CC]["t"]["discur"]<cam[CC]["t"]["dislen"]) then
			cam[CC]["t"]["diss"] = cam[CC]["t"]["diss"] + cam[CC]["t"]["dista"]
		else
			local s = sign(cam[CC]["t"]["diss"])
			cam[CC]["t"]["diss"] = cam[CC]["t"]["diss"] + cam[CC]["t"]["distd"]*sign(cam[CC]["t"]["diss"])
			if (sign(cam[CC]["t"]["diss"])~=s) then cam[CC]["t"]["diss"]=0 end
			end
		if (cam[CC]["t"]["diss"]>cam[CC]["t"]["distmaxs"]) then
			cam[CC]["t"]["diss"]=cam[CC]["t"]["distmaxs"]
		elseif (cam[CC]["t"]["diss"]<cam[CC]["t"]["distmins"]) then
			cam[CC]["t"]["diss"]=cam[CC]["t"]["distmins"]
			end
		cam[CC]["l"] = cam[CC]["l"] +cam[CC]["t"]["disc"]*cam[CC]["t"]["diss"]
		cam[CC]["t"]["discur"] = cam[CC]["t"]["discur"] + math.abs(cam[CC]["t"]["diss"])
				
		if (cam[CC]["t"]["pit"]>math.pi-0.1) then cam[CC]["t"]["pit"]=math.pi-0.1
			elseif (cam[CC]["t"]["pit"]<0.1) then cam[CC]["t"]["pit"]=0.1
			end
		if (cam[CC]["t"]["rot"]>math.pi*2) then cam[CC]["t"]["rot"]=cam[CC]["t"]["rot"]-math.pi*2
			elseif(cam[CC]["t"]["rot"]<0) then cam[CC]["t"]["rot"] = cam[CC]["t"]["rot"]+math.pi*2
			end
		
		cam[CC]["tx"] = cam[CC]["px"] + cam[CC]["l"]*math.cos(cam[CC]["t"]["rot"])*math.sin(cam[CC]["t"]["pit"])
		cam[CC]["ty"] = cam[CC]["py"] + cam[CC]["l"]*math.sin(cam[CC]["t"]["rot"])*math.sin(cam[CC]["t"]["pit"])
		cam[CC]["tz"] = cam[CC]["pz"] + cam[CC]["l"]*math.cos(cam[CC]["t"]["pit"])
		
		cam[CC]["p"]["rot"] = cam[CC]["t"]["rot"] + math.pi
		cam[CC]["p"]["pit"] = math.pi-cam[CC]["t"]["pit"] 		
		end	
	if (cam[CC]["tm"] == pmFree) then
		--cam[CC]["l"] = math.sqrt(math.pow(cam[CC]["tx"]-cam[CC]["px"],2)+math.pow(cam[CC]["ty"]-cam[CC]["py"],2)+math.pow(cam[CC]["tz"]-cam[CC]["pz"],2))
		--cam[CC]["t"]["rot"] = math.atan2(cam[CC]["ty"]-cam[CC]["py"],cam[CC]["tx"]-cam[CC]["px"])
		--cam[CC]["t"]["pit"] = math.atan2(cam[CC]["l"],cam[CC]["tz"]-cam[CC]["pz"])

		if (dR1~=0) then
				cam[CC]["t"]["rotms"] = cam[CC]["t"]["rotms"] + cam[CC]["t"]["rotma"]*sign(dR1)--*math.abs(dR1)
			else
				local s = sign(cam[CC]["t"]["rotms"])
				cam[CC]["t"]["rotms"] = cam[CC]["t"]["rotms"] + cam[CC]["t"]["rotmd"]*sign(cam[CC]["t"]["rotms"])
				if (sign(cam[CC]["t"]["rotms"])~=s) then cam[CC]["t"]["rotms"]=0 end
			end
		if (dP1~=0) then
				cam[CC]["t"]["pitms"] = cam[CC]["t"]["pitms"] + cam[CC]["t"]["pitma"]*sign(dP1)--*math.abs(dP1)
			else
				local s = sign(cam[CC]["t"]["pitms"])
				cam[CC]["t"]["pitms"] = cam[CC]["t"]["pitms"] + cam[CC]["t"]["pitmd"]*sign(cam[CC]["t"]["pitms"])
				if (sign(cam[CC]["t"]["pitms"])~=s) then cam[CC]["t"]["pitms"]=0 end
			end
		if (cam[CC]["t"]["rotms"]>cam[CC]["t"]["rotmaxs"]) then
				cam[CC]["t"]["rotms"] = cam[CC]["t"]["rotmaxs"]
			elseif (cam[CC]["t"]["rotms"]<cam[CC]["t"]["rotmins"]) then
				cam[CC]["t"]["rotms"] = cam[CC]["t"]["rotmins"]			
				end
		if (cam[CC]["t"]["pitms"]>cam[CC]["t"]["pitmaxs"]) then
				cam[CC]["t"]["pitms"] = cam[CC]["t"]["pitmaxs"]
			elseif (cam[CC]["t"]["pitms"]<cam[CC]["t"]["pitmins"]) then
				cam[CC]["t"]["pitms"] = cam[CC]["t"]["pitmins"]			
				end
			cam[CC]["t"]["rot"] = cam[CC]["t"]["rot"] + cam[CC]["t"]["rotms"]
			cam[CC]["t"]["pit"] = cam[CC]["t"]["pit"] + cam[CC]["t"]["pitms"]
			
		if (cam[CC]["t"]["pit"]>math.pi-0.1) then cam[CC]["t"]["pit"]=math.pi-0.1
			elseif (cam[CC]["t"]["pit"]<0.1) then cam[CC]["t"]["pit"]=0.1
			end
		if (cam[CC]["t"]["rot"]>math.pi*2) then cam[CC]["t"]["rot"]=cam[CC]["t"]["rot"]-math.pi*2
			elseif(cam[CC]["t"]["rot"]<0) then cam[CC]["t"]["rot"] = cam[CC]["t"]["rot"]+math.pi*2
			end
			cam[CC]["tx"] = cam[CC]["px"] + cam[CC]["l"]*math.cos(cam[CC]["t"]["rot"])*math.sin(cam[CC]["t"]["pit"])
			cam[CC]["ty"] = cam[CC]["py"] + cam[CC]["l"]*math.sin(cam[CC]["t"]["rot"])*math.sin(cam[CC]["t"]["pit"])
			cam[CC]["tz"] = cam[CC]["pz"] + cam[CC]["l"]*math.cos(cam[CC]["t"]["pit"])		
			
			cam[CC]["p"]["rot"] = cam[CC]["t"]["rot"] + math.pi
			cam[CC]["p"]["pit"] = math.pi-cam[CC]["t"]["pit"] 		
		end
	if (cam[CC]["pm"] == pmFree) then
		--cam[CC]["l"] = math.sqrt(math.pow(cam[CC]["tx"]-cam[CC]["px"],2)+math.pow(cam[CC]["ty"]-cam[CC]["py"],2)+math.pow(cam[CC]["tz"]-cam[CC]["pz"],2))
		--cam[CC]["p"]["rot"] = math.atan2(cam[CC]["py"]-cam[CC]["ty"],cam[CC]["px"]-cam[CC]["tx"])
		--cam[CC]["p"]["pit"] = math.atan2(cam[CC]["l"],cam[CC]["pz"]-cam[CC]["tz"])

		if (getKeyState("w")==true) then
			cam[CC]["ls"] = cam[CC]["ls"] - cam[CC]["la"]
		elseif (getKeyState("s")==true) then
			cam[CC]["ls"] = cam[CC]["ls"] + cam[CC]["la"]
		else
			local s = sign(cam[CC]["ls"])
			cam[CC]["ls"] = cam[CC]["ls"] + cam[CC]["ld"]*sign(cam[CC]["ls"])
			if (sign(cam[CC]["ls"])~=s) then
				cam[CC]["ls"] = 0
				end
			end
		if (cam[CC]["ls"]>cam[CC]["lmaxs"]) then
			cam[CC]["ls"] = cam[CC]["lmaxs"]
		elseif (cam[CC]["ls"]<cam[CC]["lmins"]) then
			cam[CC]["ls"] = cam[CC]["lmins"]
		end
		
		cam[CC]["l"] = cam[CC]["l"] + cam[CC]["ls"]
		
		if (cam[CC]["l"]<0.55) then 
			cam[CC]["l"] = 0.55
			cam[CC]["ls"] = 0
			end
		if (getKeyState("a")==true) then
			dR2 = -0.001
		elseif (getKeyState("d")==true) then
			dR2 = 0.001
		end
		if (dR2~=0) then
				cam[CC]["p"]["rotms"] = cam[CC]["p"]["rotms"] + cam[CC]["p"]["rotma"]*sign(dR2)--*math.abs(dR1)
			else
				local s = sign(cam[CC]["p"]["rotms"])
				cam[CC]["p"]["rotms"] = cam[CC]["p"]["rotms"] + cam[CC]["p"]["rotmd"]*sign(cam[CC]["p"]["rotms"])
				if (sign(cam[CC]["p"]["rotms"])~=s) then cam[CC]["p"]["rotms"]=0 end
			end
		if (dP2~=0) then
				cam[CC]["p"]["pitms"] = cam[CC]["p"]["pitms"] + cam[CC]["p"]["pitma"]*sign(dP2)--*math.abs(dP1)
			else
				local s = sign(cam[CC]["p"]["pitms"])
				cam[CC]["p"]["pitms"] = cam[CC]["p"]["pitms"] + cam[CC]["p"]["pitmd"]*sign(cam[CC]["p"]["pitms"])
				if (sign(cam[CC]["p"]["pitms"])~=s) then cam[CC]["p"]["pitms"]=0 end
			end
		if (cam[CC]["p"]["rotms"]>cam[CC]["p"]["rotmaxs"]) then
				cam[CC]["p"]["rotms"] = cam[CC]["p"]["rotmaxs"]
			elseif (cam[CC]["p"]["rotms"]<cam[CC]["p"]["rotmins"]) then
				cam[CC]["p"]["rotms"] = cam[CC]["p"]["rotmins"]			
				end
		if (cam[CC]["p"]["pitms"]>cam[CC]["p"]["pitmaxs"]) then
				cam[CC]["p"]["pitms"] = cam[CC]["p"]["pitmaxs"]
			elseif (cam[CC]["p"]["pitms"]<cam[CC]["p"]["pitmins"]) then
				cam[CC]["p"]["pitms"] = cam[CC]["p"]["pitmins"]			
				end
			cam[CC]["p"]["rot"] = cam[CC]["p"]["rot"] + cam[CC]["p"]["rotms"]
			cam[CC]["p"]["pit"] = cam[CC]["p"]["pit"] + cam[CC]["p"]["pitms"]
			
		if (cam[CC]["p"]["pit"]>math.pi-0.1) then cam[CC]["p"]["pit"]=math.pi-0.1
			elseif (cam[CC]["p"]["pit"]<0.1) then cam[CC]["p"]["pit"]=0.1
			end
		if (cam[CC]["p"]["rot"]>math.pi*2) then cam[CC]["p"]["rot"]=cam[CC]["p"]["rot"]-math.pi*2
			elseif(cam[CC]["p"]["rot"]<0) then cam[CC]["p"]["rot"] = cam[CC]["p"]["rot"]+math.pi*2
			end
			cam[CC]["px"] = cam[CC]["tx"] + cam[CC]["l"]*math.cos(cam[CC]["p"]["rot"])*math.sin(cam[CC]["p"]["pit"])
			cam[CC]["py"] = cam[CC]["ty"] + cam[CC]["l"]*math.sin(cam[CC]["p"]["rot"])*math.sin(cam[CC]["p"]["pit"])
			cam[CC]["pz"] = cam[CC]["tz"] + cam[CC]["l"]*math.cos(cam[CC]["p"]["pit"])
		
			cam[CC]["t"]["rot"] = cam[CC]["p"]["rot"] + math.pi
			cam[CC]["t"]["pit"] = math.pi-cam[CC]["p"]["pit"] 		
			end
	if (cam[CC]["pm"] == pmFree)or(cam[CC]["tm"] == pmFree) then
		if (getKeyState("arrow_u")==true) then
			cam[CC]["p"]["s"] = cam[CC]["p"]["s"] - cam[CC]["p"]["sa"]
			elseif (getKeyState("arrow_d")==true) then
			cam[CC]["p"]["s"] = cam[CC]["p"]["s"] + cam[CC]["p"]["sa"]
			else
			local s = sign(cam[CC]["p"]["s"])
			cam[CC]["p"]["s"] = cam[CC]["p"]["s"] + cam[CC]["p"]["sd"]*sign(cam[CC]["p"]["s"])
			if (sign(cam[CC]["p"]["s"])~=s) then
				cam[CC]["p"]["s"] = 0
				end		
			end
		if (cam[CC]["p"]["s"]>cam[CC]["p"]["smax"]) then
			cam[CC]["p"]["s"]=cam[CC]["p"]["smax"]
		elseif (cam[CC]["p"]["s"]<cam[CC]["p"]["smin"]) then
			cam[CC]["p"]["s"]=cam[CC]["p"]["smin"]
			end

		if (getKeyState("arrow_l")==true) then
			cam[CC]["p"]["st"] = cam[CC]["p"]["st"] - cam[CC]["p"]["sta"]
			elseif (getKeyState("arrow_r")==true) then
			cam[CC]["p"]["st"] = cam[CC]["p"]["st"] + cam[CC]["p"]["sta"]
			else
			local s = sign(cam[CC]["p"]["st"])
			cam[CC]["p"]["st"] = cam[CC]["p"]["st"] + cam[CC]["p"]["std"]*sign(cam[CC]["p"]["st"])
			if (sign(cam[CC]["p"]["st"])~=s) then
				cam[CC]["p"]["st"] = 0
				end		
			end	
		if (cam[CC]["p"]["st"]>cam[CC]["p"]["stmax"]) then
			cam[CC]["p"]["st"]=cam[CC]["p"]["stmax"]
		elseif (cam[CC]["p"]["st"]<cam[CC]["p"]["stmin"]) then
			cam[CC]["p"]["st"]=cam[CC]["p"]["stmin"]
			end
		local mx = cam[CC]["p"]["s"]*(math.cos(cam[CC]["p"]["rot"])*math.sin(cam[CC]["p"]["pit"]))+cam[CC]["p"]["st"]*(math.cos(cam[CC]["p"]["rot"]+math.pi2)*math.sin(cam[CC]["p"]["pit"]))
		local my = cam[CC]["p"]["s"]*(math.sin(cam[CC]["p"]["rot"])*math.sin(cam[CC]["p"]["pit"]))+cam[CC]["p"]["st"]*(math.sin(cam[CC]["p"]["rot"]+math.pi2)*math.sin(cam[CC]["p"]["pit"]))
		local mz = cam[CC]["p"]["s"]*math.cos(cam[CC]["p"]["pit"])	
		if (cam[CC]["pm"] == pmFree) then
			cam[CC]["px"] = cam[CC]["px"] + mx
			cam[CC]["py"] = cam[CC]["py"] + my
			cam[CC]["pz"] = cam[CC]["pz"] + mz	
			end
		if (cam[CC]["tm"] == pmFree) then
			cam[CC]["tx"] = cam[CC]["tx"] + mx
			cam[CC]["ty"] = cam[CC]["ty"] + my
			cam[CC]["tz"] = cam[CC]["tz"] + mz		
			end	
		end
	
	end
	
	local ctx,cty,ctz = 0
	if (cam[CC]["t"]["obj"]~=false) then
		local matrix =  getElementMatrix (getElementByID(cam[CC]["t"]["objID"]))
		ctx = cam[CC]["tx"] * matrix[1][1] + cam[CC]["ty"] * matrix[2][1] + cam[CC]["tz"] * matrix[3][1] + matrix[4][1]
		cty = cam[CC]["tx"] * matrix[1][2] + cam[CC]["ty"] * matrix[2][2] + cam[CC]["tz"] * matrix[3][2] + matrix[4][2]
		ctz = cam[CC]["tx"] * matrix[1][3] + cam[CC]["ty"] * matrix[2][3] + cam[CC]["tz"] * matrix[3][3] + matrix[4][3]		
	else
		ctx = cam[CC]["tx"] 
		cty = cam[CC]["ty"]	
		ctz = cam[CC]["tz"]
		end
	local ptx,pty,ptz = 0
	if (cam[CC]["p"]["obj"]~=false) then
		local matrix =  getElementMatrix (getElementByID(cam[CC]["p"]["objID"]))
		cpx = cam[CC]["px"] * matrix[1][1] + cam[CC]["py"] * matrix[2][1] + cam[CC]["pz"] * matrix[3][1] + matrix[4][1]
		cpy = cam[CC]["px"] * matrix[1][2] + cam[CC]["py"] * matrix[2][2] + cam[CC]["pz"] * matrix[3][2] + matrix[4][2]
		cpz = cam[CC]["px"] * matrix[1][3] + cam[CC]["py"] * matrix[2][3] + cam[CC]["pz"] * matrix[3][3] + matrix[4][3]		
	else
		cpx = cam[CC]["px"] 
		cpy = cam[CC]["py"]	
		cpz = cam[CC]["pz"]
		end	
	if (CC == "test") then setElementPosition(tmpobj, ctx , cty, ctz)
		else
		setElementPosition(tmpobj, 0 ,0, -10000)
		end
	-- fov
	if (cam[CC]["fm"] == pmFree) then
	if (getKeyState("e")==true)and(getKeyState("mouse2")==false) then
		cam[CC]["fov"]["fovms"] = cam[CC]["fov"]["fovms"] - cam[CC]["fov"]["fovma"]
		elseif (getKeyState("q")==true)and(getKeyState("mouse2")==false) then
		cam[CC]["fov"]["fovms"] = cam[CC]["fov"]["fovms"] + cam[CC]["fov"]["fovma"]
		else
		local s = sign(cam[CC]["fov"]["fovms"])
		cam[CC]["fov"]["fovms"] = cam[CC]["fov"]["fovms"] + cam[CC]["fov"]["fovmd"]*sign(cam[CC]["fov"]["fovms"])
		if (sign(cam[CC]["fov"]["fovms"])~=s) then
			cam[CC]["fov"]["fovms"] = 0
			end		
		end
	end
	if (cam[CC]["fov"]["fovms"]>cam[CC]["fov"]["fovmaxs"]) then
			cam[CC]["fov"]["fovms"]=cam[CC]["fov"]["fovmaxs"]
		elseif (cam[CC]["fov"]["fovms"]<cam[CC]["fov"]["fovmins"]) then
			cam[CC]["fov"]["fovms"]=cam[CC]["fov"]["fovmins"]
			end	
	if (cam[CC]["fov"]["fovcs"]~=0) then
		cam[CC]["fov"]["fovms"] = cam[CC]["fov"]["fovcs"]
		end
	cam[CC]["fov"]["fov"] = cam[CC]["fov"]["fov"] + cam[CC]["fov"]["fovms"]
	if (cam[CC]["fov"]["fov"]>cam[CC]["fov"]["fovmax"]) then
			cam[CC]["fov"]["fov"]=cam[CC]["fov"]["fovmax"]
			cam[CC]["fov"]["fovms"] = 0
		elseif (cam[CC]["fov"]["fov"]<cam[CC]["fov"]["fovmin"]) then
			cam[CC]["fov"]["fov"]=cam[CC]["fov"]["fovmin"]
			cam[CC]["fov"]["fovms"] = 0
			end		
	-- roll
	if (cam[CC]["rm"] == pmFree) then
	if (getKeyState("q")==true)and(getKeyState("mouse2")==true) then
		cam[CC]["rol"]["rolms"] = cam[CC]["rol"]["rolms"] + cam[CC]["rol"]["rolma"]
		elseif (getKeyState("e")==true)and(getKeyState("mouse2")==true) then
		cam[CC]["rol"]["rolms"] = cam[CC]["rol"]["rolms"] - cam[CC]["rol"]["rolma"]
		else
		local s = sign(cam[CC]["rol"]["rolms"])
		cam[CC]["rol"]["rolms"] = cam[CC]["rol"]["rolms"] + cam[CC]["rol"]["rolmd"]*sign(cam[CC]["rol"]["rolms"])
		if (sign(cam[CC]["rol"]["rolms"])~=s) then
			cam[CC]["rol"]["rolms"] = 0
			end		
		end
	end
	if (cam[CC]["rol"]["rolms"]>cam[CC]["rol"]["rolmaxs"]) then
			cam[CC]["rol"]["rolms"]=cam[CC]["rol"]["rolmaxs"]
		elseif (cam[CC]["rol"]["rolms"]<cam[CC]["rol"]["rolmins"]) then
			cam[CC]["rol"]["rolms"]=cam[CC]["rol"]["rolmins"]
			end	
	if (cam[CC]["rol"]["rolcs"]~=0) then
		cam[CC]["rol"]["rolms"] = cam[CC]["rol"]["rolcs"]
		end
	cam[CC]["rol"]["rol"] = cam[CC]["rol"]["rol"] + cam[CC]["rol"]["rolms"]
	if (cam[CC]["rol"]["rolunl"]==false) then
		if (cam[CC]["rol"]["rol"]>cam[CC]["rol"]["rolmax"]) then
				cam[CC]["rol"]["rol"]=cam[CC]["rol"]["rolmax"]
				cam[CC]["rol"]["rolms"] = 0
			elseif (cam[CC]["rol"]["rol"]<cam[CC]["rol"]["rolmin"]) then
				cam[CC]["rol"]["rol"]=cam[CC]["rol"]["rolmin"]
				cam[CC]["rol"]["rolms"] = 0
				end	
	else
		if (cam[CC]["rol"]["rol"] > 360) then
			cam[CC]["rol"]["rol"] =cam[CC]["rol"]["rol"] - 360
		elseif (cam[CC]["rol"]["rol"] < -360) then
			cam[CC]["rol"]["rol"] =cam[CC]["rol"]["rol"]  +360
			end
	end
	setCameraMatrix (cpx,cpy,cpz,ctx,cty,ctz,cam[CC]["rol"]["rol"],cam[CC]["fov"]["fov"])
	dR1 = 0
	dP1 = 0
	dR2 = 0
	dP2 = 0
	cTime = getTickCount()
elseif (camMode==cmSpect) then
local camSpd = camSpeed

--campx, campy, campz, camtx, camty, camtz = getCameraMatrix()

matX = math.cos(rotA)*math.sin(rotB)
matY = math.sin(rotA)*math.sin(rotB)
matZ = math.cos(rotB)

	if (getControlState("sprint")) then
		camSpd = camSpeed*6
		end
	if (getControlState("forwards")) then
		campz = campz + camSpd*matZ
		campx = campx + camSpd*matX
		campy = campy + camSpd*matY	
		end
	if (getControlState("backwards")) then
		campz = campz - camSpd*matZ
		campx = campx - camSpd*matX
		campy = campy - camSpd*matY	
		end
	if (getControlState("left")) then
		campx = campx + camSpd*math.cos(rotA+math.pi2)*math.sin(rotB)
		campy = campy + camSpd*math.sin(rotA+math.pi2)*math.sin(rotB)
		end
	if (getControlState("right")) then
		campx = campx - camSpd*math.cos(rotA+math.pi2)*math.sin(rotB)
		campy = campy - camSpd*math.sin(rotA+math.pi2)*math.sin(rotB)	
		end		
	camtz = campz + camLen*matZ
	camtx = campx + camLen*matX
	camty = campy + camLen*matY
	setCameraMatrix (campx, campy, campz, camtx, camty, camtz)
	--guiSetText( textLabel, "X: " .. tostring( campx ) .. ";  Y: ".. tostring( campy).."   ".."X: " .. tostring( camtx ) .. ";  Y: ".. tostring( camty)  )
elseif (camMode==cmFixed) then
	local campx = -2
	local campy = -3
	local campz = 1.0
	
	local camtx = 0
	local camty = 1
	local camtz = 0.7

	local tcampx = campx
	local tcampy = campy
	local tcampz = campz
	
	local tcamtx = camtx
	local tcamty = camty
	local tcamtz = camtz	
	
	--local matrix =  getElementMatrix ( getElementByID("vehicle (Oceanic) (1)") )
	--setCameraTarget(locPlr)
	local matrix =  getElementMatrix ( locPlr )
	-- I love it!
	campx = tcampx * matrix[1][1] + tcampy * matrix[2][1] + tcampz * matrix[3][1] + matrix[4][1]
	campy = tcampx * matrix[1][2] + tcampy * matrix[2][2] + tcampz * matrix[3][2] + matrix[4][2]
	campz = tcampx * matrix[1][3] + tcampy * matrix[2][3] + tcampz * matrix[3][3] + matrix[4][3]

	camtx = tcamtx * matrix[1][1] + tcamty * matrix[2][1] + tcamtz * matrix[3][1] + matrix[4][1]
	camty = tcamtx * matrix[1][2] + tcamty * matrix[2][2] + tcamtz * matrix[3][2] + matrix[4][2]
	camtz = tcamtx * matrix[1][3] + tcamty * matrix[2][3] + tcamtz * matrix[3][3] + matrix[4][3]
	
	--local tx,ty,tz = getElementPosition( getElementByID("vehicle (Oceanic) (1)"))
	--dxDrawLine3D ( tx, ty, tz, camtx, camty, camtz, tocolor ( 0, 255, 0, 230 ), 2)
	--dxDrawText( tostring(math.floor(camtx-tx)), 44, 43)
	
	--
	local dx = cam[2][1] - cam[1][1]
	local dy = cam[2][2] - cam[1][2]
	local dz = cam[2][3] - cam[1][3]
	dx = cam[2][1] + dx
	dy = cam[2][2] + dy
	dz = cam[2][3] + dz
	--camtx = (camtx/3+dx*2/3)
	--camty = (camty/3+dy*2/3)
	--camtz = (camtz/3+dz*2/3)
	
	--cam[1] = cam[2]
	--cam[2][1] = camtx
	--cam[2][2] = camty
	--cam[2][3] = camtz
	--cam[3] = cam[3] + 0.005
	--setPedFrozen(locPlr, true)
	--local a, b , c = getVehicleRotation(getElementByID("vehicle (Oceanic) (1)"))
	setCameraMatrix (campx ,campy,campz,camtx,camty,camtz)
	--dxDrawText( tostring(math.floor(a)), 44, 43)
	--setElementPosition ( tmpobj,  camtx, camty, camtz)
elseif (camMode==cmDefault) then
	--local cx, cy, cz, ctx, cty, ctz = getCameraMatrix()
	--setPedLookAt (getLocalPlayer(),ctx+4*(ctx-cx), cty+4*(cty-cy), ctz+4*(ctz-cz))	
	end
if (isHide==true) then
	setElementPosition (locPlr,0,0,6000)
	end

if (isPedInVehicle (locPlr)) then
	if (speedLimit>0) then
		if (getVehicleOccupant(getPedOccupiedVehicle(locPlr),0)==locPlr) then
			local vx,vy,vz = getElementVelocity(getPedOccupiedVehicle(locPlr))
			local n = (vx^2 + vy^2 + vz^2)^(0.5)
			if (n>speedLimit) then
				n = speedLimit/n
				vx = vx*n
				vy = vy*n
				vz = vz*n
				setElementVelocity(getPedOccupiedVehicle(locPlr),vx,vy,vz)
				end
			end
		end
	end
	
end
addEventHandler( "onClientPreRender", getRootElement(), PreRender)


function Render()

if (ksaver==true) then
if (skipF>=skipFi)or(skipFMode==1) then
	if (isPedInVehicle (locPlr)==false) then-- on foot
			local cx, cy, cz, ctx, cty, ctz = getCameraMatrix()
			local rot = math.atan2(cty-cy,ctx-cx)
				
			AdCurr = {}
			AdCurr["d"] = (getTickCount()-startTime)
			AdCurr[1] = math.deg(-rot+math.pi2)--*180/math.pi
			AdCurr[2] = ctx+20*(ctx-cx)
			AdCurr[3] = cty+20*(cty-cy)
			AdCurr[4] = ctz+20*(ctz-cz)
			AdCurr[5],AdCurr[6],AdCurr[7] = getElementPosition(locPlr)
			AdCurr[8],AdCurr[9],AdCurr[10] =  getElementVelocity(locPlr)
			AdCurr[11]=getPedControlState( locPlr, "crouch" )
			
			if (skipFMode==1) then
				local save = 0
				if (type(AdCurr[1])~=type(AdLast[1]))then
					save = 1
				elseif (kwrite) then
					save = 1
					kwrite = false
				elseif (math.abs(AdCurr[1]-AdLast[1])>skipAd10) then
					save = 1
				elseif (getDistanceBetweenPoints3D(AdCurr[2],AdCurr[3],AdCurr[4],AdLast[2],AdLast[3],AdLast[4])>skipAd20) then
					--save = 1
				elseif (getDistanceBetweenPoints3D(AdCurr[5],AdCurr[6],AdCurr[7],AdLast[5],AdLast[6],AdLast[7])>skipAd) then
					save = 1
				elseif (getDistanceBetweenPoints3D(AdCurr[8],AdCurr[9],AdCurr[10],AdLast[8],AdLast[9],AdLast[10])>skipAd) then
					save = 1
				elseif (AdCurr[11]~=AdLast[11]) then
					save = 1
				end
			
				if (save==1) then
					tmpKeyFrame[kfcnt] = AdCurr
					kfcnt = kfcnt + 1
					AdLast = AdCurr
					end
			
			else
				tmpKeyFrame[kfcnt] = AdCurr
				kfcnt = kfcnt + 1
			end			
			
			
			
			
			--tmpKeyFrame[kfcnt][12]=getPedRotation(locPlr)
			--if (getControlState("aim_weapon")==true) then
				--tmpKeyFrame[kfcnt][8] = getPedRotation(locPlr)
				--outputChatBox ("aim")
			--	else
				--tmpKeyFrame[kfcnt][8] = nil
			--	end
			
		else
			AdCurr = {}
		
			tmpKeyFrame[kfcnt] = {}
			AdCurr["d"] = (getTickCount()-startTime)
			AdCurr[1] = false
			-- if driver
			local veh = getPedOccupiedVehicle (locPlr)
			-- 1.4.5
			if (veh~=false) then
				local occ = getVehicleOccupant ( veh, 0 )
				if (occ==locPlr) then
					AdCurr[2] = getElementID(veh)
					AdCurr[3],AdCurr[4],AdCurr[5] = getElementRotation (veh)
					AdCurr[6],AdCurr[7],AdCurr[8] = getVehicleTurnVelocity (veh)
					AdCurr[9],AdCurr[10],AdCurr[11] = getElementVelocity (veh)
					AdCurr[12],AdCurr[13],AdCurr[14] = getElementPosition(veh)
					--tmpKeyFrame[kfcnt][15]=getPedControlState ( locPlr, "accelerate" )
					--tmpKeyFrame[kfcnt][16]=getPedControlState ( locPlr, "brake_reverse" )
					--tmpKeyFrame[kfcnt][17]=getPedControlState ( locPlr, "handbrake" )
					--tmpKeyFrame[kfcnt][18]=getPedControlState ( locPlr, "vehicle_left" )
					--tmpKeyFrame[kfcnt][19]=getPedControlState ( locPlr, "vehicle_right" )
					--tmpKeyFrame[kfcnt][20]=getPedControlState ( locPlr, "horn" )
					--local t = getVehicleType(veh)
					--if (t=="BMX") then
					--tmpKeyFrame[kfcnt][21]=getPedControlState ( locPlr, "vehicle_secondary_fire" )
					--	end
					--tmpKeyFrame[kfcnt][22]=getPedControlState ( locPlr, "steer_forward" )
					--tmpKeyFrame[kfcnt][23]=getPedControlState ( locPlr, "steer_back" )
				if (skipFMode==1) then
					local save = 0
					if (type(AdCurr[1])~=type(AdLast[1]))then
						save = 1
					elseif (kwrite) then
						save = 1
						kwrite = false
					elseif (getDistanceBetweenPoints3D(AdCurr[6],AdCurr[7],AdCurr[8],AdLast[6],AdLast[7],AdLast[8])>skipAdA5) then
						save = 1
					elseif (getDistanceBetweenPoints3D(AdCurr[9],AdCurr[10],AdCurr[11],AdLast[9],AdLast[10],AdLast[11])>skipAdA5) then
						save = 1
					elseif (getDistanceBetweenPoints3D(AdCurr[12],AdCurr[13],AdCurr[14],AdLast[12],AdLast[13],AdLast[14])>skipAdA) then
						save = 1
					end				
					
					if (save==1) then
						tmpKeyFrame[kfcnt] = AdCurr
						abz1 = kfcnt
						kfcnt = kfcnt + 1
						
						AdLast = AdCurr
						end				
					else
					tmpKeyFrame[kfcnt] = AdCurr
					kfcnt = kfcnt + 1
					end	
					else
					-- driveby
					AdCurr[2] = false
					if (isPedDoingGangDriveby(locPlr)==true) then
						AdCurr[3] = true
						
						AdCurr[4],AdCurr[5],AdCurr[6] = getPedTargetCollision(locPlr)
						if (AdCurr[4]==false) then
							AdCurr[4],AdCurr[5],AdCurr[6] = getPedTargetEnd(locPlr)
							end
						
						else
						AdCurr[3] = false
						end
					if (skipFMode==1) then
						local save = 0
						if (type(AdCurr[1])~=type(AdLast[1]))then
							save=1
							elseif (AdCurr[3]~=AdLast[3]) then
							save=1
							elseif (AdCurr[3]==true)and(AdLast[3]==true)and(getDistanceBetweenPoints3D(AdCurr[4],AdCurr[5],AdCurr[6],AdLast[4],AdLast[5],AdLast[6])>skipAdA) then
							save = 1
							end	
									
						if (save==1) then
							tmpKeyFrame[kfcnt] = AdCurr
							abz1 = kfcnt
							kfcnt = kfcnt + 1
							AdLast = AdCurr
							end				
						else
						tmpKeyFrame[kfcnt] = AdCurr
						kfcnt = kfcnt + 1
						end					
					end
			end
		end
		
		skipF = 1
	else
	skipF = skipF+1
	end	
end

if (kplayer==true) then
	local playend = true
	for i, par in pairs(tmpData) do
	if (1>0) then
	local Pkfcnt = par["kfrm"]["k"]
	local Pkfcnt1 = 0
	local nt = 0
	local ion = true
	local dt = 0
		if (par["kfrm"][Pkfcnt]~=nil ) then
		-- time
		nt = getTickCount()-tc
		if (nt>par["kfrm"][Pkfcnt]["d"]) then
			while ((nt>par["kfrm"][Pkfcnt]["d"])and(Pkfcnt<par["kfrm"]["km"])and(nt>par["kfrm"][Pkfcnt+1]["d"])) do
				Pkfcnt = Pkfcnt + 1
				end
			if (Pkfcnt>=par["kfrm"]["km"]) then
				Pkfcnt1 = Pkfcnt
				--outputChatBox ("must stop")
				dt = 0.000001
				else
				Pkfcnt1 = Pkfcnt + 1
				playend = false
				dt = (par["kfrm"][Pkfcnt1]["d"]-par["kfrm"][Pkfcnt]["d"])
				end						
			else
			while ((par["kfrm"][Pkfcnt]["d"]>nt)and(Pkfcnt>0)) do
				Pkfcnt = Pkfcnt - 1
				end	
			Pkfcnt1 = Pkfcnt + 1
			playend = false

			if (par["kfrm"][Pkfcnt1]==nil) then
				par["kfrm"][Pkfcnt1] = par["kfrm"][Pkfcnt]
				end
			
			dt = (par["kfrm"][Pkfcnt1]["d"]-par["kfrm"][Pkfcnt]["d"])
			end
			
			if (type(par["kfrm"][Pkfcnt][1])~=type(par["kfrm"][Pkfcnt1][1])) then
				Pkfcnt1 = Pkfcnt
				dt = 0.000001
				end
			
			if (par["kfrm"][Pkfcnt][1]~=false) then -- on foot
			local k = (nt-par["kfrm"][Pkfcnt]["d"])/dt
			local x,y,z = vi(k, par["kfrm"][Pkfcnt][5], par["kfrm"][Pkfcnt][6], par["kfrm"][Pkfcnt][7], par["kfrm"][Pkfcnt1][5], par["kfrm"][Pkfcnt1][6], par["kfrm"][Pkfcnt1][7])
			local an = si(k, par["kfrm"][Pkfcnt][1], par["kfrm"][Pkfcnt1][1])
			--local an2 = si(k, par["kfrm"][Pkfcnt][12], par["kfrm"][Pkfcnt1][12])
			local vx,vy,vz = vi(k, par["kfrm"][Pkfcnt][8], par["kfrm"][Pkfcnt][9], par["kfrm"][Pkfcnt][10], par["kfrm"][Pkfcnt1][8], par["kfrm"][Pkfcnt1][9], par["kfrm"][Pkfcnt1][10])
		
			--if (smooth==true) then
				setPedCameraRotation ( par["ped"],an)
				setElementPosition ( par["ped"], x, y, z, false)
				setElementVelocity (par["ped"], vx, vy, vz)
			--else
			--	setPedCameraRotation ( par["ped"], par["kfrm"][Pkfcnt][1])
			--	setElementPosition(par["ped"], par["kfrm"][Pkfcnt][5], par["kfrm"][Pkfcnt][6],par["kfrm"][Pkfcnt][7], false)
			--	setElementVelocity (par["ped"], par["kfrm"][Pkfcnt][8],par["kfrm"][Pkfcnt][9],par["kfrm"][Pkfcnt][10])	
			--end
			--	abz1 = getPedRotation(locPlr)
				--set
				
				setPedControlState ( par["ped"], "crouch", par["kfrm"][Pkfcnt][11] )
			--abz1 = 	par["kfrm"][Pkfcnt1]["d"] - par["kfrm"][Pkfcnt]["d"]
			else -- vehicle
				if (par["kfrm"][Pkfcnt][2]~=false) then
				local k = (nt-par["kfrm"][Pkfcnt]["d"])/dt
				local x,y,z = vi(k, par["kfrm"][Pkfcnt][12], par["kfrm"][Pkfcnt][13], par["kfrm"][Pkfcnt][14], par["kfrm"][Pkfcnt1][12], par["kfrm"][Pkfcnt1][13], par["kfrm"][Pkfcnt1][14])
				--abz1 = par["kfrm"][Pkfcnt][3]--tostring(k)
				local rx,ry,rz = ai(k, par["kfrm"][Pkfcnt][3], par["kfrm"][Pkfcnt][4], par["kfrm"][Pkfcnt][5], par["kfrm"][Pkfcnt1][3], par["kfrm"][Pkfcnt1][4], par["kfrm"][Pkfcnt1][5])
				local vx,vy,vz = vi(k, par["kfrm"][Pkfcnt][9], par["kfrm"][Pkfcnt][10], par["kfrm"][Pkfcnt][11], par["kfrm"][Pkfcnt1][9], par["kfrm"][Pkfcnt1][10], par["kfrm"][Pkfcnt1][11])
				local tvx,tvy,tvz = vi(k, par["kfrm"][Pkfcnt][6], par["kfrm"][Pkfcnt][7], par["kfrm"][Pkfcnt][8], par["kfrm"][Pkfcnt1][6], par["kfrm"][Pkfcnt1][7], par["kfrm"][Pkfcnt1][8])
								
				local veh = getElementByID(par["kfrm"][Pkfcnt][2])
				--if (smooth==false) then
				--	setVehicleTurnVelocity (veh,par["kfrm"][Pkfcnt][6],par["kfrm"][Pkfcnt][7],par["kfrm"][Pkfcnt][8])
				--	setElementVelocity (veh,par["kfrm"][Pkfcnt][9],par["kfrm"][Pkfcnt][10],par["kfrm"][Pkfcnt][11])
				--	setElementPosition (veh,par["kfrm"][Pkfcnt][12],par["kfrm"][Pkfcnt][13],par["kfrm"][Pkfcnt][14], false)
				--	setElementRotation (veh,par["kfrm"][Pkfcnt][3],par["kfrm"][Pkfcnt][4],par["kfrm"][Pkfcnt][5])
			
				--	else
					setElementPosition (veh, x,y,z)
					setElementVelocity (veh, vx,vy,vz)
					setVehicleTurnVelocity (veh, tvx,tvy,tvz)
					setElementRotation (veh, rx,ry,rz)
				--	end

				--setElementRotation (veh, rx,ry,rz)
				--setPedControlState ( par["ped"], "accelerate", par["kfrm"][Pkfcnt][15] )
				--setPedControlState ( par["ped"], "brake_reverse", par["kfrm"][Pkfcnt][16] )
				--setPedControlState ( par["ped"], "handbrake", par["kfrm"][Pkfcnt][17] )
				--setPedControlState ( par["ped"], "vehicle_left", par["kfrm"][Pkfcnt][18] )
				--setPedControlState ( par["ped"], "vehicle_right", par["kfrm"][Pkfcnt][19] )
				--setPedControlState ( par["ped"], "horn", par["kfrm"][Pkfcnt][20] )
				--setPedControlState ( par["ped"], "vehicle_secondary_fire", par["kfrm"][Pkfcnt][21] )
				--setPedControlState ( par["ped"], "steer_forward", par["kfrm"][Pkfcnt][22] )
				--setPedControlState ( par["ped"], "steer_back", par["kfrm"][Pkfcnt][23] )
				else -- driveby
					if (par["kfrm"][Pkfcnt][3]==true) then
						setPedDoingGangDriveby ( par["ped"], true )
						setPedAimTarget(par["ped"],par["kfrm"][Pkfcnt][4],par["kfrm"][Pkfcnt][5],par["kfrm"][Pkfcnt][6])
					elseif (par["kfrm"][Pkfcnt][3]==false) then
						setPedDoingGangDriveby ( par["ped"], false)
						end				
				end
			end
			tmpData[i]["kfrm"]["k"] = Pkfcnt
			end
		end
	end
	if (playend==true) then
		--killTimer(kplayer)
		kplayer = false
		isPlay = false
		if (isRec==false) then
			timerGo = false
			if (isSoundEnable) then
				local snd = playSound ( "client/sounds/stop.wav", false )
				setSoundVolume ( snd, 0.3)
				end
			end
		--outputChatBox ("Playback finished "..Pkfcnt.." frames")
		outputChatBox ("Playback finished")
		end
end

-- debug
--	dxDrawLine3D ( px1, py1, pz1, px2, py2, pz2, tocolor( 0, 255, 0, 230 ), 2)
--	if (isPlay == false) then
--for i, par in pairs(trace) do
--	dxDrawLine3D ( par[1], par[2], par[3], par[1], par[2], par[3]+0.1,  par[4], 2)
--	end
--	end
	if (timerShow==true) then
		if (timerGo==true) then
			timerValue = getTickCount()-timerStart
			end
		local col=""
		if (isRec==true) then
			col=tocolor ( 240, 50, 50, 255 )
		elseif (isPlay==true) then
			col=tocolor ( 50, 240, 50, 255 )
		else
			col=tocolor ( 240, 240, 50, 255 )
			end
		dxDrawText( string.format("%.2f",timerValue/1000), screenWidth-85, screenHeight-41, screenWidth, screenHeight, col, 0.7, "bankgothic" )
		dxDrawImage (screenWidth-110, screenHeight-90, 90, 45, "client/logo.png") 
		if (isShowKFR) then
			if (totalkf<8000) then
				col = tocolor ( 40, 255, 40, 70 )
			elseif (totalkf<15000) then
				col = tocolor ( 240, 240, 50, 170 )
			else
				col = tocolor ( 240, 40, 40, 255 )
			end
			dxDrawText( "KF: "..tostring(totalkf), screenWidth-84, screenHeight-24, screenWidth, screenHeight, col, 0.4, "bankgothic" )
			end
		-- debug
		--dxDrawText( tostring(abz1), screenWidth-185, screenHeight-101, screenWidth, screenHeight, col, 0.7, "bankgothic" )
		
		end
end
addEventHandler( "onClientRender", getRootElement(), Render)

function freecamMouse (rposX, rposY, aposX, aposY)
 if (isCursorShowing()==false)and(isMainMenuActive()==false)and(isMTAWindowActive()==false) then
    --local width, height = guiGetScreenSize()
	if (camMode==cmSpect) then
		rotA = rotA - (rposX-0.5)*sensRX
		rotB = rotB + (rposY-0.5)*sensRY
		if (rotA>math.pi*2) then
			rotA = rotA - math.pi*2
		elseif 	(rotA<0) then
			rotA = rotA + math.pi*2
			end
		if (rotB>math.pi-0.05) then
			rotB = math.pi-0.05
		elseif 	(rotB<0.05) then
			rotB = 0.05
			end
	elseif (camMode==cmDirector) then
		if (getKeyState("mouse1")==true) then
			dR2 = dR2 - (rposX-0.5)*sensRX
			dP2 = dP2 - (rposY-0.5)*sensRY
		else
			dR1 = dR1 - (rposX-0.5)*sensRX
			dP1 = dP1 + (rposY-0.5)*sensRY
		end
		end
	end
end
addEventHandler ("onClientCursorMove",getRootElement(), freecamMouse )

tmpobj = createObject ( 1253, 5540.6654, 1020.55122, 1240.545, 90, 0, 0 )
setElementCollisionsEnabled ( tmpobj, false )
tmpobj2 = createObject ( 1253, 5540.6654, 1020.55122, 1240.545, 90, 0, 0 )
setElementCollisionsEnabled ( tmpobj2, false )
-- set look ped at
function LookAt()
if (camMode==cmDefault) then
	local cx, cy, cz, ctx, cty, ctz = getCameraMatrix()
	setPedLookAt (getLocalPlayer(),ctx+50*(ctx-cx), cty+50*(cty-cy), ctz+50*(ctz-cz))
	--setElementPosition ( tmpobj,  ctx+4*(ctx-cx), cty+4*(cty-cy), ctz+4*(ctz-cz))
	--outputChatBox( "Press F5 to")
	end
end


function HK(k, ks)
if (isDirector==false) then
	if (camMode==cmDefault) then
	if (saveHK == true) then
		
		HotKeys[k] = {}
		local a, b = getPedAnimation( locPlr )
		local c = ""
		if (a ~=false) then
			outputChatBox( "Animation saved! Press '-' to reset player animation")
			HotKeys[k][1]= a
			HotKeys[k][2]= b
			HotKeys[k][3] = true -- loop animation
			c = "loop"
			if (getKeyState("lshift")==true) then
				-- single animation 
				HotKeys[k][3] = false
				c = "single"
				end
			outputChatBox(a.." "..b.."    "..c)
			else
			outputChatBox( "Рed is not doing an animation!")
			end
		saveHK = false
		else
		if (HotKeys[k]==nil) then
			outputChatBox( "Animation not speciefed! Press '=' to set hotkey ")
			else
			--outputChatBox( "Animation")
			if (HotKeys[k][1]==false) then
				outputChatBox( "No Animation!")
				end
			setPedAnimation(locPlr, HotKeys[k][1], HotKeys[k][2], -1, HotKeys[k][3])
			if (isRec==true) then -- add special event
				tmpSpecEvents[secnt] = {}
				tmpSpecEvents[secnt][1] = "an"
				tmpSpecEvents[secnt][2] = getTickCount() - startTime
				tmpSpecEvents[secnt][3] = HotKeys[k][1]
				tmpSpecEvents[secnt][4] = HotKeys[k][2]
				tmpSpecEvents[secnt][5] = HotKeys[k][3]
				secnt = secnt + 1
				end
			end
		end
	end
	else	
	if (k=="backspace") then
		camMode=cmSpect
		CC = ""
		else
		if (cam[k]==nil) then
			outputChatBox( "No camera speciefed for this key")
			else
			camMode = cmDirector
			CC = k
			end
		end
	
	end
end


function AnimSetHotkey()
if (camMode == cmDirector) then
	-- freeze camera
	if (cam[CC]~=nil) then
	cam[CC]["freeze"] = not cam[CC]["freeze"]
	
	if (cam[CC]["freeze"]==true) then
		outputChatBox("Camera Frozen")
		else
		outputChatBox("Camera Release")
		end
		else
		outputChatBox( "Director camera mode not selected")
		end
	else
	outputChatBox( "Press 0-9 key for save current animation!")
	saveHK = true
	end
end

function ResetAnimation()
if (camMode==cmDirector) then
	-- reset camera
	if (cam[CC]~=nil) then
		cam[CC]["p"] = cam[CC]["initp"]
		cam[CC]["t"] = cam[CC]["initt"]
		cam[CC]["rol"] = cam[CC]["initr"]
		cam[CC]["fov"] = cam[CC]["initf"]

		cam[CC]["px"] = cam[CC]["px0"]
		cam[CC]["py"] = cam[CC]["py0"]
		cam[CC]["pz"] = cam[CC]["pz0"]
		cam[CC]["tx"] = cam[CC]["tx0"]
		cam[CC]["ty"] = cam[CC]["ty0"]
		cam[CC]["tz"] = cam[CC]["tz0"]
		
		outputChatBox( "Camera reset")
		else
		outputChatBox( "Director camera mode not selected")
		end
	else
	setPedAnimation (locPlr)
	if (isRec==true) then -- add special event
		tmpSpecEvents[secnt] = {}
		tmpSpecEvents[secnt][1] = "ran"
		tmpSpecEvents[secnt][2] = getTickCount() - startTime
		secnt = secnt + 1
		end
	end
end

function ShowTimer()
	if (timerShow==true) then
	timerShow = false
	else
	timerShow = true
	end
	guiCheckBoxGetSelected(stimer, timerShow)
end

function ShowTimerGUI()
	timerShow = guiCheckBoxGetSelected(stimer)
end

function Director()
if(logged==true) then
if (isDirector==false) then
	isDirector = true
	guiSetText(scam, "Cam Menu")
	if (isHide==false) then
		lastx, lasty, lastz = getElementPosition(locPlr)
		isHide = true
		end
	campx, campy, campz, camtx, camty, camtz = getCameraMatrix()
	---setCameraMatrix (campx, campy, campz, camtx, camty, camtz)
	rotA = math.atan2(camty-campy,camtx-campx)
	rotB = math.atan2(math.sqrt(math.pow(camtx-campx,2)+math.pow(camty-campy,2)),camtz-campz)

	camMode=cmSpect
	outputChatBox( "Director mode on")
	outputChatBox( "Press F7 for camera menu")
	outputChatBox( "Press keys 2-0 for play camera")
	outputChatBox( "Press key P for play Rec")
	outputChatBox( "Press key '-' for reset current camera")
	outputChatBox( "Press key '=' for freeze current camera state")
	else
	isDirector = false
	guiSetText(scam, "Free Cam")
	if (isHide==true) then
		setElementPosition(locPlr, lastx, lasty, lastz)
		isHide = false
		end
	camMode=cmDefault
	setCameraTarget(locPlr)
	outputChatBox( "Actor mode on")
	end
	else
	outputChatBox( "You are not logged as director")
	end
end

function CamMenu(k)
--if (k=="F7")or(source==GUIEditor_Button[12])or(k=="nh") then
if (isDirector==true) then
	if (guiGetVisible(GUIEditor_Window[1])==false) then
		guiSetVisible(GUIEditor_Window[1], true)
		guiSetInputEnabled (true)
		showCursor(true)
		else
		guiSetVisible(GUIEditor_Window[1], false)
		guiSetInputEnabled (false)
		if (guiGetVisible(smenu)==false) then
			showCursor(false)
			end			
		end
	--end
	else
	outputChatBox( "Switch to director mode!")
	end
end

function moveUp(k)
	if (k=="mouse_wheel_up") then
	---dP2 = 0.001
	else
	--dP2 = -0.001
	end
end

function Kill()
if (isDirector==false) then
	if (isKill==false) then
		isKill=true
		if (guiGetVisible(smenu)==false) then
			showCursor(true)
			end
		outputChatBox( "Select Ped for remove")
		else
		isKill=false
		if (guiGetVisible(smenu)==false) then
			showCursor(false)
			end
		outputChatBox( "Disabled")
		end
	end
end

function ShowHelp(key, state)
if (state=="down") then
	guiSetVisible(GUIEditor_Window["help"], true)
	else
	guiSetVisible(GUIEditor_Window["help"], false)
	end
end

function ShowMainMenu()
if (guiGetVisible(smenu)==true) then
	guiSetVisible(smenu, false)
	showCursor(false)
	else
	guiSetVisible(smenu, true)
	showCursor(true)
	end

end

function LightOn()
	if (isRec==true)and(isPedInVehicle(locPlr)) then -- add special event
		local veh = getPedOccupiedVehicle (locPlr)
		local occ = getVehicleOccupant ( veh, 0 )
		if (occ==locPlr) then
			tmpSpecEvents[secnt] = {}
			tmpSpecEvents[secnt][1] = "lgh"
			tmpSpecEvents[secnt][2] = getTickCount() - startTime
			tmpSpecEvents[secnt][3] = getElementID(veh)
			local ls = getVehicleOverrideLights (veh)
				if (ls~=2) then
					tmpSpecEvents[secnt][4]=2
					else
					tmpSpecEvents[secnt][4]=1
					end
			setVehicleOverrideLights(veh, tmpSpecEvents[secnt][4])
			secnt = secnt + 1
			end
		end
end

function EmerLightOn(state)
	--outputChatBox(call ( getResourceFromName ( "emerlights" ), "isStroboLightsOn", getPedOccupiedVehicle (locPlr)))
	if (isRec==true)and(isPedInVehicle(locPlr)) then -- add special event
		local veh = getPedOccupiedVehicle (locPlr)
		local occ = getVehicleOccupant ( veh, 0 )
		if (occ==locPlr) then
			tmpSpecEvents[secnt] = {}
			tmpSpecEvents[secnt][1] = "elgh"
			tmpSpecEvents[secnt][2] = getTickCount() - startTime
			tmpSpecEvents[secnt][3] = getElementID(veh)

			--tmpSpecEvents[secnt][4]=call ( getResourceFromName ( "emerlights" ), "isStroboLightsOn", getPedOccupiedVehicle (locPlr))
			tmpSpecEvents[secnt][4] = state
			secnt = secnt + 1
			end
		end
		
end


function ResStart()
    outputChatBox( "Welcome to Stage resource!")
	outputChatBox( "Press F6 for switch actor/director mode")
	outputChatBox( "Press O to start/stop record and play. L - just rec")
	outputChatBox( "Press P to play record. F3 - show/hide timer")
	outputChatBox( "Press F2 to Main Menu.")
	outputChatBox( "Press I to reset scene. F4 - show/hide HUD")
	outputChatBox( "Press F5 to spectator camera mode.")

	--bindKey ( "l", "down", Rec )   --
--	bindKey ( "l", "down", LightOn )
	
	addCommandHandler("Vehicle Light On", LightOn)
	bindKey("l", "down", "Vehicle Light On")
	
	addEventHandler("onPlayerEmergencyLightStateChange", getRootElement(), EmerLightOn)
	
	--bindKey ( "o", "down", RecPlay )
	
	addCommandHandler("Begin Rec", RecPlay)
	bindKey("o", "down", "Begin Rec")
	
	--bindKey ( "p", "down", Play )
	
	addCommandHandler("Begin Play", Play)
	bindKey("p", "down", "Begin Play")
	
	--bindKey ( "i", "down", Reset )
	
	addCommandHandler("Reset Scene", Reset)
	bindKey("i", "down", "Reset Scene")	
	
	--bindKey ( "K", "down", Kill )
	
	addCommandHandler("Remove Ped", Kill)
	bindKey("k", "down", "Remove Ped")		
	
	bindKey ( "=", "down", AnimSetHotkey )
	bindKey ( "-", "down", ResetAnimation )
	--bindKey ( "m", "down", SelectMapDialog )
	--bindKey ( "F4", "down", ShowHUD )
	
	addCommandHandler("Show/Hide HUD", ShowHUD)
	bindKey("F4", "down", "Show/Hide HUD")
	
--	bindKey ( "F2", "down", ShowMainMenu )
	addCommandHandler("Show Stage Menu", ShowMainMenu)
	bindKey("F2", "down", "Show Stage Menu")
	
	--bindKey ( "F5", "down", FreeCam )
	addCommandHandler("Free Cam Mode", FreeCam)
	bindKey("F5", "down", "Free Cam Mode")	
	--bindKey ( "F6", "down", FreeCam2 )
	--bindKey ( "F3", "down", ShowTimer )
	
	addCommandHandler("Show/Hide Timer", FreeCam)
	bindKey("F3", "down", "Show/Hide Timer")
	
	--bindKey ( "F7", "down", CamMenu )
	addCommandHandler("Show Camera Menu", CamMenu)
	bindKey("F7", "down", "Show Camera Menu")
	
	--bindKey ( "F6", "down", Director )
	addCommandHandler("Switch Director/Actor Mode", Director)
	bindKey("F6", "down", "Switch Director/Actor Mode")
	
	bindKey ( "0", "down", HK)
	--bindKey ( "l", "down", HK)
	bindKey ( "2", "down", HK)
	bindKey ( "3", "down", HK)
	bindKey ( "4", "down", HK)
	bindKey ( "5", "down", HK)
	bindKey ( "6", "down", HK)
	bindKey ( "7", "down", HK)
	bindKey ( "8", "down", HK)
	bindKey ( "9", "down", HK)

	--bindKey ( "mouse_wheel_up", "both", moveUp)
	--bindKey ( "mouse_wheel_down", "both", moveUp)
	
	setMinuteDuration ( 60000 )
		
	--bindKey ( "9", "down", HK)
	--bindKey ( "9", "down", HK)
	--bindKey ( "F1", "up", funcInput )     -- bind the player's F1 up key
	--bindKey ( "fire", "both", funcInput ) -- bind the player's fire down and up control
    ---textLabel = guiCreateLabel( 0, .9, 1, .1, "", true );
    --guiLabelSetHorizontalAlign( textLabel, "center" );	
end

ResStart()

function PlayerInVeh(vehicle, seat)
if (source==getLocalPlayer()) then
	lastCar = getElementID(vehicle)
	lastSeat = seat
	--outputChatBox ( "veh2 "..lastCar)
	-- special event
	if (isRec==true) then
		tmpSpecEvents[secnt] = {}
		tmpSpecEvents[secnt][1] = "veh"
		tmpSpecEvents[secnt][2] = getTickCount() - startTime
		tmpSpecEvents[secnt][3] = lastCar
		tmpSpecEvents[secnt][4] = lastSeat
		secnt = secnt + 1
		end
	end
end
addEventHandler ( "onClientPlayerVehicleEnter", getRootElement(), PlayerInVeh)

function PlayerExitVeh(vehicle, seat)
--outputChatBox ( "veh exit ")
if (source==getLocalPlayer()) then
	-- special event
	if (isRec==true) then
		tmpSpecEvents[secnt] = {}
		tmpSpecEvents[secnt][1] = "vehe"
		tmpSpecEvents[secnt][2] = getTickCount() - startTime
		local x,y,z = getElementPosition(locPlr)
		tmpSpecEvents[secnt][3] = x
		tmpSpecEvents[secnt][4] = y
		tmpSpecEvents[secnt][5] = z
		--tmpSpecEvents[secnt][6] = getElement
		secnt = secnt + 1
		end
	end
end
addEventHandler ( "onClientPlayerVehicleExit", getRootElement(), PlayerExitVeh)


function onWeapSwitch ( prevSlot, newSlot )
if (source==getLocalPlayer()) then
	-- special event
	tmpSpecEvents[secnt] = {}
	tmpSpecEvents[secnt][1] = "we"
	tmpSpecEvents[secnt][2] = getTickCount() - startTime
	tmpSpecEvents[secnt][3] = newSlot
	secnt = secnt + 1
	end
end
addEventHandler ( "onClientPlayerWeaponSwitch", getRootElement(), onWeapSwitch )

--function fireAtMe(ped)
--setPedControlState(ped, "fire", true)
--setPedAimTarget ( ped, getElementPosition(locPlr) )
--setPedControlState(ped, "aim_weapon", true)
--end
--addEvent( "FireAtMe", true )
--addEventHandler( "FireAtMe", getRootElement(), fireAtMe)


function InitAsCurrent()
if (source==GUIEditor_Button[2]) then
	local px,py,pz,ptx,pty,ptz = getCameraMatrix()
		guiSetText(GUIEditor_Edit[2],"")
		guiSetText(GUIEditor_Edit[5],"")
		guiSetText(GUIEditor_Edit[2],string.format("%.4f", px))
		guiSetText(GUIEditor_Edit[3],string.format("%.4f", py))
		guiSetText(GUIEditor_Edit[4],string.format("%.4f", pz))
		guiSetText(GUIEditor_Edit[6],string.format("%.4f", ptx))
		guiSetText(GUIEditor_Edit[7],string.format("%.4f", pty))
		guiSetText(GUIEditor_Edit[8],string.format("%.4f", ptz))
		
		guiRadioButtonSetSelected (GUIEditor_Radio[2], true)
		guiRadioButtonSetSelected (GUIEditor_Radio[4], true)
	--outputChatBox ( "cam")
	end
end

function OnClick ( button, state, absoluteX, absoluteY, worldX, worldY, worldZ, clickedElement )
        --if an element was clicked on screen
        if (isElemSelect==true)and(clickedElement~=false) then
			guiSetText(ElemEdit, getElementID(clickedElement))
			isElemSelect = false
		elseif (isKill==true)and(clickedElement~=false) then
			if (getElementType(clickedElement)=="ped") then
				--outputChatBox ("Ped Removed")
				if (guiGetVisible(smenu)==false) then	
					showCursor(false)
					end
				isKill=false
				triggerServerEvent("onClientWantKill", getLocalPlayer(), getElementID(clickedElement))
				else
				if (getElementType(clickedElement)~="gui-button") then
					outputChatBox ("Element is not a ped!")
					if (guiGetVisible(smenu)==false) then	
						showCursor(false)
						end
					isKill=false
					end
				end

			end
		--
end
addEventHandler ( "onClientClick", getRootElement(), OnClick )

function StartObjSelection()
isElemSelect = true
if (source==GUIEditor_Button[1]) then
	ElemEdit = GUIEditor_Edit[1]
	else
	ElemEdit = GUIEditor_Edit[5]
	end
end

function CamTestStart()
if (source==GUIEditor_Button[13]) then
	CC = "test"
	
	SaveCamToKey(CC)
	
	guiSetVisible(GUIEditor_Window[1], false)
	guiSetInputEnabled (false)
	showCursor(false)
	cTime = getTickCount()
	camMode = cmDirector
	--outputChatBox ( "cam")
	end
end

function SaveCamToKey(id)
	cam[id] = {}
	cam[id]["freeze"] = false
	cam[id]["p"] = {}
	cam[id]["t"] = {}
	cam[id]["p1"] = {}
	cam[id]["t1"] = {}
	cam[id]["p"][0]=guiRadioButtonGetSelected(GUIEditor_Radio[1])
	cam[id]["p"]["objID"] = guiGetText(GUIEditor_Edit[1])
	if (cam[id]["p"]["objID"]=="") then
		cam[id]["p"]["obj"] = false
		else
		if (cam[id]["p"][0]==true) then
			cam[id]["p"]["obj"] = getElementByID(cam[id]["p"]["objID"])
			else
			cam[id]["p"]["obj"] = false
			end
		end	
	cam[id]["t"][0]=guiRadioButtonGetSelected(GUIEditor_Radio[3])
	cam[id]["t"]["objID"] = guiGetText(GUIEditor_Edit[5])
	if (cam[id]["t"]["objID"]=="") then
		cam[id]["t"]["obj"] = false
		else
		if (cam[id]["t"][0]==true) then
			cam[id]["t"]["obj"] = getElementByID(cam[id]["t"]["objID"])
			else
			cam[id]["t"]["obj"] = false
			end
		end	
	if (guiRadioButtonGetSelected(GUIEditor_Radio[5])==true) then
		cam[id]["pm"] = pmRotation
		cam[id]["p"]["objID"] = cam[id]["t"]["objID"]
		cam[id]["p"]["obj"] = cam[id]["t"]["obj"]
	elseif (guiRadioButtonGetSelected(GUIEditor_Radio[6])==true) then
		cam[id]["pm"] = pmToPoint
	elseif (guiRadioButtonGetSelected(GUIEditor_Radio[8])==true) then
		cam[id]["pm"] = pmFree
		cam[id]["p"]["objID"] = cam[id]["t"]["objID"]
		cam[id]["p"]["obj"] = cam[id]["t"]["obj"]
	else
		cam[id]["pm"] = pmStatic
		end
		
	if (guiRadioButtonGetSelected(GUIEditor_Radio[9])==true) then
		cam[id]["tm"] = pmRotation
		cam[id]["t"]["objID"] = cam[id]["p"]["objID"]
		cam[id]["t"]["obj"] = cam[id]["p"]["obj"]		
	elseif (guiRadioButtonGetSelected(GUIEditor_Radio[10])==true) then
		cam[id]["tm"] = pmToPoint
	elseif (guiRadioButtonGetSelected(GUIEditor_Radio[12])==true) then
		cam[id]["tm"] = pmFree
		cam[id]["t"]["objID"] = cam[id]["p"]["objID"]
		cam[id]["t"]["obj"] = cam[id]["p"]["obj"]	
	else
		cam[id]["tm"] = pmStatic
		end		
	
	cam[id]["p"][1]=tonumber(guiGetText(GUIEditor_Edit[2]))
	cam[id]["p"][2]=tonumber(guiGetText(GUIEditor_Edit[3]))
	cam[id]["p"][3]=tonumber(guiGetText(GUIEditor_Edit[4]))

	if (cam[id]["p"]["obj"]~=false) then	
		local matrix =  getElementMatrix (cam[id]["p"]["obj"])
		local ctx,cty,ctz = 0
		ctx = cam[id]["p"][1] * matrix[1][1] + cam[id]["p"][2] * matrix[2][1] + cam[id]["p"][3] * matrix[3][1] + matrix[4][1]
		cty = cam[id]["p"][1] * matrix[1][2] + cam[id]["p"][2] * matrix[2][2] + cam[id]["p"][3] * matrix[3][2] + matrix[4][2]
		ctz = cam[id]["p"][1] * matrix[1][3] + cam[id]["p"][2] * matrix[2][3] + cam[id]["p"][3] * matrix[3][3] + matrix[4][3]		
		
		cam[id]["p1"][1] = ctx
		cam[id]["p1"][2] = cty
		cam[id]["p1"][3] = ctz
		else
		cam[id]["p1"][1] = cam[id]["p"][1]
		cam[id]["p1"][2] = cam[id]["p"][2]
		cam[id]["p1"][3] = cam[id]["p"][3]		
		end

	cam[id]["t"][1]=tonumber(guiGetText(GUIEditor_Edit[6]))
	cam[id]["t"][2]=tonumber(guiGetText(GUIEditor_Edit[7]))
	cam[id]["t"][3]=tonumber(guiGetText(GUIEditor_Edit[8]))

	if (cam[id]["t"]["obj"]~=false) then	
		local matrix =  getElementMatrix (cam[id]["t"]["obj"])
		local ctx,cty,ctz = 0
		ctx = cam[id]["t"][1] * matrix[1][1] + cam[id]["t"][2] * matrix[2][1] + cam[id]["t"][3] * matrix[3][1] + matrix[4][1]
		cty = cam[id]["t"][1] * matrix[1][2] + cam[id]["t"][2] * matrix[2][2] + cam[id]["t"][3] * matrix[3][2] + matrix[4][2]
		ctz = cam[id]["t"][1] * matrix[1][3] + cam[id]["t"][2] * matrix[2][3] + cam[id]["t"][3] * matrix[3][3] + matrix[4][3]		
		
		cam[id]["t1"][1] = ctx
		cam[id]["t1"][2] = cty
		cam[id]["t1"][3] = ctz
		else
		cam[id]["t1"][1] = cam[id]["t"][1]
		cam[id]["t1"][2] = cam[id]["t"][2]
		cam[id]["t1"][3] = cam[id]["t"][3]		
		end	
	
	--cam[id]["t"]["obj"] = getElementByID("vehicle (Oceanic) (1)")--cam[id]["t"]["objID"])
	--cam[id]["p"]["obj"] = cam[id]["t"]["obj"]
	
	cam[id]["px"] = cam[id]["p"][1]
	cam[id]["py"] = cam[id]["p"][2]
	cam[id]["pz"] = cam[id]["p"][3]
	
	cam[id]["tx"] = cam[id]["t"][1]
	cam[id]["ty"] = cam[id]["t"][2]
	cam[id]["tz"] = cam[id]["t"][3]
	
	cam[id]["l"] = math.sqrt(math.pow(cam[id]["t1"][1]-cam[id]["p1"][1],2)+math.pow(cam[id]["t1"][2]-cam[id]["p1"][2],2)+math.pow(cam[id]["t1"][3]-cam[id]["p1"][3],2))
	cam[id]["la"] = tonumber(guiGetText(GUIEditor_Edit[55]))
	cam[id]["ld"] = tonumber(guiGetText(GUIEditor_Edit[56]))
	cam[id]["ls"] = 0
	cam[id]["lmaxs"] = tonumber(guiGetText(GUIEditor_Edit[57]))
	cam[id]["lmins"] = tonumber(guiGetText(GUIEditor_Edit[58]))
		
	
	cam[id]["t"]["rot"] = math.atan2(cam[id]["t1"][2]-cam[id]["p1"][2],cam[id]["t1"][1]-cam[id]["p1"][1])
	cam[id]["t"]["pit"] = math.atan2(cam[id]["l"],cam[id]["t1"][3]-cam[id]["p1"][3])
	cam[id]["p"]["rot"] = math.atan2(cam[id]["p1"][2]-cam[id]["t1"][2],cam[id]["p1"][1]-cam[id]["t1"][1])
	cam[id]["p"]["pit"] = math.atan2(cam[id]["l"],cam[id]["p1"][3]-cam[id]["t1"][3])
	
	cam[id]["p"]["s"] = 0 -- speed
	cam[id]["p"]["st"] = 0 -- strafe speed
	cam[id]["p"]["sa"] = tonumber(guiGetText(GUIEditor_Edit[42])) -- acceleration
	cam[id]["p"]["sd"] = tonumber(guiGetText(GUIEditor_Edit[43])) -- deceleration
	cam[id]["p"]["smax"] = tonumber(guiGetText(GUIEditor_Edit[44]))
	cam[id]["p"]["smin"] = tonumber(guiGetText(GUIEditor_Edit[45]))
	cam[id]["p"]["sta"] = tonumber(guiGetText(GUIEditor_Edit[38]))
	cam[id]["p"]["std"] = tonumber(guiGetText(GUIEditor_Edit[39]))
	cam[id]["p"]["stmax"] = tonumber(guiGetText(GUIEditor_Edit[40]))
	cam[id]["p"]["stmin"] = tonumber(guiGetText(GUIEditor_Edit[41]))
		
	--outputChatBox(cam[id]["t"]["rot"].." "..cam[id]["p"]["rot"])
	
	cam[id]["t"]["rotms"] = 0
	cam[id]["t"]["rotmaxs"] = tonumber(guiGetText(GUIEditor_Edit[98]))
	cam[id]["t"]["rotmins"] = tonumber(guiGetText(GUIEditor_Edit[99]))
	cam[id]["t"]["rotma"] = tonumber(guiGetText(GUIEditor_Edit[96]))
	cam[id]["t"]["rotmd"] = tonumber(guiGetText(GUIEditor_Edit[97]))

	cam[id]["t"]["pitms"] = 0
	cam[id]["t"]["pitmaxs"] = tonumber(guiGetText(GUIEditor_Edit[102]))
	cam[id]["t"]["pitmins"] = tonumber(guiGetText(GUIEditor_Edit[103]))
	cam[id]["t"]["pitma"] = tonumber(guiGetText(GUIEditor_Edit[100]))
	cam[id]["t"]["pitmd"] = tonumber(guiGetText(GUIEditor_Edit[101]))
	-- rotation mouse params
	cam[id]["p"]["rotms"] = 0
	cam[id]["p"]["rotmaxs"] = tonumber(guiGetText(GUIEditor_Edit[48]))
	cam[id]["p"]["rotmins"] = tonumber(guiGetText(GUIEditor_Edit[49]))
	cam[id]["p"]["rotma"] = tonumber(guiGetText(GUIEditor_Edit[46]))
	cam[id]["p"]["rotmd"] = tonumber(guiGetText(GUIEditor_Edit[47]))
	
		
	cam[id]["p"]["pitms"] = 0
	cam[id]["p"]["pitmaxs"] = tonumber(guiGetText(GUIEditor_Edit[52]))
	cam[id]["p"]["pitmins"] = tonumber(guiGetText(GUIEditor_Edit[53]))
	cam[id]["p"]["pitma"] = tonumber(guiGetText(GUIEditor_Edit[50]))
	cam[id]["p"]["pitmd"] = tonumber(guiGetText(GUIEditor_Edit[51]))
	
	-- rotation
	cam[id]["p"]["rotst"] = tonumber(guiGetText(GUIEditor_Edit[17]))*math.pi/180
	cam[id]["p"]["rotlen"] = math.abs(tonumber(guiGetText(GUIEditor_Edit[18])))*math.pi/180
	cam[id]["p"]["rotcur"] = 0
	cam[id]["p"]["rotc"] = sign(tonumber(guiGetText(GUIEditor_Edit[18])))
	cam[id]["p"]["rots"] = tonumber(guiGetText(GUIEditor_Edit[21]))
	cam[id]["p"]["rotta"] = tonumber(guiGetText(GUIEditor_Edit[19]))
	cam[id]["p"]["rottd"] = tonumber(guiGetText(GUIEditor_Edit[20]))
	cam[id]["p"]["rottmaxs"] = tonumber(guiGetText(GUIEditor_Edit[22]))
	cam[id]["p"]["rottmins"] = tonumber(guiGetText(GUIEditor_Edit[23]))
		-- and pitch
	cam[id]["p"]["pitst"] = tonumber(guiGetText(GUIEditor_Edit[24]))*math.pi/180
	cam[id]["p"]["pitlen"] = math.abs(tonumber(guiGetText(GUIEditor_Edit[25])))*math.pi/180
	cam[id]["p"]["pitcur"] = 0
	cam[id]["p"]["pitc"] = sign(tonumber(guiGetText(GUIEditor_Edit[25])))
	cam[id]["p"]["pits"] = tonumber(guiGetText(GUIEditor_Edit[28]))
	cam[id]["p"]["pitta"] = tonumber(guiGetText(GUIEditor_Edit[26]))
	cam[id]["p"]["pittd"] = tonumber(guiGetText(GUIEditor_Edit[27]))
	cam[id]["p"]["pittmaxs"] = tonumber(guiGetText(GUIEditor_Edit[29]))
	cam[id]["p"]["pittmins"] = tonumber(guiGetText(GUIEditor_Edit[30]))
		-- and distance
	cam[id]["p"]["disst"] = tonumber(guiGetText(GUIEditor_Edit[31]))
	cam[id]["p"]["dislen"] = math.abs(tonumber(guiGetText(GUIEditor_Edit[32])))
	cam[id]["p"]["discur"] = 0
	cam[id]["p"]["disc"] = sign(tonumber(guiGetText(GUIEditor_Edit[32])))
	cam[id]["p"]["diss"] = tonumber(guiGetText(GUIEditor_Edit[35]))
	cam[id]["p"]["dista"] = tonumber(guiGetText(GUIEditor_Edit[33]))
	cam[id]["p"]["distd"] = tonumber(guiGetText(GUIEditor_Edit[34]))
	cam[id]["p"]["distmaxs"] = tonumber(guiGetText(GUIEditor_Edit[36]))
	cam[id]["p"]["distmins"] = tonumber(guiGetText(GUIEditor_Edit[37]))
	-- rotation
	cam[id]["t"]["rotst"] = tonumber(guiGetText(GUIEditor_Edit[67]))*math.pi/180
	cam[id]["t"]["rotlen"] = math.abs(tonumber(guiGetText(GUIEditor_Edit[68])))*math.pi/180
	cam[id]["t"]["rotcur"] = 0
	cam[id]["t"]["rotc"] = sign(tonumber(guiGetText(GUIEditor_Edit[68])))
	cam[id]["t"]["rots"] = tonumber(guiGetText(GUIEditor_Edit[71]))
	cam[id]["t"]["rotta"] = tonumber(guiGetText(GUIEditor_Edit[69]))
	cam[id]["t"]["rottd"] = tonumber(guiGetText(GUIEditor_Edit[70]))
	cam[id]["t"]["rottmaxs"] = tonumber(guiGetText(GUIEditor_Edit[72]))
	cam[id]["t"]["rottmins"] = tonumber(guiGetText(GUIEditor_Edit[73]))
		-- and pitch
	cam[id]["t"]["pitst"] = tonumber(guiGetText(GUIEditor_Edit[74]))*math.pi/180
	cam[id]["t"]["pitlen"] = math.abs(tonumber(guiGetText(GUIEditor_Edit[75])))*math.pi/180
	cam[id]["t"]["pitcur"] = 0
	cam[id]["t"]["pitc"] = sign(tonumber(guiGetText(GUIEditor_Edit[75])))
	cam[id]["t"]["pits"] = tonumber(guiGetText(GUIEditor_Edit[78]))
	cam[id]["t"]["pitta"] = tonumber(guiGetText(GUIEditor_Edit[76]))
	cam[id]["t"]["pittd"] = tonumber(guiGetText(GUIEditor_Edit[77]))
	cam[id]["t"]["pittmaxs"] = tonumber(guiGetText(GUIEditor_Edit[79]))
	cam[id]["t"]["pittmins"] = tonumber(guiGetText(GUIEditor_Edit[80]))
		-- and distance
	cam[id]["t"]["disst"] = tonumber(guiGetText(GUIEditor_Edit[81]))
	cam[id]["t"]["dislen"] = math.abs(tonumber(guiGetText(GUIEditor_Edit[82])))
	cam[id]["t"]["discur"] = 0
	cam[id]["t"]["disc"] = sign(tonumber(guiGetText(GUIEditor_Edit[82])))
	cam[id]["t"]["diss"] = tonumber(guiGetText(GUIEditor_Edit[85]))
	cam[id]["t"]["dista"] = tonumber(guiGetText(GUIEditor_Edit[83]))
	cam[id]["t"]["distd"] = tonumber(guiGetText(GUIEditor_Edit[84]))
	cam[id]["t"]["distmaxs"] = tonumber(guiGetText(GUIEditor_Edit[86]))
	cam[id]["t"]["distmins"] = tonumber(guiGetText(GUIEditor_Edit[87]))
	
	-- movement to point/manual speed
	-- start pos
	cam[id]["p"]["spx"] = tonumber(guiGetText(GUIEditor_Edit[2]))
	cam[id]["p"]["spy"] = tonumber(guiGetText(GUIEditor_Edit[3]))
	cam[id]["p"]["spz"] = tonumber(guiGetText(GUIEditor_Edit[4]))
	-- end pos
	cam[id]["p"]["epx"] = tonumber(guiGetText(GUIEditor_Edit[9]))
	cam[id]["p"]["epy"] = tonumber(guiGetText(GUIEditor_Edit[10]))
	cam[id]["p"]["epz"] = tonumber(guiGetText(GUIEditor_Edit[11]))
	-- speed vector
	cam[id]["p"]["stx"] = (cam[id]["p"]["epx"]-cam[id]["p"]["spx"])/1000
	cam[id]["p"]["sty"] = (cam[id]["p"]["epy"]-cam[id]["p"]["spy"])/1000
	cam[id]["p"]["stz"] = (cam[id]["p"]["epz"]-cam[id]["p"]["spz"])/1000	
	-- start speed
	cam[id]["p"]["ssp"] = tonumber(guiGetText(GUIEditor_Edit[12]))
	cam[id]["p"]["smaxs"] = tonumber(guiGetText(GUIEditor_Edit[15]))
	cam[id]["p"]["smins"] = tonumber(guiGetText(GUIEditor_Edit[16]))
	-- distance to stop
	--cam[id]["p"]["len"] = 0
	cam[id]["p"]["mlen"] = math.sqrt(math.pow(cam[id]["p"]["spx"]-cam[id]["p"]["epx"],2)+math.pow(cam[id]["p"]["epy"]-cam[id]["p"]["spy"],2)+math.pow(cam[id]["p"]["epx"]-cam[id]["p"]["spx"],2))
	-- acc
	cam[id]["p"]["sax"] = tonumber(guiGetText(GUIEditor_Edit[13]))
	-- dec
	cam[id]["p"]["sdx"] = tonumber(guiGetText(GUIEditor_Edit[14]))
	
	-- movement to point/manual speed target
	-- start pos
	cam[id]["t"]["spx"] = tonumber(guiGetText(GUIEditor_Edit[6]))
	cam[id]["t"]["spy"] = tonumber(guiGetText(GUIEditor_Edit[7]))
	cam[id]["t"]["spz"] = tonumber(guiGetText(GUIEditor_Edit[8]))
	-- end pos
	cam[id]["t"]["epx"] = tonumber(guiGetText(GUIEditor_Edit[59]))
	cam[id]["t"]["epy"] = tonumber(guiGetText(GUIEditor_Edit[60]))
	cam[id]["t"]["epz"] = tonumber(guiGetText(GUIEditor_Edit[61]))
	-- speed vector
	cam[id]["t"]["stx"] = (cam[id]["t"]["epx"]-cam[id]["t"]["spx"])/1000
	cam[id]["t"]["sty"] = (cam[id]["t"]["epy"]-cam[id]["t"]["spy"])/1000
	cam[id]["t"]["stz"] = (cam[id]["t"]["epz"]-cam[id]["t"]["spz"])/1000	
	-- start speed
	cam[id]["t"]["ssp"] = tonumber(guiGetText(GUIEditor_Edit[62]))
	cam[id]["t"]["smaxs"] = tonumber(guiGetText(GUIEditor_Edit[65]))
	cam[id]["t"]["smins"] = tonumber(guiGetText(GUIEditor_Edit[66]))
	-- distance to stop
	--cam[id]["t"]["len"] = 0
	cam[id]["t"]["mlen"] = math.sqrt(math.pow(cam[id]["t"]["spx"]-cam[id]["t"]["epx"],2)+math.pow(cam[id]["t"]["epy"]-cam[id]["t"]["spy"],2)+math.pow(cam[id]["t"]["epx"]-cam[id]["t"]["spx"],2))
	-- acc
	cam[id]["t"]["sax"] = tonumber(guiGetText(GUIEditor_Edit[63]))
	-- dec
	cam[id]["t"]["sdx"] = tonumber(guiGetText(GUIEditor_Edit[64]))	
	
	
	-- init position
	if (cam[id]["pm"]==pmToPoint) then
		cam[id]["px"] = cam[id]["p"]["spx"]
		cam[id]["py"] = cam[id]["p"]["spy"]
		cam[id]["pz"] = cam[id]["p"]["spz"]
		end
	if (cam[id]["tm"]==pmToPoint) then
		cam[id]["tx"] = cam[id]["t"]["spx"]
		cam[id]["ty"] = cam[id]["t"]["spy"]
		cam[id]["tz"] = cam[id]["t"]["spz"]
		end

	cam[id]["rol"] = {}
	cam[id]["rol"]["rol"] = tonumber(guiGetText(GUIEditor_Edit[105]))
	cam[id]["rol"]["rolms"] = tonumber(guiGetText(GUIEditor_Edit[107]))
	cam[id]["rol"]["rolcs"] = tonumber(guiGetText(GUIEditor_Edit[108]))
	cam[id]["rol"]["rolmaxs"] = tonumber(guiGetText(GUIEditor_Edit[119]))
	cam[id]["rol"]["rolmins"] = tonumber(guiGetText(GUIEditor_Edit[120]))
	cam[id]["rol"]["rolma"] = tonumber(guiGetText(GUIEditor_Edit[106]))
	cam[id]["rol"]["rolmd"] = tonumber(guiGetText(GUIEditor_Edit[118]))
	cam[id]["rol"]["rolmax"] = tonumber(guiGetText(GUIEditor_Edit[109]))
	cam[id]["rol"]["rolmin"] = tonumber(guiGetText(GUIEditor_Edit[110]))
	cam[id]["rol"]["rolunl"] = guiCheckBoxGetSelected(GUIEditor_Checkbox[1])
	
	if (guiCheckBoxGetSelected(GUIEditor_Checkbox[3])==true) then
		cam[id]["rm"] = pmFree
		else
		cam[id]["rm"] = pmStatic
		end

	cam[id]["fov"] = {}
	cam[id]["fov"]["fov"] = tonumber(guiGetText(GUIEditor_Edit[111]))
	cam[id]["fov"]["fovms"] = tonumber(guiGetText(GUIEditor_Edit[113]))
	cam[id]["fov"]["fovcs"] = tonumber(guiGetText(GUIEditor_Edit[117]))
	cam[id]["fov"]["fovmaxs"] = tonumber(guiGetText(GUIEditor_Edit[121]))
	cam[id]["fov"]["fovmins"] = tonumber(guiGetText(GUIEditor_Edit[122]))
	cam[id]["fov"]["fovma"] = tonumber(guiGetText(GUIEditor_Edit[112]))
	cam[id]["fov"]["fovmd"] = tonumber(guiGetText(GUIEditor_Edit[114]))
	cam[id]["fov"]["fovmax"] = tonumber(guiGetText(GUIEditor_Edit[115]))
	cam[id]["fov"]["fovmin"] = tonumber(guiGetText(GUIEditor_Edit[116]))

	if (guiCheckBoxGetSelected(GUIEditor_Checkbox[2])==true) then
		cam[id]["fm"] = pmFree
		else
		cam[id]["fm"] = pmStatic
		end
	
	cam[id]["initp"] = cam[id]["p"]
	cam[id]["initt"] = cam[id]["t"]
	cam[id]["initr"] = cam[id]["rol"]
	cam[id]["initf"] = cam[id]["fov"]
	cam[id]["px0"] = cam[id]["px"]
	cam[id]["py0"] = cam[id]["py"]
	cam[id]["pz0"] = cam[id]["pz"]
	cam[id]["tx0"] = cam[id]["tx"]
	cam[id]["ty0"] = cam[id]["ty"]
	cam[id]["tz0"] = cam[id]["tz"]
	--outputChatBox ( "cam saved to .. "..id)
	end

function LoadCamToMenu(id)

	if (cam[id]["initp"][0]== true) then
		guiRadioButtonSetSelected(GUIEditor_Radio[1], true)
		end
	guiSetText(GUIEditor_Edit[1],cam[id]["initp"]["objID"])	
	
	if (cam[id]["initt"][0]== true) then
		guiRadioButtonSetSelected(GUIEditor_Radio[3], true)
		end
	guiSetText(GUIEditor_Edit[5],cam[id]["initt"]["objID"])

		
	if (cam[id]["pm"] == pmRotation) then
	guiRadioButtonSetSelected(GUIEditor_Radio[5], true)
	elseif (cam[id]["pm"] == pmToPoint) then
		guiRadioButtonGetSelected(GUIEditor_Radio[6], true)
	elseif (cam[id]["pm"] == pmFree) then
	guiRadioButtonSetSelected(GUIEditor_Radio[8], true)
	else
		guiRadioButtonSetSelected(GUIEditor_Radio[7], true)
		end	
		
	if (cam[id]["tm"] == pmRotation) then
	guiRadioButtonSetSelected(GUIEditor_Radio[9], true)
	elseif (cam[id]["tm"] == pmToPoint) then
		guiRadioButtonGetSelected(GUIEditor_Radio[10], true)
	elseif (cam[id]["tm"] == pmFree) then
	guiRadioButtonSetSelected(GUIEditor_Radio[12], true)
	else
		guiRadioButtonSetSelected(GUIEditor_Radio[11], true)
		end		
	
	guiSetText(GUIEditor_Edit[2],cam[id]["initp"][1])
	guiSetText(GUIEditor_Edit[3],cam[id]["initp"][2])
	guiSetText(GUIEditor_Edit[4],cam[id]["initp"][3])
	guiSetText(GUIEditor_Edit[6],cam[id]["initt"][1])
	guiSetText(GUIEditor_Edit[7],cam[id]["initt"][2])
	guiSetText(GUIEditor_Edit[8],cam[id]["initt"][3])
	
	guiSetText(GUIEditor_Edit[55],cam[id]["la"])
	guiSetText(GUIEditor_Edit[56],cam[id]["ld"])
	guiSetText(GUIEditor_Edit[57],cam[id]["lmaxs"])
	guiSetText(GUIEditor_Edit[58],cam[id]["lmins"])

	guiSetText(GUIEditor_Edit[42],cam[id]["initp"]["sa"])
	guiSetText(GUIEditor_Edit[43],cam[id]["initp"]["sd"])
	guiSetText(GUIEditor_Edit[44],cam[id]["initp"]["smax"])
	guiSetText(GUIEditor_Edit[45],cam[id]["initp"]["smin"])
	guiSetText(GUIEditor_Edit[38],cam[id]["initp"]["sta"])
	guiSetText(GUIEditor_Edit[39],cam[id]["initp"]["std"])
	guiSetText(GUIEditor_Edit[40],cam[id]["initp"]["stmax"])
	guiSetText(GUIEditor_Edit[41],cam[id]["initp"]["stmin"])
		
	--outputChatBox(cam[id]["initt"]["rot"].." "..cam[id]["initp"]["rot"])
	guiSetText(GUIEditor_Edit[98],cam[id]["initt"]["rotmaxs"])
	guiSetText(GUIEditor_Edit[99],cam[id]["initt"]["rotmins"])
	guiSetText(GUIEditor_Edit[96],cam[id]["initt"]["rotma"])
	guiSetText(GUIEditor_Edit[97],cam[id]["initt"]["rotmd"])
	guiSetText(GUIEditor_Edit[102],cam[id]["initt"]["pitmaxs"])
	guiSetText(GUIEditor_Edit[103],cam[id]["initt"]["pitmins"])
	guiSetText(GUIEditor_Edit[100],cam[id]["initt"]["pitma"])
	guiSetText(GUIEditor_Edit[101],cam[id]["initt"]["pitmd"])


	guiSetText(GUIEditor_Edit[48],cam[id]["initp"]["rotmaxs"])
	guiSetText(GUIEditor_Edit[49],cam[id]["initp"]["rotmins"])
	guiSetText(GUIEditor_Edit[46],cam[id]["initp"]["rotma"])
	guiSetText(GUIEditor_Edit[47],cam[id]["initp"]["rotmd"])
	guiSetText(GUIEditor_Edit[52],cam[id]["initp"]["pitmaxs"])
	guiSetText(GUIEditor_Edit[53],cam[id]["initp"]["pitmins"])
	guiSetText(GUIEditor_Edit[50],cam[id]["initp"]["pitma"])	
	guiSetText(GUIEditor_Edit[51],cam[id]["initp"]["pitmd"])
	
	-- rotation
	guiSetText(GUIEditor_Edit[17],math.deg(cam[id]["initp"]["rotst"]))
	guiSetText(GUIEditor_Edit[18],math.deg(cam[id]["initp"]["rotlen"]*cam[id]["initp"]["rotc"]))
	guiSetText(GUIEditor_Edit[21],cam[id]["initp"]["rots"])
	guiSetText(GUIEditor_Edit[19],cam[id]["initp"]["rotta"])
	guiSetText(GUIEditor_Edit[20],cam[id]["initp"]["rottd"])
	guiSetText(GUIEditor_Edit[22],cam[id]["initp"]["rottmaxs"])
	guiSetText(GUIEditor_Edit[23],cam[id]["initp"]["rottmins"])
		-- and pitch
	guiSetText(GUIEditor_Edit[24],math.deg(cam[id]["initp"]["pitst"]))
	guiSetText(GUIEditor_Edit[25],math.deg(cam[id]["initp"]["pitlen"]*cam[id]["initp"]["pitc"]))
	guiSetText(GUIEditor_Edit[28],cam[id]["initp"]["pits"])
	guiSetText(GUIEditor_Edit[26],cam[id]["initp"]["pitta"])
	guiSetText(GUIEditor_Edit[27],cam[id]["initp"]["pittd"])
	guiSetText(GUIEditor_Edit[29],cam[id]["initp"]["pittmaxs"])
	guiSetText(GUIEditor_Edit[30],cam[id]["initp"]["pittmins"])

		-- and distance
	guiSetText(GUIEditor_Edit[31],cam[id]["initp"]["disst"])
	guiSetText(GUIEditor_Edit[32],cam[id]["initp"]["dislen"]*cam[id]["initp"]["disc"])
	guiSetText(GUIEditor_Edit[35],cam[id]["initp"]["diss"])
	guiSetText(GUIEditor_Edit[33],cam[id]["initp"]["dista"])
	guiSetText(GUIEditor_Edit[34],cam[id]["initp"]["distd"])
	guiSetText(GUIEditor_Edit[36],cam[id]["initp"]["distmaxs"])
	guiSetText(GUIEditor_Edit[37],cam[id]["initp"]["distmins"])
	-- rotation
	guiSetText(GUIEditor_Edit[67],math.deg(cam[id]["initt"]["rotst"]))
	guiSetText(GUIEditor_Edit[68],math.deg(cam[id]["initt"]["rotlen"]*cam[id]["initt"]["rotc"]))
	guiSetText(GUIEditor_Edit[71],cam[id]["initt"]["rots"])
	guiSetText(GUIEditor_Edit[69],cam[id]["initt"]["rotta"])
	guiSetText(GUIEditor_Edit[70],cam[id]["initt"]["rottd"])
	guiSetText(GUIEditor_Edit[72],cam[id]["initt"]["rottmaxs"])
	guiSetText(GUIEditor_Edit[73],cam[id]["initt"]["rottmins"])
		-- and pitch
	guiSetText(GUIEditor_Edit[74],math.deg(cam[id]["initt"]["pitst"]))
	guiSetText(GUIEditor_Edit[75],math.deg(cam[id]["initt"]["pitlen"]*cam[id]["initt"]["pitc"]))
	guiSetText(GUIEditor_Edit[78],cam[id]["initt"]["pits"])
	guiSetText(GUIEditor_Edit[76],cam[id]["initt"]["pitta"])
	guiSetText(GUIEditor_Edit[77],cam[id]["initt"]["pittd"])
	guiSetText(GUIEditor_Edit[79],cam[id]["initt"]["pittmaxs"])
	guiSetText(GUIEditor_Edit[80],cam[id]["initt"]["pittmins"])
		-- and distance
	guiSetText(GUIEditor_Edit[81],cam[id]["initt"]["disst"])
	guiSetText(GUIEditor_Edit[82],cam[id]["initt"]["dislen"]*cam[id]["initt"]["disc"])
	guiSetText(GUIEditor_Edit[85],cam[id]["initt"]["diss"])
	guiSetText(GUIEditor_Edit[83],cam[id]["initt"]["dista"])
	guiSetText(GUIEditor_Edit[84],cam[id]["initt"]["distd"])
	guiSetText(GUIEditor_Edit[86],cam[id]["initt"]["distmaxs"])
	guiSetText(GUIEditor_Edit[87],cam[id]["initt"]["distmins"])
	
	-- movement to point/manual speed
	-- start pos
	guiSetText(GUIEditor_Edit[2],cam[id]["initp"]["spx"])
	guiSetText(GUIEditor_Edit[3],cam[id]["initp"]["spy"])
	guiSetText(GUIEditor_Edit[4],cam[id]["initp"]["spz"])
	-- end pos
	guiSetText(GUIEditor_Edit[9],cam[id]["initp"]["epx"])
	guiSetText(GUIEditor_Edit[10],cam[id]["initp"]["epy"])
	guiSetText(GUIEditor_Edit[11],cam[id]["initp"]["epz"])
	-- start speed
	guiSetText(GUIEditor_Edit[12],cam[id]["initp"]["ssp"])
	guiSetText(GUIEditor_Edit[15],cam[id]["initp"]["smaxs"])
	guiSetText(GUIEditor_Edit[16],cam[id]["initp"]["smins"])
	-- acc
	guiSetText(GUIEditor_Edit[13],cam[id]["initp"]["sax"])
	-- dec
	guiSetText(GUIEditor_Edit[14],cam[id]["initp"]["sdx"])
	-- movement to point/manual speed target
	-- start pos
	guiSetText(GUIEditor_Edit[6],cam[id]["initt"]["spx"])
	guiSetText(GUIEditor_Edit[7],cam[id]["initt"]["spy"])
	guiSetText(GUIEditor_Edit[8],cam[id]["initt"]["spz"])
	-- end pos
	guiSetText(GUIEditor_Edit[59],cam[id]["initt"]["epx"])
	guiSetText(GUIEditor_Edit[60],cam[id]["initt"]["epy"])
	guiSetText(GUIEditor_Edit[61],cam[id]["initt"]["epz"])
	-- start speed
	guiSetText(GUIEditor_Edit[62],cam[id]["initt"]["ssp"])
	guiSetText(GUIEditor_Edit[65],cam[id]["initt"]["smaxs"])
	guiSetText(GUIEditor_Edit[66],cam[id]["initt"]["smins"])
	-- acc
	guiSetText(GUIEditor_Edit[63],cam[id]["initt"]["sax"])
	-- dec
	guiSetText(GUIEditor_Edit[64],cam[id]["initt"]["sdx"])



	guiSetText(GUIEditor_Edit[105],cam[id]["initr"]["initr"])
	guiSetText(GUIEditor_Edit[107],cam[id]["initr"]["rolms"])
	guiSetText(GUIEditor_Edit[108],cam[id]["initr"]["rolcs"])
	guiSetText(GUIEditor_Edit[119],cam[id]["initr"]["rolmaxs"])
	guiSetText(GUIEditor_Edit[120],cam[id]["initr"]["rolmins"])
	guiSetText(GUIEditor_Edit[106],cam[id]["initr"]["rolma"])
	guiSetText(GUIEditor_Edit[118],cam[id]["initr"]["rolmd"])
	guiSetText(GUIEditor_Edit[109],cam[id]["initr"]["rolmax"])
	guiSetText(GUIEditor_Edit[110],cam[id]["initr"]["rolmin"])
	guiCheckBoxSetSelected(GUIEditor_Checkbox[1],cam[id]["initr"]["rolunl"])
	
	if (cam[id]["rm"]== pmFree) then
		guiCheckBoxGetSelected(GUIEditor_Checkbox[3], true)
		else
		guiCheckBoxGetSelected(GUIEditor_Checkbox[3], false)
		end
	if (cam[id]["fm"]== pmFree) then
		guiCheckBoxGetSelected(GUIEditor_Checkbox[2], true)
		else
		guiCheckBoxGetSelected(GUIEditor_Checkbox[2], false)
		end
	guiSetText(GUIEditor_Edit[111],cam[id]["initf"]["initf"])
	guiSetText(GUIEditor_Edit[113],cam[id]["initf"]["fovms"])
	guiSetText(GUIEditor_Edit[117],cam[id]["initf"]["fovcs"])
	guiSetText(GUIEditor_Edit[121],cam[id]["initf"]["fovmaxs"])
	guiSetText(GUIEditor_Edit[122],cam[id]["initf"]["fovmins"])
	guiSetText(GUIEditor_Edit[112],cam[id]["initf"]["fovma"])
	guiSetText(GUIEditor_Edit[114],cam[id]["initf"]["fovmd"])
	guiSetText(GUIEditor_Edit[115],cam[id]["initf"]["fovmax"])
	guiSetText(GUIEditor_Edit[116],cam[id]["initf"]["fovmin"])

end

function SaveCam(key)
if (source==GUIEditor_Button[11]) then
	local id = guiGetText(GUIEditor_Edit[123])
	SaveCamToKey(id)
	outputChatBox ("Camera Preset Saved to "..id)
	end
end

function LoadCam(key)
if (source==GUIEditor_Button[10]) then
	local id = guiGetText(GUIEditor_Edit[123])
	if (cam[id]==nil) then
		outputChatBox ("No camera preset specified for this key!")
		else
		LoadCamToMenu(id)
		end
	end
end
---- ---- ---- ----- ---

function ShowLogin()
if (source==slogin) then	
	guiSetVisible(dlmenu, true)
	--guiSetText(dlmenu, "Director login. Enter Password")
	guiBringToFront(dlmenu)
	guiSetInputEnabled (true)
	end
end

function EnterPass()
if (source==dlok)or(source==dledit) then
	local txt = guiGetText(dledit)
	if (txt~="") then
		triggerServerEvent("clientWantLogin", getLocalPlayer(), txt)
		guiSetVisible(dlmenu, false)
		guiSetInputEnabled (false)
		end
	elseif (source==dlcancel) then
	guiSetVisible(dlmenu, false)
	guiSetInputEnabled (false)
	end
end

function login(val)
	if (val==true) then
		outputChatBox("Login success")
		MenuButtonDisable(true)
		logged = true
		guiSetText(sllogin, "Logged as: director")
		else
		outputChatBox("Wrong password")
		end
end
addEvent( "onLogin", true )
addEventHandler( "onLogin", getRootElement(), login)
--- --- ---

function ShowMapSel()
if (source==sselmap) then	
	guiSetVisible(smmenu, true)
	--guiSetText(dlmenu, "Director login. Enter Password")
	guiBringToFront(smmenu)
	guiSetInputEnabled (true)
	end
end

function EnterMapName()
if (source==smok)or(source==smedit) then
	local txt = guiGetText(smedit)
	if (txt~="") then
		triggerServerEvent("clientSelectMap", getLocalPlayer(), txt)
		guiSetVisible(smmenu, false)
		guiSetInputEnabled (false)
		end
	elseif (source==smcancel) then
	guiSetVisible(smmenu, false)
	guiSetInputEnabled (false)
	end
end

--- --- ---
function MinDurShow()
if (source==smindur) then	
	guiSetVisible(mdmenu, true)
	guiBringToFront(mdmenu)
	guiSetInputEnabled (true)
	end
end

function EnterMinDur()
if (source==mdok)or(source==mdedit) then
	local txt = guiGetText(mdedit)
	if (txt~="") then
		local val = tonumber(txt)
		if (val>=0) then
			setMinuteDuration(val)
			end
		guiSetVisible(mdmenu, false)
		guiSetInputEnabled (false)
		end
	elseif (source==mdcancel) then
	guiSetVisible(mdmenu, false)
	guiSetInputEnabled (false)
	end
end

--- --- ---

function SaveMenuShow()
if (source==ssave) then	
	guiSetVisible(sdlmenu, true)
	--guiSetText(dlmenu, "Director login. Enter Password")
	guiBringToFront(sdlmenu)
	guiSetInputEnabled (true)
	end
end

function SaveMenuSend()
if (source==sdlsave)or(source==sdledit2) then
	local path = guiGetText(sdledit1)
	local fname = guiGetText(sdledit2)
	if (fname~="") then
		triggerServerEvent("clientWantSave", getLocalPlayer(), path, fname, guiCheckBoxGetSelected(sdlowr))
		guiSetVisible(sdlmenu, false)
		guiSetInputEnabled (false)
		end
	elseif (source==sdlcancel) then
	guiSetVisible(sdlmenu, false)
	guiSetInputEnabled (false)
	end
end
--- --- ---

function LoadMenuShow()
if (source==sload) then	
	guiSetVisible(odlmenu, true)
	--guiSetText(dlmenu, "Director login. Enter Password")
	guiBringToFront(odlmenu)
	guiSetInputEnabled (true)
	end
end

function LoadMenuSend()
if (source==odlsave)or(source==odledit2) then
	local path = guiGetText(odledit1)
	local fname = guiGetText(odledit2)
	if (fname~="") then
		triggerServerEvent("clientWantLoad", getLocalPlayer(), path, fname)
		guiSetVisible(odlmenu, false)
		guiSetInputEnabled (false)
		end
	elseif (source==odlcancel) then
	guiSetVisible(odlmenu, false)
	guiSetInputEnabled (false)
	end
end
--- --- ---
function ClearMenuShow()
if (source==sclear) then	
	guiSetVisible(clmenu, true)
	guiBringToFront(clmenu)
	guiSetInputEnabled (true)
	end
end

function EnterClearMenu()
if (source==clok)or(source==cledit) then
	guiSetVisible(clmenu, false)
	guiSetInputEnabled (false)	
	triggerServerEvent("clientWantClear",getLocalPlayer())
	else
	guiSetVisible(clmenu, false)
	guiSetInputEnabled (false)
	end
end
--- --- ---
function SLimiterMenu()
if (source==sslim) then	
	guiSetVisible(slmenu, true)
	guiBringToFront(slmenu)
	guiSetInputEnabled (true)
	end
end

function SLimiterAccept()
if (source==slok)or(source==sledit1) then
	guiSetVisible(slmenu, false)
	guiSetInputEnabled (false)	
	if (tonumber(guiGetText(sledit1))~=nil) then
		speedLimit = tonumber(guiGetText(sledit1))
		end
	else
	guiSetVisible(slmenu, false)
	guiSetInputEnabled (false)
	end
end
--- --- ---
function QualityMenu()
if (source==squal) then	
	guiSetVisible(qmenu, true)
	guiBringToFront(qmenu)
	guiSetInputEnabled (true)
	end
end

function QualityMenuAccept()
if (source==qacc) then
	guiSetVisible(qmenu, false)
	guiSetInputEnabled (false)
	local par1,par2,par3 = 1,5,20
	local par4,par5 = 1,2
	local skip_mode = 1
	local skip_fi = 3
	if (guiRadioButtonGetSelected(qmin)) then
	par1 = 5.0
	par2 = 10.0
	par3 = 40.0
	par4 = 6.0
	par5 = 3.0
	skip_mode = 1
	elseif (guiRadioButtonGetSelected(qmed)) then
	par1 = 2.0
	par2 = 3.0
	par3 = 15.0
	par4 = 3.0
	par5 = 2.0
	skip_mode = 1
	elseif (guiRadioButtonGetSelected(qhigh)) then
	par1 = 1.0
	par2 = 1.0
	par3 = 10.0
	par4 = 2.0
	par5 = 0.5
	skip_mode = 1
	elseif (guiRadioButtonGetSelected(qfmin)) then
	skip_mode = 0
	skip_fi = 16	
	elseif (guiRadioButtonGetSelected(qfmed)) then
	skip_mode = 0
	skip_fi = 8
	elseif (guiRadioButtonGetSelected(qfhigh)) then
	skip_mode = 0
	skip_fi = 2
	elseif (guiRadioButtonGetSelected(qfmax)) then
	skip_mode = 0
	skip_fi = 0
	elseif (guiRadioButtonGetSelected(qman)) then
	skip_mode = 1
	par1 = tonumber(guiGetText(qedit1))
	par2 = tonumber(guiGetText(qedit2))
	par3 = par2*5
	par4 = tonumber(guiGetText(qedit3))
	par5 = tonumber(guiGetText(qedit4))
	elseif (guiRadioButtonGetSelected(qfman)) then
	skip_mode = 0
	skip_fi = tonumber(guiGetText(qedit5))
	end
	triggerServerEvent("clientQualitySet", getLocalPlayer(),skip_mode,skip_fi,par1,par2,par3,par4,par5)
	elseif (source==qcancel) then
	guiSetVisible(qmenu, false)
	guiSetInputEnabled (false)
	end
end

--- --- ---
--- --- ---
function MenuButtonDisable(val)
	guiSetEnabled( srec,val)
	guiSetEnabled( sstop,val)
	guiSetEnabled( sreset,val)
	guiSetEnabled( sclear,val)
	guiSetEnabled( skill,val)
	guiSetEnabled( ssave,val)
	guiSetEnabled( sload,val)
	guiSetEnabled( splay,val)
	guiSetEnabled( sswitch,val)
	guiSetEnabled( sselmap,val)
	guiSetEnabled( squal,val)
end

function CamMenuShow()
if (source==scam) then
	if (isDirector==true) then
		CamMenu("nh")
		else
		FreeCam()
		end
	end
end

function det(m,i,j)-- noob code. I'm so tired today. sorry.
local i1 =2
local i2 = 3
local i3 = 4
local j1 =2
local j2 = 3
local j3 = 4
if (i==2) then 
i1 =1
i2 = 3
i3 = 4
elseif (i==3) then
i1 =1
i2 = 2
i3 = 4
elseif (i==4) then
i1 =1
i2 = 2
i3 = 3
end
if (j==2) then 
j1 =1
j2 = 3
j3 = 4
elseif (j==3) then
j1 =1
j2 = 2
j3 = 4
elseif (j==4) then
j1 =1
j2 = 2
j3 = 3
end
local res = m[i1][j1]*m[i2][j2]*m[i3][j3]+m[i1][j2]*m[i2][j3]*m[i3][j1]+m[i2][j1]*m[i3][j2]*m[i1][j3]-
m[i3][j1]*m[i2][j2]*m[i1][j3]-m[i1][j2]*m[i2][j1]*m[i3][j3]-m[i1][j1]*m[i2][j3]*m[i3][j2]
return res
end

function getCurrentPosition()
local px,py,pz,tx,ty,tz = getCameraMatrix()
local elem = getElementByID(guiGetText(GUIEditor_Edit[1]))
local nx,ny,nz = 0,0,0
if (elem)and(guiRadioButtonGetSelected(GUIEditor_Radio[1])) then
	local matrix = getElementMatrix (elem)
	--px, py, pz = getElementPosition(locPlr)
	
	--vec = {}
	--vec[1] = px
	--vec[2] = py
	--vec[3] = pz
	--vec[4] = 1
	
	--[[px = 30
	py = 10
	pz = 3
	pn = 10
	
	matrix[1][1] = 1
	matrix[1][2] = 2
	matrix[1][3] = 3
	matrix[1][4] = 4
	
	matrix[2][1] = -1
	matrix[2][2] = 2
	matrix[2][3] = -3
	matrix[2][4] = 4
	
	matrix[3][1] = 0
	matrix[3][2] = 1
	matrix[3][3] = -1
	matrix[3][4] = 1
	
	matrix[4][1] = 1
	matrix[4][2] = 1
	matrix[4][3] = 1
	matrix[4][4] = 1]]--
	pn = 1
	local det0 = (matrix[1][1]*det(matrix,1,1)-matrix[1][2]*det(matrix,1,2)+matrix[1][3]*det(matrix,1,3)-matrix[1][4]*det(matrix,1,4))

	matrix[1][1] = px
	matrix[2][1] = py
	matrix[3][1] = pz
	matrix[4][1] = pn
	local det1 = (matrix[1][1]*det(matrix,1,1)-matrix[1][2]*det(matrix,1,2)+matrix[1][3]*det(matrix,1,3)-matrix[1][4]*det(matrix,1,4))
	nx = det1/det0

	local matrix = getElementMatrix (elem)
	matrix[1][2] = px
	matrix[2][2] = py
	matrix[3][2] = pz
	matrix[4][2] = pn
	local det2 = (matrix[1][1]*det(matrix,1,1)-matrix[1][2]*det(matrix,1,2)+matrix[1][3]*det(matrix,1,3)-matrix[1][4]*det(matrix,1,4))	
	ny = det2/det0

	local matrix = getElementMatrix (elem)
	matrix[1][3] = px
	matrix[2][3] = py
	matrix[3][3] = pz
	matrix[4][3] = pn
	local det3 = (matrix[1][1]*det(matrix,1,1)-matrix[1][2]*det(matrix,1,2)+matrix[1][3]*det(matrix,1,3)-matrix[1][4]*det(matrix,1,4))

	nz = det3/det0

	local matrix = getElementMatrix (elem)
	matrix[1][4] = px
	matrix[2][4] = py
	matrix[3][4] = pz
	matrix[4][4] = pn
	local det4 = (matrix[1][1]*det(matrix,1,1)-matrix[1][2]*det(matrix,1,2)+matrix[1][3]*det(matrix,1,3)-matrix[1][4]*det(matrix,1,4))

	nn = det4/det0
	
	local px0 = nx/nn
	local py0 = ny/nn
	local pz0 = nz/nn
	nx = px0
	ny = py0
	nz = pz0
else
nx = px
ny = py
nz = pz
	
	end
return nx,ny,nz
end

function getCurrentTPosition()
local tx,ty,tz,px,py,pz = getCameraMatrix()
local elem = getElementByID(guiGetText(GUIEditor_Edit[5]))
local nx,ny,nz = 0,0,0
if (elem)and(guiRadioButtonGetSelected(GUIEditor_Radio[3])) then
	local matrix = getElementMatrix (elem)

	pn = 1
	local det0 = (matrix[1][1]*det(matrix,1,1)-matrix[1][2]*det(matrix,1,2)+matrix[1][3]*det(matrix,1,3)-matrix[1][4]*det(matrix,1,4))

	matrix[1][1] = px
	matrix[2][1] = py
	matrix[3][1] = pz
	matrix[4][1] = pn
	local det1 = (matrix[1][1]*det(matrix,1,1)-matrix[1][2]*det(matrix,1,2)+matrix[1][3]*det(matrix,1,3)-matrix[1][4]*det(matrix,1,4))
	nx = det1/det0

	local matrix = getElementMatrix (elem)
	matrix[1][2] = px
	matrix[2][2] = py
	matrix[3][2] = pz
	matrix[4][2] = pn
	local det2 = (matrix[1][1]*det(matrix,1,1)-matrix[1][2]*det(matrix,1,2)+matrix[1][3]*det(matrix,1,3)-matrix[1][4]*det(matrix,1,4))	
	ny = det2/det0

	local matrix = getElementMatrix (elem)
	matrix[1][3] = px
	matrix[2][3] = py
	matrix[3][3] = pz
	matrix[4][3] = pn
	local det3 = (matrix[1][1]*det(matrix,1,1)-matrix[1][2]*det(matrix,1,2)+matrix[1][3]*det(matrix,1,3)-matrix[1][4]*det(matrix,1,4))

	nz = det3/det0

	local matrix = getElementMatrix (elem)
	matrix[1][4] = px
	matrix[2][4] = py
	matrix[3][4] = pz
	matrix[4][4] = pn
	local det4 = (matrix[1][1]*det(matrix,1,1)-matrix[1][2]*det(matrix,1,2)+matrix[1][3]*det(matrix,1,3)-matrix[1][4]*det(matrix,1,4))

	nn = det4/det0
	
	local px0 = nx/nn
	local py0 = ny/nn
	local pz0 = nz/nn
	nx = px0
	ny = py0
	nz = pz0
else
nx = px
ny = py
nz = pz
	
	end
return nx,ny,nz
end

function gp1()
local px,py,pz = getCurrentPosition()
guiSetText(GUIEditor_Edit[2],string.format("%.5f",px))
guiSetText(GUIEditor_Edit[3],string.format("%.5f",py))
guiSetText(GUIEditor_Edit[4],string.format("%.5f",pz))
end
function gp2()
local px,py,pz = getCurrentPosition()
guiSetText(GUIEditor_Edit[9],string.format("%.5f",px))
guiSetText(GUIEditor_Edit[10],string.format("%.5f",py))
guiSetText(GUIEditor_Edit[11],string.format("%.5f",pz))
end
function gt1()
local px,py,pz = getCurrentTPosition()
guiSetText(GUIEditor_Edit[6],string.format("%.5f",px))
guiSetText(GUIEditor_Edit[7],string.format("%.5f",py))
guiSetText(GUIEditor_Edit[8],string.format("%.5f",pz))
end
function gt2()
local px,py,pz = getCurrentTPosition()
guiSetText(GUIEditor_Edit[59],string.format("%.5f",px))
guiSetText(GUIEditor_Edit[60],string.format("%.5f",py))
guiSetText(GUIEditor_Edit[61],string.format("%.5f",pz))
end
function copy1()
guiSetText(GUIEditor_Edit[38],guiGetText(GUIEditor_Edit[88]))
guiSetText(GUIEditor_Edit[39],guiGetText(GUIEditor_Edit[89]))
guiSetText(GUIEditor_Edit[40],guiGetText(GUIEditor_Edit[90]))
guiSetText(GUIEditor_Edit[41],guiGetText(GUIEditor_Edit[91]))

guiSetText(GUIEditor_Edit[42],guiGetText(GUIEditor_Edit[92]))
guiSetText(GUIEditor_Edit[43],guiGetText(GUIEditor_Edit[93]))
guiSetText(GUIEditor_Edit[44],guiGetText(GUIEditor_Edit[94]))
guiSetText(GUIEditor_Edit[45],guiGetText(GUIEditor_Edit[95]))

guiSetText(GUIEditor_Edit[46],guiGetText(GUIEditor_Edit[96]))
guiSetText(GUIEditor_Edit[47],guiGetText(GUIEditor_Edit[97]))
guiSetText(GUIEditor_Edit[48],guiGetText(GUIEditor_Edit[98]))
guiSetText(GUIEditor_Edit[49],guiGetText(GUIEditor_Edit[99]))

guiSetText(GUIEditor_Edit[50],guiGetText(GUIEditor_Edit[100]))
guiSetText(GUIEditor_Edit[51],guiGetText(GUIEditor_Edit[101]))
guiSetText(GUIEditor_Edit[52],guiGetText(GUIEditor_Edit[102]))
guiSetText(GUIEditor_Edit[53],guiGetText(GUIEditor_Edit[103]))
end
function copy2()
guiSetText(GUIEditor_Edit[88],guiGetText(GUIEditor_Edit[38]))
guiSetText(GUIEditor_Edit[89],guiGetText(GUIEditor_Edit[39]))
guiSetText(GUIEditor_Edit[90],guiGetText(GUIEditor_Edit[40]))
guiSetText(GUIEditor_Edit[91],guiGetText(GUIEditor_Edit[41]))

guiSetText(GUIEditor_Edit[92],guiGetText(GUIEditor_Edit[42]))
guiSetText(GUIEditor_Edit[93],guiGetText(GUIEditor_Edit[43]))
guiSetText(GUIEditor_Edit[94],guiGetText(GUIEditor_Edit[44]))
guiSetText(GUIEditor_Edit[95],guiGetText(GUIEditor_Edit[45]))

guiSetText(GUIEditor_Edit[96],guiGetText(GUIEditor_Edit[46]))
guiSetText(GUIEditor_Edit[97],guiGetText(GUIEditor_Edit[47]))
guiSetText(GUIEditor_Edit[98],guiGetText(GUIEditor_Edit[48]))
guiSetText(GUIEditor_Edit[99],guiGetText(GUIEditor_Edit[49]))

guiSetText(GUIEditor_Edit[100],guiGetText(GUIEditor_Edit[50]))
guiSetText(GUIEditor_Edit[101],guiGetText(GUIEditor_Edit[51]))
guiSetText(GUIEditor_Edit[102],guiGetText(GUIEditor_Edit[52]))
guiSetText(GUIEditor_Edit[103],guiGetText(GUIEditor_Edit[53]))
end
--- --- --- --- ---
GUIEditor_Window[1] = guiCreateWindow(93,37,630,534,"Camera settings",false)
GUIEditor_TabPanel[1] = guiCreateTabPanel(0.0238,0.0581,0.9476,0.8296,true,GUIEditor_Window[1])
GUIEditor_Tab[1] = guiCreateTab("Position Init",GUIEditor_TabPanel[1])
GUIEditor_Label[1] = guiCreateLabel(0.0251,0.0286,0.1809,0.0406,"Coord system",true,GUIEditor_Tab[1])
guiLabelSetColor(GUIEditor_Label[1],255,255,255)
guiLabelSetVerticalAlign(GUIEditor_Label[1],"top")
guiLabelSetHorizontalAlign(GUIEditor_Label[1],"left",false)
GUIEditor_Radio[1] = guiCreateRadioButton(0.0251,0.0835,0.2513,0.0525,"Element (local)",true,GUIEditor_Tab[1])
GUIEditor_Radio[2] = guiCreateRadioButton(0.3451,0.0883,0.2228,0.043,"World (global)",true,GUIEditor_Tab[1])
guiRadioButtonSetSelected(GUIEditor_Radio[2],true)
GUIEditor_Label[2] = guiCreateLabel(0.0251,0.1647,0.1491,0.043,"Element ID:",true,GUIEditor_Tab[1])
guiLabelSetColor(GUIEditor_Label[2],255,255,255)
guiLabelSetVerticalAlign(GUIEditor_Label[2],"top")
guiLabelSetHorizontalAlign(GUIEditor_Label[2],"left",false)
GUIEditor_Edit[1] = guiCreateEdit(0.1809,0.1575,0.5159,0.0525,"",true,GUIEditor_Tab[1])
GUIEditor_Button[1] = guiCreateButton(0.7152,0.1599,0.1374,0.0525,"Select",true,GUIEditor_Tab[1])
GUIEditor_Label[3] = guiCreateLabel(0.0302,0.2482,0.1725,0.0477,"Init Position:",true,GUIEditor_Tab[1])
guiLabelSetColor(GUIEditor_Label[3],255,255,255)
guiLabelSetVerticalAlign(GUIEditor_Label[3],"top")
guiLabelSetHorizontalAlign(GUIEditor_Label[3],"left",false)
GUIEditor_Edit[2] = guiCreateEdit(0.1022,0.3126,0.1457,0.0716,"238.7550",true,GUIEditor_Tab[1])
GUIEditor_Edit[3] = guiCreateEdit(0.2496,0.3126,0.1457,0.0716,"14.9725",true,GUIEditor_Tab[1])
GUIEditor_Edit[4] = guiCreateEdit(0.397,0.3126,0.1457,0.0716,"4.5113",true,GUIEditor_Tab[1])
GUIEditor_Label[4] = guiCreateLabel(0.0251,0.3246,0.062,0.0406,"(x;y;z)",true,GUIEditor_Tab[1])
guiLabelSetColor(GUIEditor_Label[4],255,255,255)
guiLabelSetVerticalAlign(GUIEditor_Label[4],"top")
guiLabelSetHorizontalAlign(GUIEditor_Label[4],"left",false)
GUIEditor_Button[2] = guiCreateButton(0.7102,0.3246,0.263,0.1217,"Init camera with current position and target",true,GUIEditor_Tab[1])
GUIEditor_Button[3] = guiCreateButton(0.5477,0.3294,0.0302,0.0477,"c",true,GUIEditor_Tab[1])
GUIEditor_Tab[2] = guiCreateTab("Target Init",GUIEditor_TabPanel[1])
GUIEditor_Label[5] = guiCreateLabel(0.0251,0.0286,0.1809,0.0406,"Coord system",true,GUIEditor_Tab[2])
guiLabelSetColor(GUIEditor_Label[5],255,255,255)
guiLabelSetVerticalAlign(GUIEditor_Label[5],"top")
guiLabelSetHorizontalAlign(GUIEditor_Label[5],"left",false)
GUIEditor_Radio[3] = guiCreateRadioButton(0.0251,0.0835,0.2513,0.0525,"Element (local)",true,GUIEditor_Tab[2])
GUIEditor_Radio[4] = guiCreateRadioButton(0.3451,0.0883,0.2228,0.043,"World (global)",true,GUIEditor_Tab[2])
guiRadioButtonSetSelected(GUIEditor_Radio[4],true)
GUIEditor_Label[6] = guiCreateLabel(0.0251,0.1647,0.1491,0.043,"Element ID:",true,GUIEditor_Tab[2])
guiLabelSetColor(GUIEditor_Label[6],255,255,255)
guiLabelSetVerticalAlign(GUIEditor_Label[6],"top")
guiLabelSetHorizontalAlign(GUIEditor_Label[6],"left",false)
GUIEditor_Edit[5] = guiCreateEdit(0.1809,0.1575,0.5159,0.0525,"",true,GUIEditor_Tab[2])
GUIEditor_Button[4] = guiCreateButton(0.7152,0.1599,0.1374,0.0525,"Select",true,GUIEditor_Tab[2])
GUIEditor_Label[7] = guiCreateLabel(0.0302,0.2482,0.1725,0.0477,"Init Position:",true,GUIEditor_Tab[2])
guiLabelSetColor(GUIEditor_Label[7],255,255,255)
guiLabelSetVerticalAlign(GUIEditor_Label[7],"top")
guiLabelSetHorizontalAlign(GUIEditor_Label[7],"left",false)
GUIEditor_Edit[6] = guiCreateEdit(0.1022,0.3126,0.1457,0.0716,"234.7034",true,GUIEditor_Tab[2])
GUIEditor_Edit[7] = guiCreateEdit(0.2496,0.3126,0.1457,0.0716,"16.3065",true,GUIEditor_Tab[2])
GUIEditor_Edit[8] = guiCreateEdit(0.397,0.3126,0.1457,0.0716,"4.4518",true,GUIEditor_Tab[2])
GUIEditor_Label[8] = guiCreateLabel(0.0251,0.3246,0.062,0.0406,"(x;y;z)",true,GUIEditor_Tab[2])
guiLabelSetColor(GUIEditor_Label[8],255,255,255)
guiLabelSetVerticalAlign(GUIEditor_Label[8],"top")
guiLabelSetHorizontalAlign(GUIEditor_Label[8],"left",false)
GUIEditor_Button[5] = guiCreateButton(0.5477,0.3294,0.0302,0.0477,"c",true,GUIEditor_Tab[2])
GUIEditor_Tab[3] = guiCreateTab("Position Movement",GUIEditor_TabPanel[1])
GUIEditor_Radio[5] = guiCreateRadioButton(0.0134,0.0143,0.3333,0.0382,"Rotation around Target",true,GUIEditor_Tab[3])
guiSetFont(GUIEditor_Radio[5],"default-bold-small")
GUIEditor_Radio[6] = guiCreateRadioButton(0.0134,0.327,0.4188,0.0477,"Move to point",true,GUIEditor_Tab[3])
guiSetFont(GUIEditor_Radio[6],"default-bold-small")
GUIEditor_Radio[7] = guiCreateRadioButton(0.0151,0.58,0.3635,0.0453,"Static",true,GUIEditor_Tab[3])
guiSetFont(GUIEditor_Radio[7],"default-bold-small")
GUIEditor_Radio[8] = guiCreateRadioButton(0.4992,0.58,0.2127,0.043,"Manual Movement",true,GUIEditor_Tab[3])
guiRadioButtonSetSelected(GUIEditor_Radio[8],true)
guiSetFont(GUIEditor_Radio[8],"default-bold-small")
GUIEditor_Label[9] = guiCreateLabel(0.0201,0.1885,0.1106,0.0358,"pitch",true,GUIEditor_Tab[3])
guiLabelSetColor(GUIEditor_Label[9],255,255,255)
guiLabelSetVerticalAlign(GUIEditor_Label[9],"top")
guiLabelSetHorizontalAlign(GUIEditor_Label[9],"left",false)
GUIEditor_Label[10] = guiCreateLabel(0.0201,0.1217,0.1039,0.0334,"rotation",true,GUIEditor_Tab[3])
guiLabelSetColor(GUIEditor_Label[10],255,255,255)
guiLabelSetVerticalAlign(GUIEditor_Label[10],"top")
guiLabelSetHorizontalAlign(GUIEditor_Label[10],"left",false)
GUIEditor_Label[11] = guiCreateLabel(0.0168,0.2721,0.1139,0.0382,"distance",true,GUIEditor_Tab[3])
guiLabelSetColor(GUIEditor_Label[11],255,255,255)
guiLabelSetVerticalAlign(GUIEditor_Label[11],"top")
guiLabelSetHorizontalAlign(GUIEditor_Label[11],"left",false)
GUIEditor_Label[12] = guiCreateLabel(0.0201,0.3842,0.0637,0.043,"(x,y,z)",true,GUIEditor_Tab[3])
guiLabelSetColor(GUIEditor_Label[12],255,255,255)
guiLabelSetVerticalAlign(GUIEditor_Label[12],"top")
guiLabelSetHorizontalAlign(GUIEditor_Label[12],"left",false)
GUIEditor_Edit[9] = guiCreateEdit(0.0871,0.3842,0.1491,0.0597,"2.0",true,GUIEditor_Tab[3])
GUIEditor_Edit[10] = guiCreateEdit(0.2379,0.3842,0.1491,0.0597,"5.0",true,GUIEditor_Tab[3])
GUIEditor_Edit[11] = guiCreateEdit(0.3886,0.3842,0.1491,0.0597,"4.0",true,GUIEditor_Tab[3])
GUIEditor_Label[13] = guiCreateLabel(0.0168,0.4582,0.1055,0.043,"Init speed",true,GUIEditor_Tab[3])
guiLabelSetColor(GUIEditor_Label[13],255,255,255)
guiLabelSetVerticalAlign(GUIEditor_Label[13],"top")
guiLabelSetHorizontalAlign(GUIEditor_Label[13],"left",false)
GUIEditor_Edit[12] = guiCreateEdit(0.129,0.4606,0.1139,0.0477,"0",true,GUIEditor_Tab[3])
GUIEditor_Label[14] = guiCreateLabel(0.5377,0.4654,0.1156,0.0358,"Acceleration",true,GUIEditor_Tab[3])
guiLabelSetColor(GUIEditor_Label[14],255,255,255)
guiLabelSetVerticalAlign(GUIEditor_Label[14],"top")
guiLabelSetHorizontalAlign(GUIEditor_Label[14],"left",false)
GUIEditor_Edit[13] = guiCreateEdit(0.6616,0.4582,0.1256,0.0501,"0.004",true,GUIEditor_Tab[3])
GUIEditor_Label[15] = guiCreateLabel(0.5394,0.5227,0.1307,0.043,"Deceleration",true,GUIEditor_Tab[3])
guiLabelSetColor(GUIEditor_Label[15],255,255,255)
guiLabelSetVerticalAlign(GUIEditor_Label[15],"top")
guiLabelSetHorizontalAlign(GUIEditor_Label[15],"left",false)
GUIEditor_Edit[14] = guiCreateEdit(0.6616,0.5179,0.1256,0.0501,"-0.008",true,GUIEditor_Tab[3])
GUIEditor_Label[16] = guiCreateLabel(0.0134,0.5179,0.1206,0.043,"Max. speed",true,GUIEditor_Tab[3])
guiLabelSetColor(GUIEditor_Label[16],255,255,255)
guiLabelSetVerticalAlign(GUIEditor_Label[16],"top")
guiLabelSetHorizontalAlign(GUIEditor_Label[16],"left",false)
GUIEditor_Edit[15] = guiCreateEdit(0.129,0.5179,0.1139,0.0477,"0.5",true,GUIEditor_Tab[3])
GUIEditor_Label[17] = guiCreateLabel(0.268,0.5251,0.129,0.0382,"Min. speed",true,GUIEditor_Tab[3])
guiLabelSetColor(GUIEditor_Label[17],255,255,255)
guiLabelSetVerticalAlign(GUIEditor_Label[17],"top")
guiLabelSetHorizontalAlign(GUIEditor_Label[17],"left",false)
GUIEditor_Edit[16] = guiCreateEdit(0.392,0.5203,0.1256,0.0477,"0",true,GUIEditor_Tab[3])
GUIEditor_Label[18] = guiCreateLabel(0.139,0.0716,0.139,0.0501,"Init angle(deg)",true,GUIEditor_Tab[3])
guiLabelSetColor(GUIEditor_Label[18],255,255,255)
guiLabelSetVerticalAlign(GUIEditor_Label[18],"top")
guiLabelSetHorizontalAlign(GUIEditor_Label[18],"left",false)
GUIEditor_Label[19] = guiCreateLabel(0.2931,0.074,0.0955,0.0382,"Rotate",true,GUIEditor_Tab[3])
guiLabelSetColor(GUIEditor_Label[19],255,255,255)
guiLabelSetVerticalAlign(GUIEditor_Label[19],"top")
guiLabelSetHorizontalAlign(GUIEditor_Label[19],"left",false)
GUIEditor_Label[20] = guiCreateLabel(0.3987,0.0716,0.1139,0.0382,"Acceleration",true,GUIEditor_Tab[3])
guiLabelSetColor(GUIEditor_Label[20],255,255,255)
guiLabelSetVerticalAlign(GUIEditor_Label[20],"top")
guiLabelSetHorizontalAlign(GUIEditor_Label[20],"left",false)
GUIEditor_Label[21] = guiCreateLabel(0.5176,0.0716,0.1424,0.0358,"Deceleration",true,GUIEditor_Tab[3])
guiLabelSetColor(GUIEditor_Label[21],255,255,255)
guiLabelSetVerticalAlign(GUIEditor_Label[21],"top")
guiLabelSetHorizontalAlign(GUIEditor_Label[21],"left",false)
GUIEditor_Label[22] = guiCreateLabel(0.6566,0.0334,0.0536,0.074,"Init\nspeed",true,GUIEditor_Tab[3])
guiLabelSetColor(GUIEditor_Label[22],255,255,255)
guiLabelSetVerticalAlign(GUIEditor_Label[22],"top")
guiLabelSetHorizontalAlign(GUIEditor_Label[22],"left",false)
GUIEditor_Label[23] = guiCreateLabel(0.727,0.0573,0.0988,0.0716,"Max spd",true,GUIEditor_Tab[3])
guiLabelSetColor(GUIEditor_Label[23],255,255,255)
guiLabelSetVerticalAlign(GUIEditor_Label[23],"top")
guiLabelSetHorizontalAlign(GUIEditor_Label[23],"left",false)
GUIEditor_Label[24] = guiCreateLabel(0.8107,0.0573,0.0888,0.0597,"Min spd",true,GUIEditor_Tab[3])
guiLabelSetColor(GUIEditor_Label[24],255,255,255)
guiLabelSetVerticalAlign(GUIEditor_Label[24],"top")
guiLabelSetHorizontalAlign(GUIEditor_Label[24],"left",false)
GUIEditor_Edit[17] = guiCreateEdit(0.1424,0.1169,0.0938,0.0477,"0",true,GUIEditor_Tab[3])
GUIEditor_Edit[18] = guiCreateEdit(0.2881,0.1169,0.0938,0.0477,"350",true,GUIEditor_Tab[3])
GUIEditor_Edit[19] = guiCreateEdit(0.4171,0.1169,0.0938,0.0477,"0.008",true,GUIEditor_Tab[3])
GUIEditor_Edit[20] = guiCreateEdit(0.5394,0.1169,0.0938,0.0477,"-0.01",true,GUIEditor_Tab[3])
GUIEditor_Edit[21] = guiCreateEdit(0.6482,0.1146,0.0754,0.0477,"0",true,GUIEditor_Tab[3])
GUIEditor_Edit[22] = guiCreateEdit(0.7286,0.1146,0.0787,0.0477,"0.1",true,GUIEditor_Tab[3])
GUIEditor_Edit[23] = guiCreateEdit(0.8107,0.1146,0.0787,0.0477,"0",true,GUIEditor_Tab[3])
GUIEditor_Edit[24] = guiCreateEdit(0.1424,0.1814,0.0938,0.0477,"0",true,GUIEditor_Tab[3])
GUIEditor_Edit[25] = guiCreateEdit(0.2864,0.179,0.0938,0.0477,"60",true,GUIEditor_Tab[3])
GUIEditor_Edit[26] = guiCreateEdit(0.4171,0.179,0.0938,0.0477,"0.001",true,GUIEditor_Tab[3])
GUIEditor_Edit[27] = guiCreateEdit(0.541,0.179,0.0938,0.0477,"-0.001",true,GUIEditor_Tab[3])
GUIEditor_Edit[28] = guiCreateEdit(0.6499,0.179,0.0754,0.0477,"0",true,GUIEditor_Tab[3])
GUIEditor_Edit[29] = guiCreateEdit(0.7303,0.179,0.0787,0.0477,"0.05",true,GUIEditor_Tab[3])
GUIEditor_Edit[30] = guiCreateEdit(0.8124,0.179,0.0787,0.0477,"0",true,GUIEditor_Tab[3])
GUIEditor_Label[25] = guiCreateLabel(0.134,0.2315,0.139,0.0501,"Init value",true,GUIEditor_Tab[3])
guiLabelSetColor(GUIEditor_Label[25],255,255,255)
guiLabelSetVerticalAlign(GUIEditor_Label[25],"top")
guiLabelSetHorizontalAlign(GUIEditor_Label[25],"left",false)
GUIEditor_Edit[31] = guiCreateEdit(0.1407,0.2721,0.0938,0.0477,"0",true,GUIEditor_Tab[3])
GUIEditor_Edit[32] = guiCreateEdit(0.2848,0.2721,0.0938,0.0477,"60",true,GUIEditor_Tab[3])
GUIEditor_Edit[33] = guiCreateEdit(0.4171,0.2721,0.0938,0.0477,"0.004",true,GUIEditor_Tab[3])
GUIEditor_Edit[34] = guiCreateEdit(0.541,0.2721,0.0938,0.0477,"-0.05",true,GUIEditor_Tab[3])
GUIEditor_Edit[35] = guiCreateEdit(0.6482,0.2721,0.0754,0.0477,"0",true,GUIEditor_Tab[3])
GUIEditor_Edit[36] = guiCreateEdit(0.7286,0.2721,0.0787,0.0477,"0.05",true,GUIEditor_Tab[3])
GUIEditor_Edit[37] = guiCreateEdit(0.809,0.2721,0.0787,0.0477,"0",true,GUIEditor_Tab[3])
GUIEditor_Label[26] = guiCreateLabel(0.4992,0.6611,0.1809,0.0501,"strafe pos",true,GUIEditor_Tab[3])
guiLabelSetColor(GUIEditor_Label[26],255,255,255)
guiLabelSetVerticalAlign(GUIEditor_Label[26],"top")
guiLabelSetHorizontalAlign(GUIEditor_Label[26],"left",false)
GUIEditor_Edit[38] = guiCreateEdit(0.6332,0.6635,0.0821,0.0477,"0.004",true,GUIEditor_Tab[3])
GUIEditor_Label[27] = guiCreateLabel(0.5008,0.716,0.124,0.0501,"move pos",true,GUIEditor_Tab[3])
guiLabelSetColor(GUIEditor_Label[27],255,255,255)
guiLabelSetVerticalAlign(GUIEditor_Label[27],"top")
guiLabelSetHorizontalAlign(GUIEditor_Label[27],"left",false)
GUIEditor_Label[28] = guiCreateLabel(0.6348,0.6253,0.0553,0.0334,"accel",true,GUIEditor_Tab[3])
guiLabelSetColor(GUIEditor_Label[28],255,255,255)
guiLabelSetVerticalAlign(GUIEditor_Label[28],"top")
guiLabelSetHorizontalAlign(GUIEditor_Label[28],"left",false)
GUIEditor_Label[29] = guiCreateLabel(0.7219,0.6253,0.0553,0.0334,"decel",true,GUIEditor_Tab[3])
guiLabelSetColor(GUIEditor_Label[29],255,255,255)
guiLabelSetVerticalAlign(GUIEditor_Label[29],"top")
guiLabelSetHorizontalAlign(GUIEditor_Label[29],"left",false)
GUIEditor_Edit[39] = guiCreateEdit(0.7169,0.6635,0.0821,0.0477,"-0.008",true,GUIEditor_Tab[3])
GUIEditor_Edit[40] = guiCreateEdit(0.799,0.6635,0.0821,0.0477,"1",true,GUIEditor_Tab[3])
GUIEditor_Edit[41] = guiCreateEdit(0.8811,0.6635,0.0821,0.0477,"-1",true,GUIEditor_Tab[3])
GUIEditor_Label[30] = guiCreateLabel(0.8007,0.6181,0.0754,0.0406,"max spd",true,GUIEditor_Tab[3])
guiLabelSetColor(GUIEditor_Label[30],255,255,255)
guiLabelSetVerticalAlign(GUIEditor_Label[30],"top")
guiLabelSetHorizontalAlign(GUIEditor_Label[30],"left",false)
GUIEditor_Label[31] = guiCreateLabel(0.8861,0.6134,0.0737,0.0358,"min spd",true,GUIEditor_Tab[3])
guiLabelSetColor(GUIEditor_Label[31],255,255,255)
guiLabelSetVerticalAlign(GUIEditor_Label[31],"top")
guiLabelSetHorizontalAlign(GUIEditor_Label[31],"left",false)
GUIEditor_Label[32] = guiCreateLabel(0.5008,0.7637,0.1273,0.0501,"rotate",true,GUIEditor_Tab[3])
guiLabelSetColor(GUIEditor_Label[32],255,255,255)
guiLabelSetVerticalAlign(GUIEditor_Label[32],"top")
guiLabelSetHorizontalAlign(GUIEditor_Label[32],"left",false)
GUIEditor_Edit[42] = guiCreateEdit(0.6332,0.7136,0.0821,0.0477,"0.004",true,GUIEditor_Tab[3])
GUIEditor_Edit[43] = guiCreateEdit(0.7169,0.7136,0.0821,0.0477,"-0.008",true,GUIEditor_Tab[3])
GUIEditor_Edit[44] = guiCreateEdit(0.799,0.7136,0.0821,0.0477,"1",true,GUIEditor_Tab[3])
GUIEditor_Edit[45] = guiCreateEdit(0.8811,0.7136,0.0821,0.0477,"-1",true,GUIEditor_Tab[3])
GUIEditor_Edit[46] = guiCreateEdit(0.6348,0.7613,0.0821,0.0477,"0.003",true,GUIEditor_Tab[3])
GUIEditor_Edit[47] = guiCreateEdit(0.7186,0.7613,0.0821,0.0477,"-0.002",true,GUIEditor_Tab[3])
GUIEditor_Edit[48] = guiCreateEdit(0.8007,0.7613,0.0821,0.0477,"0.05",true,GUIEditor_Tab[3])
GUIEditor_Edit[49] = guiCreateEdit(0.8827,0.7613,0.0821,0.0477,"-0.05",true,GUIEditor_Tab[3])
GUIEditor_Label[33] = guiCreateLabel(0.4992,0.8138,0.1273,0.0501,"pitch",true,GUIEditor_Tab[3])
guiLabelSetColor(GUIEditor_Label[33],255,255,255)
guiLabelSetVerticalAlign(GUIEditor_Label[33],"top")
guiLabelSetHorizontalAlign(GUIEditor_Label[33],"left",false)
GUIEditor_Edit[50] = guiCreateEdit(0.6348,0.8091,0.0821,0.0477,"0.003",true,GUIEditor_Tab[3])
GUIEditor_Edit[51] = guiCreateEdit(0.7186,0.8091,0.0821,0.0477,"-0.002",true,GUIEditor_Tab[3])
GUIEditor_Edit[52] = guiCreateEdit(0.8007,0.8091,0.0821,0.0477,"0.05",true,GUIEditor_Tab[3])
GUIEditor_Edit[53] = guiCreateEdit(0.8827,0.8091,0.0821,0.0477,"-0.05",true,GUIEditor_Tab[3])
GUIEditor_Label[34] = guiCreateLabel(0.4992,0.9332,0.1441,0.0382,"Shift multiply",true,GUIEditor_Tab[3])
guiLabelSetColor(GUIEditor_Label[34],255,255,255)
guiLabelSetVerticalAlign(GUIEditor_Label[34],"top")
guiLabelSetHorizontalAlign(GUIEditor_Label[34],"left",false)
GUIEditor_Edit[54] = guiCreateEdit(0.6315,0.9236,0.0821,0.0477,"5.0",true,GUIEditor_Tab[3])
GUIEditor_Button[6] = guiCreateButton(0.5427,0.3914,0.0318,0.0453,"c",true,GUIEditor_Tab[3])
GUIEditor_Button[7] = guiCreateButton(0.871,0.9356,0.0938,0.043,"as tar",true,GUIEditor_Tab[3])
GUIEditor_Label[35] = guiCreateLabel(0.4992,0.864,0.1273,0.0501,"distance",true,GUIEditor_Tab[3])
guiLabelSetColor(GUIEditor_Label[35],255,255,255)
guiLabelSetVerticalAlign(GUIEditor_Label[35],"top")
guiLabelSetHorizontalAlign(GUIEditor_Label[35],"left",false)
GUIEditor_Edit[55] = guiCreateEdit(0.6348,0.8568,0.0821,0.0477,"0.004",true,GUIEditor_Tab[3])
GUIEditor_Edit[56] = guiCreateEdit(0.7186,0.8568,0.0821,0.0477,"-0.008",true,GUIEditor_Tab[3])
GUIEditor_Edit[57] = guiCreateEdit(0.8007,0.8568,0.0821,0.0477,"1",true,GUIEditor_Tab[3])
GUIEditor_Edit[58] = guiCreateEdit(0.8827,0.8568,0.0821,0.0477,"-1",true,GUIEditor_Tab[3])
GUIEditor_Tab[4] = guiCreateTab("Target Movement",GUIEditor_TabPanel[1])
GUIEditor_Radio[9] = guiCreateRadioButton(0.0134,0.0143,0.3333,0.0382,"Rotation around Cam Position",true,GUIEditor_Tab[4])
guiSetFont(GUIEditor_Radio[9],"default-bold-small")
GUIEditor_Radio[10] = guiCreateRadioButton(0.0134,0.327,0.4188,0.0477,"Move to point",true,GUIEditor_Tab[4])
guiSetFont(GUIEditor_Radio[10],"default-bold-small")
GUIEditor_Radio[11] = guiCreateRadioButton(0.0151,0.58,0.3635,0.0453,"Static",true,GUIEditor_Tab[4])
guiSetFont(GUIEditor_Radio[11],"default-bold-small")
GUIEditor_Radio[12] = guiCreateRadioButton(0.4992,0.58,0.2127,0.043,"Manual Movement",true,GUIEditor_Tab[4])
guiRadioButtonSetSelected(GUIEditor_Radio[12],true)
guiSetFont(GUIEditor_Radio[12],"default-bold-small")
GUIEditor_Label[36] = guiCreateLabel(0.0201,0.1885,0.1106,0.0358,"pitch",true,GUIEditor_Tab[4])
guiLabelSetColor(GUIEditor_Label[36],255,255,255)
guiLabelSetVerticalAlign(GUIEditor_Label[36],"top")
guiLabelSetHorizontalAlign(GUIEditor_Label[36],"left",false)
GUIEditor_Label[37] = guiCreateLabel(0.0201,0.1217,0.1039,0.0334,"rotation",true,GUIEditor_Tab[4])
guiLabelSetColor(GUIEditor_Label[37],255,255,255)
guiLabelSetVerticalAlign(GUIEditor_Label[37],"top")
guiLabelSetHorizontalAlign(GUIEditor_Label[37],"left",false)
GUIEditor_Label[38] = guiCreateLabel(0.0168,0.2721,0.1139,0.0382,"distance",true,GUIEditor_Tab[4])
guiLabelSetColor(GUIEditor_Label[38],255,255,255)
guiLabelSetVerticalAlign(GUIEditor_Label[38],"top")
guiLabelSetHorizontalAlign(GUIEditor_Label[38],"left",false)
GUIEditor_Label[39] = guiCreateLabel(0.0201,0.3842,0.0637,0.043,"(x,y,z)",true,GUIEditor_Tab[4])
guiLabelSetColor(GUIEditor_Label[39],255,255,255)
guiLabelSetVerticalAlign(GUIEditor_Label[39],"top")
guiLabelSetHorizontalAlign(GUIEditor_Label[39],"left",false)
GUIEditor_Edit[59] = guiCreateEdit(0.0871,0.3842,0.1491,0.0597,"2.0",true,GUIEditor_Tab[4])
GUIEditor_Edit[60] = guiCreateEdit(0.2379,0.3842,0.1491,0.0597,"5.0",true,GUIEditor_Tab[4])
GUIEditor_Edit[61] = guiCreateEdit(0.3886,0.3842,0.1491,0.0597,"4.0",true,GUIEditor_Tab[4])
GUIEditor_Label[40] = guiCreateLabel(0.0168,0.4582,0.1055,0.043,"Init speed",true,GUIEditor_Tab[4])
guiLabelSetColor(GUIEditor_Label[40],255,255,255)
guiLabelSetVerticalAlign(GUIEditor_Label[40],"top")
guiLabelSetHorizontalAlign(GUIEditor_Label[40],"left",false)
GUIEditor_Edit[62] = guiCreateEdit(0.129,0.4606,0.1139,0.0477,"0",true,GUIEditor_Tab[4])
GUIEditor_Label[41] = guiCreateLabel(0.5377,0.4654,0.1156,0.0358,"Acceleration",true,GUIEditor_Tab[4])
guiLabelSetColor(GUIEditor_Label[41],255,255,255)
guiLabelSetVerticalAlign(GUIEditor_Label[41],"top")
guiLabelSetHorizontalAlign(GUIEditor_Label[41],"left",false)
GUIEditor_Edit[63] = guiCreateEdit(0.6616,0.4582,0.1256,0.0501,"0.004",true,GUIEditor_Tab[4])
GUIEditor_Label[42] = guiCreateLabel(0.5394,0.5227,0.1307,0.043,"Deceleration",true,GUIEditor_Tab[4])
guiLabelSetColor(GUIEditor_Label[42],255,255,255)
guiLabelSetVerticalAlign(GUIEditor_Label[42],"top")
guiLabelSetHorizontalAlign(GUIEditor_Label[42],"left",false)
GUIEditor_Edit[64] = guiCreateEdit(0.6616,0.5179,0.1256,0.0501,"-0.008",true,GUIEditor_Tab[4])
GUIEditor_Label[43] = guiCreateLabel(0.0134,0.5179,0.1206,0.043,"Max. speed",true,GUIEditor_Tab[4])
guiLabelSetColor(GUIEditor_Label[43],255,255,255)
guiLabelSetVerticalAlign(GUIEditor_Label[43],"top")
guiLabelSetHorizontalAlign(GUIEditor_Label[43],"left",false)
GUIEditor_Edit[65] = guiCreateEdit(0.129,0.5179,0.1139,0.0477,"1",true,GUIEditor_Tab[4])
GUIEditor_Label[44] = guiCreateLabel(0.268,0.5251,0.129,0.0382,"Min. speed",true,GUIEditor_Tab[4])
guiLabelSetColor(GUIEditor_Label[44],255,255,255)
guiLabelSetVerticalAlign(GUIEditor_Label[44],"top")
guiLabelSetHorizontalAlign(GUIEditor_Label[44],"left",false)
GUIEditor_Edit[66] = guiCreateEdit(0.392,0.5203,0.1256,0.0477,"0",true,GUIEditor_Tab[4])
GUIEditor_Label[45] = guiCreateLabel(0.139,0.0716,0.139,0.0501,"Init angle(deg)",true,GUIEditor_Tab[4])
guiLabelSetColor(GUIEditor_Label[45],255,255,255)
guiLabelSetVerticalAlign(GUIEditor_Label[45],"top")
guiLabelSetHorizontalAlign(GUIEditor_Label[45],"left",false)
GUIEditor_Label[46] = guiCreateLabel(0.2931,0.074,0.0955,0.0382,"Rotate",true,GUIEditor_Tab[4])
guiLabelSetColor(GUIEditor_Label[46],255,255,255)
guiLabelSetVerticalAlign(GUIEditor_Label[46],"top")
guiLabelSetHorizontalAlign(GUIEditor_Label[46],"left",false)
GUIEditor_Label[47] = guiCreateLabel(0.3987,0.0716,0.1139,0.0382,"Acceleration",true,GUIEditor_Tab[4])
guiLabelSetColor(GUIEditor_Label[47],255,255,255)
guiLabelSetVerticalAlign(GUIEditor_Label[47],"top")
guiLabelSetHorizontalAlign(GUIEditor_Label[47],"left",false)
GUIEditor_Label[48] = guiCreateLabel(0.5176,0.0716,0.1424,0.0358,"Deceleration",true,GUIEditor_Tab[4])
guiLabelSetColor(GUIEditor_Label[48],255,255,255)
guiLabelSetVerticalAlign(GUIEditor_Label[48],"top")
guiLabelSetHorizontalAlign(GUIEditor_Label[48],"left",false)
GUIEditor_Label[49] = guiCreateLabel(0.6566,0.0334,0.0536,0.074,"Init\nspeed",true,GUIEditor_Tab[4])
guiLabelSetColor(GUIEditor_Label[49],255,255,255)
guiLabelSetVerticalAlign(GUIEditor_Label[49],"top")
guiLabelSetHorizontalAlign(GUIEditor_Label[49],"left",false)
GUIEditor_Label[50] = guiCreateLabel(0.727,0.0573,0.0988,0.0716,"Max spd",true,GUIEditor_Tab[4])
guiLabelSetColor(GUIEditor_Label[50],255,255,255)
guiLabelSetVerticalAlign(GUIEditor_Label[50],"top")
guiLabelSetHorizontalAlign(GUIEditor_Label[50],"left",false)
GUIEditor_Label[51] = guiCreateLabel(0.8107,0.0573,0.0888,0.0597,"Min spd",true,GUIEditor_Tab[4])
guiLabelSetColor(GUIEditor_Label[51],255,255,255)
guiLabelSetVerticalAlign(GUIEditor_Label[51],"top")
guiLabelSetHorizontalAlign(GUIEditor_Label[51],"left",false)
GUIEditor_Edit[67] = guiCreateEdit(0.1424,0.1169,0.0938,0.0477,"0",true,GUIEditor_Tab[4])
GUIEditor_Edit[68] = guiCreateEdit(0.2881,0.1169,0.0938,0.0477,"350",true,GUIEditor_Tab[4])
GUIEditor_Edit[69] = guiCreateEdit(0.4171,0.1169,0.0938,0.0477,"0.004",true,GUIEditor_Tab[4])
GUIEditor_Edit[70] = guiCreateEdit(0.5394,0.1169,0.0938,0.0477,"-0.008",true,GUIEditor_Tab[4])
GUIEditor_Edit[71] = guiCreateEdit(0.6482,0.1146,0.0754,0.0477,"0",true,GUIEditor_Tab[4])
GUIEditor_Edit[72] = guiCreateEdit(0.7286,0.1146,0.0787,0.0477,"1",true,GUIEditor_Tab[4])
GUIEditor_Edit[73] = guiCreateEdit(0.8107,0.1146,0.0787,0.0477,"0",true,GUIEditor_Tab[4])
GUIEditor_Edit[74] = guiCreateEdit(0.1424,0.1814,0.0938,0.0477,"0",true,GUIEditor_Tab[4])
GUIEditor_Edit[75] = guiCreateEdit(0.2864,0.179,0.0938,0.0477,"60",true,GUIEditor_Tab[4])
GUIEditor_Edit[76] = guiCreateEdit(0.4171,0.179,0.0938,0.0477,"0.004",true,GUIEditor_Tab[4])
GUIEditor_Edit[77] = guiCreateEdit(0.541,0.179,0.0938,0.0477,"-0.008",true,GUIEditor_Tab[4])
GUIEditor_Edit[78] = guiCreateEdit(0.6499,0.179,0.0754,0.0477,"0",true,GUIEditor_Tab[4])
GUIEditor_Edit[79] = guiCreateEdit(0.7303,0.179,0.0787,0.0477,"0.05",true,GUIEditor_Tab[4])
GUIEditor_Edit[80] = guiCreateEdit(0.8124,0.179,0.0787,0.0477,"0",true,GUIEditor_Tab[4])
GUIEditor_Label[52] = guiCreateLabel(0.134,0.2315,0.139,0.0501,"Init value",true,GUIEditor_Tab[4])
guiLabelSetColor(GUIEditor_Label[52],255,255,255)
guiLabelSetVerticalAlign(GUIEditor_Label[52],"top")
guiLabelSetHorizontalAlign(GUIEditor_Label[52],"left",false)
GUIEditor_Edit[81] = guiCreateEdit(0.1407,0.2721,0.0938,0.0477,"0",true,GUIEditor_Tab[4])
GUIEditor_Edit[82] = guiCreateEdit(0.2848,0.2721,0.0938,0.0477,"60",true,GUIEditor_Tab[4])
GUIEditor_Edit[83] = guiCreateEdit(0.4171,0.2721,0.0938,0.0477,"0.002",true,GUIEditor_Tab[4])
GUIEditor_Edit[84] = guiCreateEdit(0.541,0.2721,0.0938,0.0477,"-0.01",true,GUIEditor_Tab[4])
GUIEditor_Edit[85] = guiCreateEdit(0.6482,0.2721,0.0754,0.0477,"0",true,GUIEditor_Tab[4])
GUIEditor_Edit[86] = guiCreateEdit(0.7286,0.2721,0.0787,0.0477,"0.05",true,GUIEditor_Tab[4])
GUIEditor_Edit[87] = guiCreateEdit(0.809,0.2721,0.0787,0.0477,"0",true,GUIEditor_Tab[4])
GUIEditor_Label[53] = guiCreateLabel(0.4992,0.6611,0.1809,0.0501,"strafe pos",true,GUIEditor_Tab[4])
guiLabelSetColor(GUIEditor_Label[53],255,255,255)
guiLabelSetVerticalAlign(GUIEditor_Label[53],"top")
guiLabelSetHorizontalAlign(GUIEditor_Label[53],"left",false)
GUIEditor_Edit[88] = guiCreateEdit(0.6332,0.6635,0.0821,0.0477,"0.004",true,GUIEditor_Tab[4])
GUIEditor_Label[54] = guiCreateLabel(0.5008,0.716,0.124,0.0501,"move pos",true,GUIEditor_Tab[4])
guiLabelSetColor(GUIEditor_Label[54],255,255,255)
guiLabelSetVerticalAlign(GUIEditor_Label[54],"top")
guiLabelSetHorizontalAlign(GUIEditor_Label[54],"left",false)
GUIEditor_Label[55] = guiCreateLabel(0.6348,0.6253,0.0553,0.0334,"accel",true,GUIEditor_Tab[4])
guiLabelSetColor(GUIEditor_Label[55],255,255,255)
guiLabelSetVerticalAlign(GUIEditor_Label[55],"top")
guiLabelSetHorizontalAlign(GUIEditor_Label[55],"left",false)
GUIEditor_Label[56] = guiCreateLabel(0.7219,0.6253,0.0553,0.0334,"decel",true,GUIEditor_Tab[4])
guiLabelSetColor(GUIEditor_Label[56],255,255,255)
guiLabelSetVerticalAlign(GUIEditor_Label[56],"top")
guiLabelSetHorizontalAlign(GUIEditor_Label[56],"left",false)
GUIEditor_Edit[89] = guiCreateEdit(0.7169,0.6635,0.0821,0.0477,"-0.008",true,GUIEditor_Tab[4])
GUIEditor_Edit[90] = guiCreateEdit(0.799,0.6635,0.0821,0.0477,"1",true,GUIEditor_Tab[4])
GUIEditor_Edit[91] = guiCreateEdit(0.8811,0.6635,0.0821,0.0477,"-1",true,GUIEditor_Tab[4])
GUIEditor_Label[57] = guiCreateLabel(0.8007,0.6181,0.0754,0.0406,"max spd",true,GUIEditor_Tab[4])
guiLabelSetColor(GUIEditor_Label[57],255,255,255)
guiLabelSetVerticalAlign(GUIEditor_Label[57],"top")
guiLabelSetHorizontalAlign(GUIEditor_Label[57],"left",false)
GUIEditor_Label[58] = guiCreateLabel(0.8861,0.6134,0.0737,0.0358,"min spd",true,GUIEditor_Tab[4])
guiLabelSetColor(GUIEditor_Label[58],255,255,255)
guiLabelSetVerticalAlign(GUIEditor_Label[58],"top")
guiLabelSetHorizontalAlign(GUIEditor_Label[58],"left",false)
GUIEditor_Label[59] = guiCreateLabel(0.5008,0.7637,0.1273,0.0501,"rotate",true,GUIEditor_Tab[4])
guiLabelSetColor(GUIEditor_Label[59],255,255,255)
guiLabelSetVerticalAlign(GUIEditor_Label[59],"top")
guiLabelSetHorizontalAlign(GUIEditor_Label[59],"left",false)
GUIEditor_Edit[92] = guiCreateEdit(0.6332,0.7136,0.0821,0.0477,"0.004",true,GUIEditor_Tab[4])
GUIEditor_Edit[93] = guiCreateEdit(0.7169,0.7136,0.0821,0.0477,"-0.008",true,GUIEditor_Tab[4])
GUIEditor_Edit[94] = guiCreateEdit(0.799,0.7136,0.0821,0.0477,"1",true,GUIEditor_Tab[4])
GUIEditor_Edit[95] = guiCreateEdit(0.8811,0.7136,0.0821,0.0477,"-1",true,GUIEditor_Tab[4])
GUIEditor_Edit[96] = guiCreateEdit(0.6348,0.7613,0.0821,0.0477,"0.003",true,GUIEditor_Tab[4])
GUIEditor_Edit[97] = guiCreateEdit(0.7186,0.7613,0.0821,0.0477,"-0.002",true,GUIEditor_Tab[4])
GUIEditor_Edit[98] = guiCreateEdit(0.8007,0.7613,0.0821,0.0477,"0.05",true,GUIEditor_Tab[4])
GUIEditor_Edit[99] = guiCreateEdit(0.8827,0.7613,0.0821,0.0477,"-0.05",true,GUIEditor_Tab[4])
GUIEditor_Label[60] = guiCreateLabel(0.4992,0.8138,0.1273,0.0501,"pitch",true,GUIEditor_Tab[4])
guiLabelSetColor(GUIEditor_Label[60],255,255,255)
guiLabelSetVerticalAlign(GUIEditor_Label[60],"top")
guiLabelSetHorizontalAlign(GUIEditor_Label[60],"left",false)
GUIEditor_Edit[100] = guiCreateEdit(0.6348,0.8091,0.0821,0.0477,"0.003",true,GUIEditor_Tab[4])
GUIEditor_Edit[101] = guiCreateEdit(0.7186,0.8091,0.0821,0.0477,"-0.002",true,GUIEditor_Tab[4])
GUIEditor_Edit[102] = guiCreateEdit(0.8007,0.8091,0.0821,0.0477,"0.05",true,GUIEditor_Tab[4])
GUIEditor_Edit[103] = guiCreateEdit(0.8827,0.8091,0.0821,0.0477,"-0.05",true,GUIEditor_Tab[4])
GUIEditor_Label[61] = guiCreateLabel(0.4992,0.8926,0.1441,0.0382,"Shift multiply",true,GUIEditor_Tab[4])
guiLabelSetColor(GUIEditor_Label[61],255,255,255)
guiLabelSetVerticalAlign(GUIEditor_Label[61],"top")
guiLabelSetHorizontalAlign(GUIEditor_Label[61],"left",false)
GUIEditor_Edit[104] = guiCreateEdit(0.6298,0.8902,0.0821,0.0477,"5.0",true,GUIEditor_Tab[4])
GUIEditor_Button[8] = guiCreateButton(0.5427,0.3914,0.0318,0.0453,"c",true,GUIEditor_Tab[4])
GUIEditor_Button[9] = guiCreateButton(0.8693,0.8735,0.0938,0.043,"as pos",true,GUIEditor_Tab[4])
GUIEditor_Tab[5] = guiCreateTab("Roll and FOV",GUIEditor_TabPanel[1])
GUIEditor_Label[62] = guiCreateLabel(0.0168,0.0286,0.1709,0.0382,"Roll",true,GUIEditor_Tab[5])
guiLabelSetColor(GUIEditor_Label[62],255,127,39)
guiLabelSetVerticalAlign(GUIEditor_Label[62],"top")
guiLabelSetHorizontalAlign(GUIEditor_Label[62],"left",false)
guiSetFont(GUIEditor_Label[62],"default-bold-small")
GUIEditor_Label[63] = guiCreateLabel(0.0168,0.0955,0.0905,0.0382,"Init value",true,GUIEditor_Tab[5])
guiLabelSetColor(GUIEditor_Label[63],255,255,255)
guiLabelSetVerticalAlign(GUIEditor_Label[63],"top")
guiLabelSetHorizontalAlign(GUIEditor_Label[63],"left",false)
GUIEditor_Edit[105] = guiCreateEdit(0.1441,0.0907,0.1441,0.0549,"0",true,GUIEditor_Tab[5])
GUIEditor_Label[64] = guiCreateLabel(0.0168,0.2554,0.1156,0.0406,"Acceleration",true,GUIEditor_Tab[5])
guiLabelSetColor(GUIEditor_Label[64],255,255,255)
guiLabelSetVerticalAlign(GUIEditor_Label[64],"top")
guiLabelSetHorizontalAlign(GUIEditor_Label[64],"left",false)
GUIEditor_Edit[106] = guiCreateEdit(0.1474,0.2482,0.1441,0.0549,"0.005",true,GUIEditor_Tab[5])
GUIEditor_Edit[107] = guiCreateEdit(0.4472,0.0931,0.1441,0.0549,"0",true,GUIEditor_Tab[5])
GUIEditor_Label[65] = guiCreateLabel(0.0168,0.3413,0.1173,0.0453,"Deceleration",true,GUIEditor_Tab[5])
guiLabelSetColor(GUIEditor_Label[65],255,255,255)
guiLabelSetVerticalAlign(GUIEditor_Label[65],"top")
guiLabelSetHorizontalAlign(GUIEditor_Label[65],"left",false)
GUIEditor_Edit[108] = guiCreateEdit(0.4456,0.1695,0.1441,0.0549,"0",true,GUIEditor_Tab[5])
GUIEditor_Label[66] = guiCreateLabel(0.6315,0.0907,0.0988,0.043,"Max Value",true,GUIEditor_Tab[5])
guiLabelSetColor(GUIEditor_Label[66],255,255,255)
guiLabelSetVerticalAlign(GUIEditor_Label[66],"top")
guiLabelSetHorizontalAlign(GUIEditor_Label[66],"left",false)
GUIEditor_Label[67] = guiCreateLabel(0.6348,0.1742,0.0905,0.0406,"Min Value",true,GUIEditor_Tab[5])
guiLabelSetColor(GUIEditor_Label[67],255,255,255)
guiLabelSetVerticalAlign(GUIEditor_Label[67],"top")
guiLabelSetHorizontalAlign(GUIEditor_Label[67],"left",false)
GUIEditor_Edit[109] = guiCreateEdit(0.737,0.0835,0.1441,0.0549,"45",true,GUIEditor_Tab[5])
GUIEditor_Edit[110] = guiCreateEdit(0.737,0.1623,0.1441,0.0549,"-45",true,GUIEditor_Tab[5])
GUIEditor_Label[68] = guiCreateLabel(0.0151,0.4558,0.1843,0.0573,"FOV",true,GUIEditor_Tab[5])
guiLabelSetColor(GUIEditor_Label[68],255,127,39)
guiLabelSetVerticalAlign(GUIEditor_Label[68],"top")
guiLabelSetHorizontalAlign(GUIEditor_Label[68],"left",false)
guiSetFont(GUIEditor_Label[68],"default-bold-small")
GUIEditor_Label[69] = guiCreateLabel(0.0151,0.5298,0.0905,0.0382,"Init value",true,GUIEditor_Tab[5])
guiLabelSetColor(GUIEditor_Label[69],255,255,255)
guiLabelSetVerticalAlign(GUIEditor_Label[69],"top")
guiLabelSetHorizontalAlign(GUIEditor_Label[69],"left",false)
GUIEditor_Edit[111] = guiCreateEdit(0.139,0.5227,0.1441,0.0549,"70",true,GUIEditor_Tab[5])
GUIEditor_Label[70] = guiCreateLabel(0.0151,0.6778,0.1156,0.0406,"Acceleration",true,GUIEditor_Tab[5])
guiLabelSetColor(GUIEditor_Label[70],255,255,255)
guiLabelSetVerticalAlign(GUIEditor_Label[70],"top")
guiLabelSetHorizontalAlign(GUIEditor_Label[70],"left",false)
GUIEditor_Edit[112] = guiCreateEdit(0.1407,0.6754,0.1441,0.0549,"0.005",true,GUIEditor_Tab[5])
GUIEditor_Label[71] = guiCreateLabel(0.3384,0.5227,0.0938,0.0382,"Init speed",true,GUIEditor_Tab[5])
guiLabelSetColor(GUIEditor_Label[71],255,255,255)
guiLabelSetVerticalAlign(GUIEditor_Label[71],"top")
guiLabelSetHorizontalAlign(GUIEditor_Label[71],"left",false)
GUIEditor_Edit[113] = guiCreateEdit(0.4439,0.5107,0.1441,0.0549,"0",true,GUIEditor_Tab[5])
GUIEditor_Label[72] = guiCreateLabel(0.0151,0.7566,0.1173,0.0453,"Deceleration",true,GUIEditor_Tab[5])
guiLabelSetColor(GUIEditor_Label[72],255,255,255)
guiLabelSetVerticalAlign(GUIEditor_Label[72],"top")
guiLabelSetHorizontalAlign(GUIEditor_Label[72],"left",false)
GUIEditor_Edit[114] = guiCreateEdit(0.1424,0.7566,0.1441,0.0549,"-0.01",true,GUIEditor_Tab[5])
GUIEditor_Label[73] = guiCreateLabel(0.6281,0.5131,0.0988,0.043,"Max Value",true,GUIEditor_Tab[5])
guiLabelSetColor(GUIEditor_Label[73],255,255,255)
guiLabelSetVerticalAlign(GUIEditor_Label[73],"top")
guiLabelSetHorizontalAlign(GUIEditor_Label[73],"left",false)
GUIEditor_Label[74] = guiCreateLabel(0.6298,0.5967,0.0905,0.0406,"Min Value",true,GUIEditor_Tab[5])
guiLabelSetColor(GUIEditor_Label[74],255,255,255)
guiLabelSetVerticalAlign(GUIEditor_Label[74],"top")
guiLabelSetHorizontalAlign(GUIEditor_Label[74],"left",false)
GUIEditor_Edit[115] = guiCreateEdit(0.7353,0.5036,0.1441,0.0549,"110",true,GUIEditor_Tab[5])
GUIEditor_Edit[116] = guiCreateEdit(0.7337,0.5895,0.1441,0.0549,"0.05",true,GUIEditor_Tab[5])
GUIEditor_Checkbox[1] = guiCreateCheckBox(0.6348,0.2267,0.2412,0.0525,"not fix(allow rotation)",false,true,GUIEditor_Tab[5])
GUIEditor_Edit[117] = guiCreateEdit(0.4439,0.599,0.1441,0.0549,"0",true,GUIEditor_Tab[5])
GUIEditor_Edit[118] = guiCreateEdit(0.1491,0.3365,0.1441,0.0549,"-0.01",true,GUIEditor_Tab[5])
GUIEditor_Label[75] = guiCreateLabel(0.3149,0.1623,0.129,0.0764,"Const Speed\n(0 - disabled)",true,GUIEditor_Tab[5])
guiLabelSetColor(GUIEditor_Label[75],255,255,255)
guiLabelSetVerticalAlign(GUIEditor_Label[75],"top")
guiLabelSetHorizontalAlign(GUIEditor_Label[75],"left",false)
GUIEditor_Label[76] = guiCreateLabel(0.0168,0.6205,0.0787,0.043,"Manual",true,GUIEditor_Tab[5])
guiLabelSetColor(GUIEditor_Label[76],100,255,100)
guiLabelSetVerticalAlign(GUIEditor_Label[76],"top")
guiLabelSetHorizontalAlign(GUIEditor_Label[76],"left",false)
guiSetFont(GUIEditor_Label[76],"default-bold-small")
GUIEditor_Label[77] = guiCreateLabel(0.0168,0.1981,0.0737,0.0358,"Manual",true,GUIEditor_Tab[5])
guiLabelSetColor(GUIEditor_Label[77],100,255,100)
guiLabelSetVerticalAlign(GUIEditor_Label[77],"top")
guiLabelSetHorizontalAlign(GUIEditor_Label[77],"left",false)
guiSetFont(GUIEditor_Label[77],"default-bold-small")
GUIEditor_Label[78] = guiCreateLabel(0.3233,0.2554,0.1156,0.0406,"Max speed",true,GUIEditor_Tab[5])
guiLabelSetColor(GUIEditor_Label[78],255,255,255)
guiLabelSetVerticalAlign(GUIEditor_Label[78],"top")
guiLabelSetHorizontalAlign(GUIEditor_Label[78],"left",false)
GUIEditor_Edit[119] = guiCreateEdit(0.4456,0.2458,0.1441,0.0549,"1.0",true,GUIEditor_Tab[5])
GUIEditor_Label[79] = guiCreateLabel(0.3266,0.3484,0.1156,0.0406,"Min speed",true,GUIEditor_Tab[5])
guiLabelSetColor(GUIEditor_Label[79],255,255,255)
guiLabelSetVerticalAlign(GUIEditor_Label[79],"top")
guiLabelSetHorizontalAlign(GUIEditor_Label[79],"left",false)
GUIEditor_Edit[120] = guiCreateEdit(0.4472,0.3294,0.1441,0.0549,"-1.0",true,GUIEditor_Tab[5])
GUIEditor_Label[80] = guiCreateLabel(0.3216,0.6874,0.1156,0.0406,"Max speed",true,GUIEditor_Tab[5])
guiLabelSetColor(GUIEditor_Label[80],255,255,255)
guiLabelSetVerticalAlign(GUIEditor_Label[80],"top")
guiLabelSetHorizontalAlign(GUIEditor_Label[80],"left",false)
GUIEditor_Edit[121] = guiCreateEdit(0.4439,0.6778,0.1441,0.0549,"1.0",true,GUIEditor_Tab[5])
GUIEditor_Label[81] = guiCreateLabel(0.3199,0.7589,0.1156,0.0406,"Min speed",true,GUIEditor_Tab[5])
guiLabelSetColor(GUIEditor_Label[81],255,255,255)
guiLabelSetVerticalAlign(GUIEditor_Label[81],"top")
guiLabelSetHorizontalAlign(GUIEditor_Label[81],"left",false)
GUIEditor_Edit[122] = guiCreateEdit(0.4439,0.7566,0.1441,0.0549,"-1.0",true,GUIEditor_Tab[5])
GUIEditor_Label[82] = guiCreateLabel(0.3116,0.5871,0.129,0.0764,"Const Speed\n(0 - disabled)",true,GUIEditor_Tab[5])
guiLabelSetColor(GUIEditor_Label[82],255,255,255)
guiLabelSetVerticalAlign(GUIEditor_Label[82],"top")
guiLabelSetHorizontalAlign(GUIEditor_Label[82],"left",false)
GUIEditor_Label[83] = guiCreateLabel(0.3283,0.0979,0.0938,0.0382,"Init speed",true,GUIEditor_Tab[5])
guiLabelSetColor(GUIEditor_Label[83],255,255,255)
guiLabelSetVerticalAlign(GUIEditor_Label[83],"top")
guiLabelSetHorizontalAlign(GUIEditor_Label[83],"left",false)
GUIEditor_Checkbox[2] = guiCreateCheckBox(0.1223,0.6086,0.1558,0.0573,"enable",false,true,GUIEditor_Tab[5])
guiCheckBoxSetSelected(GUIEditor_Checkbox[2],true)
GUIEditor_Checkbox[3] = guiCreateCheckBox(0.129,0.1862,0.1558,0.0573,"enable",false,true,GUIEditor_Tab[5])
guiCheckBoxSetSelected(GUIEditor_Checkbox[3],true)
GUIEditor_Label[84] = guiCreateLabel(0.0286,0.9064,0.2317,0.0356,"Hotkey(in director mode):",true,GUIEditor_Window[1])
guiLabelSetColor(GUIEditor_Label[84],255,255,255)
guiLabelSetVerticalAlign(GUIEditor_Label[84],"top")
guiLabelSetHorizontalAlign(GUIEditor_Label[84],"left",false)
GUIEditor_Edit[123] = guiCreateEdit(0.0952,0.9419,0.0905,0.0356,"",true,GUIEditor_Window[1])
GUIEditor_Label[85] = guiCreateLabel(0.0111,0.9419,0.054,0.0375,"(2-9)",true,GUIEditor_Window[1])
guiLabelSetColor(GUIEditor_Label[85],255,255,255)
guiLabelSetVerticalAlign(GUIEditor_Label[85],"top")
guiLabelSetHorizontalAlign(GUIEditor_Label[85],"left",false)
GUIEditor_Button[10] = guiCreateButton(0.2635,0.8914,0.1095,0.0449,"Load",true,GUIEditor_Window[1])
GUIEditor_Button[11] = guiCreateButton(0.2603,0.9419,0.1111,0.0412,"Set",true,GUIEditor_Window[1])
GUIEditor_Button[12] = guiCreateButton(0.8143,0.9139,0.1508,0.0655,"Close",true,GUIEditor_Window[1])
GUIEditor_Button[13] = guiCreateButton(0.6111,0.9157,0.1667,0.0655,"Test Camera!",true,GUIEditor_Window[1])
GUIEditor_Label[86] = guiCreateLabel(0.3794,0.9476,0.227,0.0262,"<-- Save camera settings",true,GUIEditor_Window[1])
guiLabelSetColor(GUIEditor_Label[86],255,255,255)
guiLabelSetVerticalAlign(GUIEditor_Label[86],"top")
guiLabelSetHorizontalAlign(GUIEditor_Label[86],"left",false)
GUIEditor_Label[87] = guiCreateLabel(0.3841,0.8989,0.2222,0.0281,"Current cam ID: <none>",true,GUIEditor_Window[1])
guiLabelSetColor(GUIEditor_Label[87],255,255,255)
guiLabelSetVerticalAlign(GUIEditor_Label[87],"top")
guiLabelSetHorizontalAlign(GUIEditor_Label[87],"left",false)
guiSetFont(GUIEditor_Label[87],"default-bold-small")

GUIEditor_Window["help"] = guiCreateWindow(192,123,448,464,"Help Window",false)
GUIEditor_Label["help"] = guiCreateLabel(0.0335,0.0647,0.9708,0.9711,"Actor mode\n\n"..
 "O - Start/Stop Record Player Motion\nI - Reset Scene\nP - Playback Record\nF3 - show/hide Timer\nF4 - show/hide HUD\nF5 Free cam\nF1 - freeroam menu for weapons animations etc.\n"..
 "- - Reset Current Player Animation\2-9 - Play Animation Hotkey\n K - kill ped\n= - Record Animation hotkey(2-0) Animation select in FreeRoam\n\nConsole commands\n"..
 "sens /sensX/sensY - mouse sensivity\nmap <mapname> - set <mapname> resource as current map\n dd <numeric value> - experimental parameter. May improve car movement\n           (must be -50/+50 default 15)\n"..
 "\n Director Menu  - F6\n"..
 "\F7 - Camera menu\nI - Reset Scene\nP - Playback Record\n\n"..
 "Camera Free mode key control:\n"..
 "W/S - move to Target\nA/D - Rotation around Target\n Arrow Keys - move camera\n"..
 "Mouse Look - rotate Target(if not fixed) around Position\nMouse Look + LMB - rotate Position(if not fixed) around Target\n"..
 "Space - Pitch camera (relative Target)\n 2-9 - Apply Camera Preset (saved on F7 menu)\n"..
 "- - Reset Camera\n = - Freeze camera\n\n\n For easy car reset - make map in Map editor resource and load it with 'map' console command",true,GUIEditor_Window["help"])
guiLabelSetColor(GUIEditor_Label["help"],255,255,255)
guiLabelSetVerticalAlign(GUIEditor_Label["help"],"top")
guiLabelSetHorizontalAlign(GUIEditor_Label["help"],"left",false)
guiSetFont(GUIEditor_Label["help"],"default-small")
--GUIEditor_Button["help"] = guiCreateButton(0.7076,0.9138,0.2321,0.0647,"Close",true,GUIEditor_Window["help"])

--- --- --- ---

smenu = guiCreateWindow(419,72,287,428,"Stage Menu",false)
srec = guiCreateButton(0.6829,0.8178,0.2474,0.1425,"Rec",true,smenu)
splay = guiCreateButton(0.0662,0.8248,0.2544,0.1355,"Play",true,smenu)
sstop = guiCreateButton(0.3728,0.8178,0.2544,0.1425,"Stop",true,smenu)
sreset = guiCreateButton(0.3798,0.7266,0.2404,0.0771,"Reset scene",true,smenu)
sclear = guiCreateButton(0.7735,0.5491,0.1498,0.0678,"Clear Scene",true,smenu)
sllogin = guiCreateLabel(0.0523,0.0537,0.3902,0.0421,"Logged as: actor",true,smenu)
guiLabelSetColor(sllogin,255,255,255)
guiLabelSetVerticalAlign(sllogin,"top")
guiLabelSetHorizontalAlign(sllogin,"left",false)
sswitch = guiCreateButton(0.669,0.0724,0.2753,0.0864,"switch to director mode",true,smenu)
squal = guiCreateButton(0.0697,0.5444,0.561,0.0514,"Movement quality settings",true,smenu)
skill = guiCreateButton(0.7735,0.6449,0.1498,0.0678,"Delete Ped",true,smenu)
slogin = guiCreateButton(0.439,0.0607,0.1254,0.0397,"login",true,smenu)
stimer = guiCreateCheckBox(0.0976,0.4206,0.5819,0.0467,"Show Timer",false,true,smenu)
guiCheckBoxSetSelected(stimer,true)
shud = guiCreateCheckBox(0.0976,0.472,0.5819,0.0467,"Show HUD",false,true,smenu)
guiCheckBoxSetSelected(shud,true)
skfrate = guiCreateCheckBox(0.6725,0.3785,0.2822,0.0771,"Show\nkframe qnt.",false,true,smenu)
guiCheckBoxSetSelected(skfrate,true)
ssnd = guiCreateCheckBox(0.676,0.4766,0.2857,0.0444,"Sounds",false,true,smenu)
guiCheckBoxSetSelected(ssnd,true)
scam = guiCreateButton(0.0697,0.1706,0.5645,0.0631,"Free Cam",true,smenu)
ssave = guiCreateButton(0.0732,0.2593,0.561,0.0561,"Save Scene",true,smenu)
sload = guiCreateButton(0.0732,0.3271,0.561,0.0561,"Load Scene",true,smenu)
sselmap = guiCreateButton(0.669,0.257,0.2822,0.0561,"Select map file",true,smenu)
smindur = guiCreateButton(0.0697,0.6028,0.561,0.0514,"Set Minute Duration",true,smenu)
sslim = guiCreateButton(0.0732,0.6612,0.561,0.0514,"Set Veh Speed Limiter",true,smenu)
--- --- --- --- ---
dlmenu = guiCreateWindow(236,241,365,115,"Director login. Enter Password",false)
dledit = guiCreateEdit(0.0521,0.2696,0.8822,0.2609,"",true,dlmenu)
dlok = guiCreateButton(0.6767,0.6174,0.2575,0.287,"Ok",true,dlmenu)
dlcancel = guiCreateButton(0.389,0.6261,0.2575,0.2696,"Cancel",true,dlmenu)
--- --- --- --- ---
smmenu = guiCreateWindow(236,241,365,115,"Enter map name. (Map resource must be started)",false)
smedit = guiCreateEdit(0.0521,0.2696,0.8822,0.2609,"",true,smmenu)
smok = guiCreateButton(0.6767,0.6174,0.2575,0.287,"Ok",true,smmenu)
smcancel = guiCreateButton(0.389,0.6261,0.2575,0.2696,"Cancel",true,smmenu)
--- --- --- --- ---
mdmenu = guiCreateWindow(236,241,365,115,"Set Minute Duration(takes effect on local player)",false)
mdedit = guiCreateEdit(0.0521,0.2696,0.8822,0.2609,"60000",true,mdmenu)
mdok = guiCreateButton(0.6767,0.6174,0.2575,0.287,"Ok",true,mdmenu)
mdcancel = guiCreateButton(0.389,0.6261,0.2575,0.2696,"Cancel",true,mdmenu)
--- --- --- --- ---
clmenu = guiCreateWindow(236,241,365,115,"Clear Scene",false)
cllabel = guiCreateLabel(0.0521,0.2696,0.8822,0.2609,"Are you sure?",true,clmenu)
clcancel = guiCreateButton(0.6767,0.6174,0.2575,0.287,"Cancel",true,clmenu)
clok = guiCreateButton(0.389,0.6261,0.2575,0.2696,"Ok",true,clmenu)
--- --- --- --- --- 
slmenu = guiCreateWindow(236,241,365,115,"Vehicle Speed Limiter",false)
sllabel = guiCreateLabel(0.0521,0.6696,0.8822,0.2609,"0 - disable",true,slmenu)
sledit1 = guiCreateEdit(0.0521,0.2696,0.8822,0.2609,"0.5",true,slmenu)
slok = guiCreateButton(0.6767,0.6174,0.2575,0.287,"Ok",true,slmenu)
slcancel = guiCreateButton(0.389,0.6261,0.2575,0.2696,"Cancel",true,slmenu)
--- --- --- --- --- 
qmenu = guiCreateWindow(267,38,338,485,"Player motion recording quality",false)
qmin = guiCreateRadioButton(0.0414,0.1773,0.8787,0.068,"Slow moving peds and vehicles\n(suitable for background citizens)",true,qmenu)
qmed = guiCreateRadioButton(0.0414,0.2412,0.8817,0.0557,"Medium quality (default)",true,qmenu)
guiRadioButtonSetSelected(qmed,true)
qhigh = guiCreateRadioButton(0.0414,0.2928,0.9053,0.0515,"High quality",true,qmenu)
qlab1 = guiCreateLabel(0.0533,0.0928,0.8284,0.0701,"Adaptive framerate (depends on object speed)\n          less memory usage",true,qmenu)
guiLabelSetColor(qlab1,255,255,255)
guiLabelSetVerticalAlign(qlab1,"top")
guiLabelSetHorizontalAlign(qlab1,"left",false)
qlab2 = guiCreateLabel(0.0444,0.5258,0.8698,0.0598,"Constant framerate (depends on FPS\nand frameskip rate). Large memory usage",true,qmenu)
guiLabelSetColor(qlab2,255,255,255)
guiLabelSetVerticalAlign(qlab2,"top")
guiLabelSetHorizontalAlign(qlab2,"left",false)
qfmin = guiCreateRadioButton(0.0621,0.5979,0.8728,0.0474,"For slow moving peds",true,qmenu)
qfmed = guiCreateRadioButton(0.0621,0.6536,0.7456,0.0454,"Medium",true,qmenu)
qfhigh = guiCreateRadioButton(0.0621,0.7031,0.6864,0.0495,"High",true,qmenu)
qfmax = guiCreateRadioButton(0.0651,0.7526,0.7692,0.0474,"Maximum (not recommended for crowd scene)",true,qmenu)
qman = guiCreateRadioButton(0.0444,0.3485,0.5858,0.0454,"Manual adaptive settings",true,qmenu)
qedit1 = guiCreateEdit(0.3166,0.4082,0.2189,0.0495,"1.5",true,qmenu)
qlab3 = guiCreateLabel(0.0385,0.4186,0.287,0.0392,"coord increment",true,qmenu)
guiLabelSetColor(qlab3,255,255,255)
guiLabelSetVerticalAlign(qlab3,"top")
guiLabelSetHorizontalAlign(qlab3,"left",false)
qedit2 = guiCreateEdit(0.3136,0.4598,0.2189,0.0495,"5",true,qmenu)
qlab4 = guiCreateLabel(0.0385,0.4577,0.2692,0.033,"angle increment",true,qmenu)
guiLabelSetColor(qlab4,255,255,255)
guiLabelSetVerticalAlign(qlab4,"top")
guiLabelSetHorizontalAlign(qlab4,"left",false)
qlab5 = guiCreateLabel(0.0355,0.3959,0.2544,0.0268,"on foot",true,qmenu)
guiLabelSetColor(qlab5,255,255,255)
guiLabelSetVerticalAlign(qlab5,"top")
guiLabelSetHorizontalAlign(qlab5,"left",false)
qedit3 = guiCreateEdit(0.5769,0.4082,0.213,0.0495,"3",true,qmenu)
qedit4 = guiCreateEdit(0.5769,0.4577,0.213,0.0495,"5",true,qmenu)
qlab6 = guiCreateLabel(0.5858,0.3711,0.287,0.0392,"veh",true,qmenu)
guiLabelSetColor(qlab6,255,255,255)
guiLabelSetVerticalAlign(qlab6,"top")
guiLabelSetHorizontalAlign(qlab6,"left",false)
qfman = guiCreateRadioButton(0.0651,0.8165,0.784,0.0392,"Manual",true,qmenu)
qlab7 = guiCreateLabel(0.0533,0.8784,0.3166,0.0289,"Save every",true,qmenu)
guiLabelSetColor(qlab7,255,255,255)
guiLabelSetVerticalAlign(qlab7,"top")
guiLabelSetHorizontalAlign(qlab7,"left",false)
qedit5 = guiCreateEdit(0.284,0.868,0.2426,0.0495,"5",true,qmenu)
qlab7 = guiCreateLabel(0.574,0.8804,0.1834,0.0351,"frame",true,qmenu)
guiLabelSetColor(qlab7,255,255,255)
guiLabelSetVerticalAlign(qlab7,"top")
guiLabelSetHorizontalAlign(qlab7,"left",false)
qcancel = guiCreateButton(0.7041,0.9299,0.2574,0.0454,"Cancel",true,qmenu)
qacc = guiCreateButton(0.4467,0.9299,0.2308,0.0474,"Accept",true,qmenu)
qlab9 = guiCreateLabel(0.0651,0.0454,0.5562,0.0351,"effect on all players",true,qmenu)
guiLabelSetColor(qlab9,255,255,255)
guiLabelSetVerticalAlign(qlab9,"top")
guiLabelSetHorizontalAlign(qlab9,"left",false)
guiSetFont(qlab9,"default-small")
--- --- --- --- ---
sdlmenu = guiCreateWindow(190,218,406,137,"Save movement data",false)
sdllab1 = guiCreateLabel(0.0567,0.1679,0.2488,0.1022,"Resource name:",true,sdlmenu)
guiLabelSetColor(sdllab1,255,255,255)
guiLabelSetVerticalAlign(sdllab1,"top")
guiLabelSetHorizontalAlign(sdllab1,"left",false)
sdllab2 = guiCreateLabel(0.0567,0.3869,0.2438,0.1095,"File name:",true,sdlmenu)
guiLabelSetColor(sdllab2,255,255,255)
guiLabelSetVerticalAlign(sdllab2,"top")
guiLabelSetHorizontalAlign(sdllab2,"left",false)
sdledit1 = guiCreateEdit(0.3079,0.1533,0.436,0.1898,"",true,sdlmenu)
sdledit2 = guiCreateEdit(0.3103,0.3577,0.436,0.1898,"",true,sdlmenu)
sdlsave = guiCreateButton(0.6847,0.6496,0.2266,0.2555,"Save",true,sdlmenu)
sdlcancel = guiCreateButton(0.4458,0.6496,0.2266,0.2555,"Cancel",true,sdlmenu)
sdlowr = guiCreateCheckBox(0.0542,0.7591,0.1995,0.1387,"overwrite",false,true,sdlmenu)
sdllab3 = guiCreateLabel(0.7635,0.1606,0.234,0.3577,"(optional)\nusefull to store\ndata in map res",true,sdlmenu)
guiLabelSetColor(sdllab3,255,255,255)
guiLabelSetVerticalAlign(sdllab3,"top")
guiLabelSetHorizontalAlign(sdllab3,"left",false)
guiSetFont(sdllab3,"default-small")

--- --- --- --- ---
odlmenu = guiCreateWindow(190,218,406,137,"Load movement data",false)
odllab1 = guiCreateLabel(0.0567,0.1679,0.2488,0.1022,"Resource name:",true,odlmenu)
guiLabelSetColor(odllab1,255,255,255)
guiLabelSetVerticalAlign(odllab1,"top")
guiLabelSetHorizontalAlign(odllab1,"left",false)
odllab2 = guiCreateLabel(0.0567,0.3869,0.2438,0.1095,"File name:",true,odlmenu)
guiLabelSetColor(odllab2,255,255,255)
guiLabelSetVerticalAlign(odllab2,"top")
guiLabelSetHorizontalAlign(odllab2,"left",false)
odledit1 = guiCreateEdit(0.3079,0.1533,0.436,0.1898,"",true,odlmenu)
odledit2 = guiCreateEdit(0.3103,0.3577,0.436,0.1898,"",true,odlmenu)
odlsave = guiCreateButton(0.6847,0.6496,0.2266,0.2555,"Load",true,odlmenu)
odlcancel = guiCreateButton(0.4458,0.6496,0.2266,0.2555,"Cancel",true,odlmenu)
odllab3 = guiCreateLabel(0.7635,0.1606,0.234,0.3577,"(NOTE: all unsaved\ndata will be lost)",true,odlmenu)
guiLabelSetColor(odllab3,255,255,255)
guiLabelSetVerticalAlign(odllab3,"top")
guiLabelSetHorizontalAlign(odllab3,"left",false)
guiSetFont(odllab3,"default-small")

--- --- --- --- ---
addEventHandler ( "onClientGUIClick",GUIEditor_Button[12], CamMenu , false)
addEventHandler ( "onClientGUIClick",GUIEditor_Button[2], InitAsCurrent , false)
addEventHandler ( "onClientGUIClick",GUIEditor_Button[13], CamTestStart , false)
addEventHandler ( "onClientGUIClick",GUIEditor_Button[1], StartObjSelection , false)
addEventHandler ( "onClientGUIClick",GUIEditor_Button[4], StartObjSelection , false)
addEventHandler ( "onClientGUIClick",GUIEditor_Button[11], SaveCam , false)
addEventHandler ( "onClientGUIClick",GUIEditor_Button[10], LoadCam , false)

addEventHandler ( "onClientGUIClick",slogin, ShowLogin, false)
addEventHandler ( "onClientGUIClick",dlcancel, EnterPass, false)
addEventHandler ( "onClientGUIClick",dlok, EnterPass, false)
addEventHandler( "onClientGUIAccepted", dledit, EnterPass, false)
addEventHandler ( "onClientGUIClick",sselmap, ShowMapSel, false)
addEventHandler ( "onClientGUIClick",smcancel, EnterMapName, false)
addEventHandler ( "onClientGUIClick",smok, EnterMapName, false)
addEventHandler( "onClientGUIAccepted", smedit, EnterMapName, false)
addEventHandler ( "onClientGUIClick",sswitch, Director, false)
addEventHandler ( "onClientGUIClick",scam, CamMenuShow, false)
addEventHandler ( "onClientGUIClick",smindur, MinDurShow, false)
addEventHandler ( "onClientGUIClick",mdcancel, EnterMinDur, false)
addEventHandler ( "onClientGUIClick",mdok, EnterMinDur, false)
addEventHandler( "onClientGUIAccepted", mdedit, EnterMinDur, false)
addEventHandler ( "onClientGUIClick",skill, Kill, false)
addEventHandler ( "onClientGUIClick",sclear, ClearMenuShow, false)
addEventHandler ( "onClientGUIClick",clok, EnterClearMenu, false)
addEventHandler ( "onClientGUIClick",clcancel, EnterClearMenu, false)
addEventHandler ( "onClientGUIClick",sreset, Reset, false)
addEventHandler ( "onClientGUIClick",srec, Rec, false)
addEventHandler ( "onClientGUIClick",splay, Play, false)
addEventHandler ( "onClientGUIClick",sstop, Stop, false)
addEventHandler ( "onClientGUIClick",squal, QualityMenu, false)
addEventHandler ( "onClientGUIClick",qacc, QualityMenuAccept, false)
addEventHandler ( "onClientGUIClick",qcancel, QualityMenuAccept, false)
addEventHandler ( "onClientGUIClick",ssave, SaveMenuShow, false)
addEventHandler ( "onClientGUIClick",sdlcancel, SaveMenuSend, false)
addEventHandler ( "onClientGUIClick",sdlsave, SaveMenuSend, false)
addEventHandler ( "onClientGUIClick",sload, LoadMenuShow, false)
addEventHandler ( "onClientGUIClick",odlcancel, LoadMenuSend, false)
addEventHandler ( "onClientGUIClick",odlsave, LoadMenuSend, false)
addEventHandler ( "onClientGUIClick",sslim, SLimiterMenu, false)
addEventHandler ( "onClientGUIClick",slok, SLimiterAccept, false)
addEventHandler ( "onClientGUIClick",slcancel, SLimiterAccept, false)
addEventHandler( "onClientGUIAccepted", sledit1, SLimiterAccept, false)

addEventHandler ( "onClientGUIClick", stimer, ShowTimerGUI, false)
addEventHandler ( "onClientGUIClick", shud, ShowHUDGUI, false)
addEventHandler ( "onClientGUIClick", skfrate, ShowKFrate, false)
addEventHandler ( "onClientGUIClick", ssnd, SoundsEnable, false)

addEventHandler( "onClientGUIClick",GUIEditor_Button[3],gp1,false)
addEventHandler( "onClientGUIClick",GUIEditor_Button[6],gp2,false)
addEventHandler( "onClientGUIClick",GUIEditor_Button[5],gt1,false)
addEventHandler( "onClientGUIClick",GUIEditor_Button[8],gt2,false)

addEventHandler( "onClientGUIClick",GUIEditor_Button[7],copy1,false)
addEventHandler( "onClientGUIClick",GUIEditor_Button[9],copy2,false)

guiSetVisible(GUIEditor_Window[1], false)
guiSetVisible(GUIEditor_Window["help"], false)
guiSetVisible(smenu, false)
guiSetVisible(dlmenu, false)
guiSetVisible(smmenu, false)
guiSetVisible(mdmenu, false)
guiSetVisible(clmenu, false)
guiSetVisible(qmenu, false)
guiSetVisible(sdlmenu, false)
guiSetVisible(odlmenu, false)
guiSetVisible(slmenu, false)
MenuButtonDisable(false)

end)