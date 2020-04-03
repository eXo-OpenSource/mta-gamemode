local weaponsTable = {0 ,22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39}


addEventHandler("onClientPlayerWasted", localPlayer, function() 
	triggerServerEvent("HelicopterDriveBy:onClientWasted", localPlayer)
end)

function switchNextWeapon()
	progress = 1
	if not getElementData(localPlayer, "HeliGlue") then return end
	local currentWeapon = getPedWeapon( localPlayer )
	if currentWeapon == 1 then currentWeapon = 0 end
	local currentSlot = getPedWeaponSlot(localPlayer)
	local switchTo
	for key,weaponID in ipairs(weaponsTable) do
		if weaponID == currentWeapon then
			local i = key + progress
			while i ~= key do
				nextWeapon = weaponsTable[i]
				if nextWeapon then
					local slot = getSlotFromWeapon(nextWeapon)
					local weapon = getPedWeapon(localPlayer, slot)
					if ( weapon == nextWeapon  ) then
						switchToWeapon = weapon
						switchTo = slot
						break
					end
				end
				if not weaponsTable[i+progress] then
					if progress < 0 then
						i = #weaponsTable
					else
						i = 1
					end
				else
					i = i + progress
				end
			end
			break
		end
	end
	if not switchTo then return end
	setPedWeaponSlot(localPlayer, switchTo)
end

function switchPrevWeapon()
	progress = -1
	if not getElementData(localPlayer, "HeliGlue") then return end
	local currentWeapon = getPedWeapon( localPlayer )
	if currentWeapon == 1 then currentWeapon = 0 end
	local currentSlot = getPedWeaponSlot(localPlayer)
	local switchTo
	for key,weaponID in ipairs(weaponsTable) do
		if weaponID == currentWeapon then
			local i = key + progress
			while i ~= key do
				nextWeapon = weaponsTable[i]
				if nextWeapon then
					local slot = getSlotFromWeapon(nextWeapon)
					local weapon = getPedWeapon(localPlayer, slot)
					if ( weapon == nextWeapon  ) then
						switchToWeapon = weapon
						switchTo = slot
						break
					end
				end
				if not weaponsTable[i+progress] then
					if progress < 0 then
						i = #weaponsTable
					else
						i = 1
					end
				else
					i = i + progress
				end
			end
			break
		end
	end
	if not switchTo then return end
	setPedWeaponSlot(localPlayer, switchTo)
end
-----------------
addEvent("HDB:Camera", true)
addEventHandler("HDB:Camera", root,
	function(bool)
		setCameraClip(true, bool)
	end
)
-----------------
bindKey("e", "down", switchNextWeapon)
bindKey("q", "down", switchPrevWeapon)
bindKey("mouse_wheel_down", "down", switchNextWeapon)
bindKey("mouse_wheel_up", "down", switchPrevWeapon)