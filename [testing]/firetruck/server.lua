local ladderRotateLeft = false
local ladderRotateRight = false
local ladderMoveUp = false
local ladderMoveDown = false
local ladderMoveOut = false
local ladderMoveIn = false

addCommandHandler("fw", function(player)
	truck = createVehicle(544, player:getPosition())
	warpPedIntoVehicle(player, truck)
	
	main = createObject(1932, truck:getPosition())
	
	--main:setCollisionsEnabled(false)
	main:attach(truck, 0, 0.5, 1.1)

	ladder1 = createObject(1931, truck:getPosition())
	--ladder1:setCollisionsEnabled(false)
	ladder1:attach(main, 0, 0, 0)
	
	ladder2 = createObject(1931, truck:getPosition())
	--ladder2:setCollisionsEnabled(false)
	ladder2:attach(ladder1, 0, -1.4, 0.2)
	ladder2:setScale(0.8)
	
	ladder3 = createObject(1931, truck:getPosition())
	--ladder3:setCollisionsEnabled(false)
	ladder3:attach(ladder2, 0, -1, 0.2)
	ladder3:setScale(0.6)
	
	truck:setData("main", main)
	truck:setData("ladder1", ladder1)
	truck:setData("ladder2", ladder2)
	truck:setData("ladder3", ladder3)

	bindKey ( player, "w", "both", ladderfunc, truck)
	bindKey ( player, "a", "both", ladderfunc, truck)
	bindKey ( player, "s", "both", ladderfunc, truck)
	bindKey ( player, "d", "both", ladderfunc, truck)
	bindKey ( player, "lctrl", "both", ladderfunc, truck)
	bindKey ( player, "lshift", "both", ladderfunc, truck)
	
	setTimer(doladderfunc, 50, 0)
end)

function ladderfunc(player, key, state)
	if key == "a" then
		ladderRotateLeft = state == "down" and true or false
	elseif key == "d" then
		ladderRotateRight = state == "down" and true or false
	elseif key == "w" then
		ladderMoveUp = state == "down" and true or false
	elseif key == "s" then
		ladderMoveDown = state == "down" and true or false
	elseif key == "lctrl" then
		ladderMoveIn = state == "down" and true or false
	elseif key == "lshift" then
		ladderMoveOut = state == "down" and true or false
	end
end

function doladderfunc()
	local x, y, z, rx, ry, rz = getElementAttachedOffsets(main)

	local x1, y1, z1, rx1, ry1, rz1 = getElementAttachedOffsets(ladder1)
	local x2, y2, z2, rx2, ry2, rz2 = getElementAttachedOffsets(ladder2)
	local x3, y3, z3, rx3, ry3, rz3 = getElementAttachedOffsets(ladder3)

	
	if ladderRotateRight then
		main:attach(truck, 0, 0.5, 1.1, rx, ry, rz+0.7)
	elseif ladderRotateLeft then
		main:attach(truck, 0, 0.5, 1.1, rx, ry, rz-0.7)
	elseif ladderMoveUp then
		if rx1 > -50 then
			ladder1:attach(main, x1, y1, z1, rx1-0.5, ry1, rz1)
			outputChatBox(rx1)
		end
	elseif ladderMoveDown then
		if rx1 < 0 then
			ladder1:attach(main, x1, y1, z1, rx1+0.5, ry1, rz1)
		end
	elseif ladderMoveIn then
		if y3 < -1.4 then
			ladder3:attach(ladder2, x3, y3+0.1, z3, rx3, ry3, rz3 )
		elseif y2 < -1.4 then	
			ladder2:attach(ladder1, x2, y2+0.1, z2, rx2, ry2, rz2)
		end
	elseif ladderMoveOut then
		if y2 > -5.5 then
			ladder2:attach(ladder1, x2, y2-0.1, z2, rx2, ry2, rz2)
		elseif y3 > -4.5 then
			ladder3:attach(ladder2, x3, y3-0.1, z3, rx3, ry3, rz3 )
		end
	end
end