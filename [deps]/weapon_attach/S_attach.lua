for key, player in ipairs(getElementsByType("player")) do
	setElementData(player, "a:weaponIsConcealed",false)
end

local slotChecks =
{
	"W_A:w0",
	"W_A:w1",
	"W_A:w2",
	"W_A:w3",
	"W_A:w5",
	"W_A:w6",
	[10] = "W_A:w0"
}

--	[ID] = {bone, x, y, z, rx, ry, rz, model, slot},
local weaponTable = {
	[2] = {14, 0.1, 0.11, -0.05, 180, 90, -90, 333, 1},
	[3] = {14, 0.1, 0.11, -0.05, 180, 90, -90, 334, 1},
	[4] = {14, 0.1, 0.11, -0.05, 180, 90, -90, 335, 1},
	[5] = {14, 0.1, 0.11, -0.05, 180, 90, -90, 336, 1},
	[6] = {14, 0.1, 0.11, -0.05, 180, 90, -90, 337, 1},
	[10] = {14, 0.1, 0.11, -0.05, 180, 90, -90, 321, 10},
	[22] = {14, 0.1, 0.11, -0.05, 180, 90, -90, 346, 2},
	[23] = {14, 0.1, 0.11, -0.05, 180, 90, -90, 347, 2},
	[24] = {14, 0.1, 0.11, -0.05, 180, 90, -90, 348, 2},
	[25] = {3, 0, -0.15, 0.245, 8, 90, 0, 349, 3},
	[26] = {13, -0.07, 0.11, -0.05, 180, 90, -90, 350, 3},
	[27] = {3, 0, -0.15, 0.245, 8, 90, 0, 351, 3},
	[28] = {3, 0, -0.1, -0.13, 0, 90, 180, 352, 4},
	[29] = {14, 0.1, -0.07, 0.02, 180, 90, -140, 353, 4},
	[30] = {3, 0.175, 0.2, 0.125, 180, 240, 5, 355, 5},
	[31] = {3, 0.175, 0.24, 0.125, 180, 240, 5, 356, 5},
	[32] = {3, 0.19, -0.08, -0.12, 0, 60, 180, 372, 4},
	[33] = {3, 0, -0.18, -0.33, -3, 270, 0, 357, 6},
	[34] = {3, 0, -0.13, -0.245, -3, 270, 0, 358, 6},
}

