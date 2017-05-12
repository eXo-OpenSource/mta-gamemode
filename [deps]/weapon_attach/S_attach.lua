--	[ID] = {bone, x, y, z, rx, ry, rz, model, slot},
local weaponTable = {
	[22] = {14, 0.1, 0.11, -0.05, 180, 90, -90, 346, 2},
	[23] = {14, 0.1, 0.11, -0.05, 180, 90, -90, 347, 2},
	[24] = {14, 0.1, 0.11, -0.05, 180, 90, -90, 348, 2},
	[25] = {3, 0, -0.15, 0.245, 8, 90, 0, 349, 3},
	[26] = {13, -0.07, 0.11, -0.05, 180, 90, -90, 350, 3},
	[27] = {3, 0, -0.15, 0.245, 8, 90, 0, 351, 3},
	[28] = {14, 0.1, 0.11, -0.05, 180, 90, -90, 352, 4},
	[29] = {14, 0.1, 0.11, -0.05, 180, 90, -90, 353, 4},
	[30] = {3, 0.175, 0.2, 0.125, 180, 240, 5, 355, 5},
	[31] = {3, 0.175, 0.2, 0.125, 180, 240, 5, 356, 5},
	[32] = {14, 0.1, 0.11, -0.05, 180, 90, -90, 372, 4},
	[33] = {3, 0, -0.13, -0.245, -3, 270, 0, 357, 6},
	[34] = {3, 0, -0.13, -0.245, -3, 270, 0, 358, 6},
}

function createModel(player, weapon, state, slot)
	local x, y, z = getElementPosition(player)
	local r = getPedRotation(player)
	local dim = getElementDimension(player)
	local int = getElementInterior(player)
	
	if weaponTable[weapon] then
		local bone = weaponTable[weapon][1]
		local x = weaponTable[weapon][2]
		local y = weaponTable[weapon][3]
		local z = weaponTable[weapon][4]
		local rx = weaponTable[weapon][5]
		local ry = weaponTable[weapon][6]
		local rz = weaponTable[weapon][7]
		local objectID = weaponTable[weapon][8]
		local slotID = weaponTable[weapon][9]

		if state == 1 then
			if slot == slotID then
				if getElementData(player, "a:weapon:slot"..slot.."") then
					local objectSlot = getElementData(player, "a:weapon:slot"..slot.."")
					if isElement(objectSlot) then
						destroyElement(objectSlot) 
					end
				end
				
				local object = createObject(objectID, x, y, z)
				exports.bone_attach:attachElementToBone(object, player, bone, x, y, z, rx, ry, rz)
				setElementData(player, "a:weapon:slot"..slotID.."", object)
				setElementData(object, "a:weapon:id", weapon)
				setElementData(object, "a:weapon:slot"..slotID.."", player)
				setElementCollisionsEnabled(object, false)
				setElementInterior(object, int)
				setElementDimension(object, dim)

				local theVehicle = getPedOccupiedVehicle(player)
				
				if theVehicle then
					setElementAlpha(object, 0)
				end
			end
		elseif state == 0 then
			for i = 1, 12 do
				local object = getElementData(player, "a:weapon:slot"..i.."")
				if isElement(object) then
					local id = getElementData(object, "a:weapon:id")
					if id == weapon then
						destroyElement(object)
						setElementData(player, "a:weapon:slot"..getSlotFromWeapon(weapon).."", nil)
					end
				end
			end
		end
	end
end
addEvent("createWepObject", true)
addEventHandler("createWepObject", getRootElement(), createModel)

function destroyAll()
	for i = 1, 12 do
		local object = getElementData(source, "a:weapon:slot"..i.."")
		if isElement(object) then
			local id = getElementData(object, "a:weapon:id")
			if id then
				destroyElement(object)
				setElementData(source, "a:weapon:slot"..id.."", nil)
			end
		end
	end
end
addEvent("destroyWepObjects", true)
addEventHandler("destroyWepObjects", getRootElement(), destroyAll)

function alphaWepsVehicle(theVehicle, seat, jacked)
	for i = 1, 12 do
		local object = getElementData(source, "a:weapon:slot"..i.."")
		if isElement(object) then
			setElementAlpha(object, 0)
		end
	end
end
addEventHandler("onPlayerVehicleEnter", getRootElement(), alphaWepsVehicle)

function unalphaWepsVehicle(theVehicle, seat, jacked)
    for i = 1, 12 do
		local object = getElementData(source, "a:weapon:slot"..i.."")
		if isElement(object) then 
			setElementAlpha(object, 255)
		end
	end
end
addEventHandler("onPlayerVehicleExit", getRootElement(), unalphaWepsVehicle)