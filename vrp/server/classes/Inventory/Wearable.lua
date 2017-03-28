-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Item/Wearable.lua
-- *  PURPOSE:     Wearable class
-- *
-- ****************************************************************************

--[[
1: head
2: neck
3: spine
4: pelvis
5: left clavicle
6: right clavicle
7: left shoulder
8: right shoulder
9: left elbow
10: right elbow
11: left hand
12: right hand
13: left hip
14: right hip
15: left knee
16: right knee
17: left ankle
18: right ankle
19: left foot
20: right foot
]]

Wearable = inherit ( Singleton )
local dumpFunc = function() end
local attachFunc = dumpFunc
local isAttach = dumpFunc
local detachFunc = dumpFunc

addEventHandler("onResourceStart", root, function( s) 
	if s == "bone_attach" then
		attachFunc = exports["bone_attach"].attachElementToBone
		isAttach = exports["bone_attach"].isElementAttachedToBone
		detachFunc = exports["bone_attach"].detachElementFromBone
	end
end)

function Wearable:constructor() 

end

function Wearable:destructor()

end

function Wearable:giveIntoPedHand( obj, ped, iHand )
	if obj then 
		if ped then
			if iHand == 1 or iHand == 2 then
				if not isAttach( obj ) then
					local val1 = getElementDimension( obj )
					local val2 = getElementDimension ( ped )
					local ibone = tonumber( "1"..iHand ) 
					if val1 ~= val2 then 
						setElementDimension( obj , val2 ) 
					end
					val1 = getElementInterior( obj )
					val2 = getElementInterior( ped )
					if val1 ~= val2 then 
						setElementInterior( obj, val2 )
					end
					attachFunc( obj, ped, ibone )
				end
			end
		end
	end
end

function Wearable:setOnPedHead( obj, ped )
	if obj then 
		if ped then
			if not isAttach( obj ) then
				local val1 = getElementDimension( obj )
				local val2 = getElementDimension ( ped )
				local ibone = 1 
				if val1 ~= val2 then 
					setElementDimension( obj , val2 ) 
				end
				val1 = getElementInterior( obj )
				val2 = getElementInterior( ped )
				if val1 ~= val2 then 
					setElementInterior( obj, val2 )
				end
				attachFunc( obj, ped, ibone )
			end
		end
	end
end

function Wearable:removeObj( obj )
	if obj then 
		detachFunc( obj )
	end
end