local alternativeTable =
{
	[30] = {3, 0.1, -0.16, -0.25, -3, 288, 0, 355, 5},
	[31] = {3, 0.1, -0.16, -0.25, -3, 288, 0, 356, 5},
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
			local alternativeSlot4
			if weapon == 30 or weapon == 31 then
				alternativeSlot4 = getElementData(player,"W_A:alt_w5")
			end
			if alternativeSlot4 then
				bone = alternativeTable[weapon][1]
				x = alternativeTable[weapon][2]
				y = alternativeTable[weapon][3]
				z = alternativeTable[weapon][4]
				rx = alternativeTable[weapon][5]
				ry = alternativeTable[weapon][6]
				rz = alternativeTable[weapon][7]
				objectID = alternativeTable[weapon][8]
				slotID = alternativeTable[weapon][9]
			end
			local bIsEnabled
			if slotChecks[slot] and (Weapon ~= 32 and Weapon ~= 28) then
				bIsEnabled = getElementData(player,slotChecks[slot])
			elseif prevWeapon == 32 or prevWeapon == 28 then
				bIsEnabled = getElementData(player,"W_A:w4")
			end
			if weapon == 34 then bIsEnabled = true end
			if not bIsEnabled then
				return
			end
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
				if slot >= 3 and (weapon ~= 32 and weapon ~= 28) then
					if getElementData(player, "a:weaponIsConcealed") then
						setElementAlpha(object, 0)
						setObjectScale(object,0)
					end
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
			setObjectScale(object,0)
		end
	end
end
addEventHandler("onPlayerVehicleEnter", getRootElement(), alphaWepsVehicle)

function unalphaWepsVehicle(theVehicle, seat, jacked)
	local isConcealed = getElementData( source, "a:weaponIsConcealed")
	local weapon
	if not isConcealed then
		for i = 1, 12 do
			local object = getElementData(source, "a:weapon:slot"..i.."")
			if isElement(object) then
				setElementAlpha(object, 255)
				setObjectScale(object,1)
			else
				createModel(source, getPedWeapon(source, i ), 1, i)
			end
		end
	else
		for i = 1, 12 do
			local object = getElementData(source, "a:weapon:slot"..i.."")
			if isElement(object) then
				weapon = getElementData(object, "a:weapon:id")
				if i < 3 and ( weapon ~= 32 and weapon~=28) then
					setElementAlpha(object, 255)
					setObjectScale(object,1)
				end
			else
				if i < 3 and ( weapon ~= 32 and weapon~=28) then
					createModel(source, getPedWeapon(source, i ), 1, i)
				end
			end
		end
	end
end
addEventHandler("onPlayerVehicleExit", getRootElement(), unalphaWepsVehicle)

addEvent("onElementDimensionChange")
addEventHandler("onElementDimensionChange", root, function( dim )
	if source then
		if getElementType(source) == "player" then
			local wObj
			for i = 1, 12 do
				wObj =  getElementData(source, "a:weapon:slot"..i.."")
				if isElement(wObj) then
					setElementDimension(wObj, dim)
				end
			end
		end
	end
end)

addEvent("onElementInteriorChange")
addEventHandler("onElementInteriorChange", root, function( int )
	if source then
		if getElementType(source) == "player" then
			local wObj
			for i = 1, 12 do
				wObj =  getElementData(source, "a:weapon:slot"..i.."")
				if isElement(wObj) then
					setElementInterior(wObj, int)
				end
			end
		end
	end
end)

addEventHandler("onPlayerQuit", root, function(  )
	if source then
		if getElementType(source) == "player" then
			local wObj
			for i = 1, 12 do
				wObj =  getElementData(source, "a:weapon:slot"..i.."")
				if isElement(wObj) then
					destroyElement(wObj)
				end
			end
		end
	end
end)

addEvent("WeaponAttach:removeAllWeapons")
addEventHandler("WeaponAttach:removeAllWeapons", root, function()
	if source then
		for i = 1, 12 do
			local object = getElementData(source, "a:weapon:slot"..i.."")
			if isElement(object) then
				local id = getElementData(source, "a:weapon:id")
				destroyElement(object)
				setElementData(source, "a:weapon:slot"..i.."", nil)
			end
		end
	end
end)

addEvent("WeaponAttach:concealWeapons")
addEventHandler("WeaponAttach:concealWeapons", root , function()
	if source then
		if getElementType(source) == "player" then
			local wObj, weapon
			setElementData(source, "a:weaponIsConcealed", true)
			for i = 3, 12 do
				wObj =  getElementData(source, "a:weapon:slot"..i.."")
				if isElement(wObj) then
					weapon = getElementData(wObj, "a:weapon:id")
					if weapon ~= 32 and weapon ~= 28 then
						createModel(source, getPedWeapon(source, i ), 0, i)
						setElementData(source, "a:weapon:slot"..i.."", nil)
					end
				end
			end
		end
	end
end)

addEvent("WeaponAttach:unconcealWeapons")
addEventHandler("WeaponAttach:unconcealWeapons", root , function()
	if source then
		if getElementType(source) == "player" then
			setElementData(source, "a:weaponIsConcealed", false)
			local currentWeapon = getPedWeapon(source)
			local iWeapon
			if not getPedOccupiedVehicle(source) then
				for i = 1, 12 do
					iWeapon = getPedWeapon(source, i )
					if iWeapon ~= currentWeapon then
						createModel(source, iWeapon, 1, i)
					end
				end
			end
		end
	end
end)

addEvent("WeaponAttach:onWeaponGive")
addEventHandler("WeaponAttach:onWeaponGive", root, function( newWeapon, slot, force, obj)
	if source then
		if getElementType(source) == "player" then
			if newWeapon and slot then
				local wObj =  getElementData(source, "a:weapon:slot"..slot.."")
				local weapon
				if isElement(wObj) then
					weapon = getElementData(wObj, "a:weapon:id")
					createModel(source, weapon, 0, slot)
					setElementData(source, "a:weapon:slot"..slot.."", nil)
				end
				if not force then
					createModel(source, newWeapon, 1, slot)
				end
			end
		end
	end
end)

addEvent("WeaponAttach:onWeaponTake")
addEventHandler("WeaponAttach:onWeaponTake", root, function( takeWeaponID )
	if source then
		if getElementType(source) == "player" then
			if takeWeaponID then
				local slot = getSlotFromWeapon(takeWeaponID)
				if slot then
					createModel(source, takeWeaponID, 0, slot)
					setElementData(source, "a:weapon:slot"..slot.."", nil)
				end
			end
		end
	end
end)

addEvent("WeaponAttach:onInititate")
addEventHandler("WeaponAttach:onInititate", root, function()
	if source then
		if getElementType(source) == "player" then
			local weapon
			local currentWeapon = getPedWeapon( source )
			for i = 1, 12 do
				local weapon = getPedWeapon(source, i)
				if weapon then
					if weapon ~= currentWeapon then
						createModel(source, weapon, 1, i)
					end
				end
			end
		end
	end
end)
