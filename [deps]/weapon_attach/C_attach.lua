local slotChecks = 
{
	"W_A:w0",
	"W_A:w1",
	"W_A:w2",
	"W_A:w3",
	"W_A:w5",
	"W_A:w6",
}

function removeWeaponOnSwitch(prevSlot, newSlot)
	local bIsEnabled
	local prevWeapon = getPedWeapon(localPlayer, prevSlot)
	if slotChecks[prevSlot] and (prevWeapon ~= 32 and prevWeapon ~= 28) then 
		bIsEnabled = getElementData(localPlayer,slotChecks[prevSlot])
	elseif prevWeapon == 32 or prevWeapon == 28 then 
		bIsEnabled = getElementData(localPlayer,"W_A:w4")
	end
	if prevWeapon == 34 then bIsEnabled = true end
	triggerServerEvent("createWepObject", localPlayer, localPlayer, getPedWeapon(localPlayer, newSlot), 0, getSlotFromWeapon(getPedWeapon(localPlayer, newSlot)))
	if bIsEnabled then
		triggerServerEvent("createWepObject", localPlayer, localPlayer, prevWeapon, 1, getSlotFromWeapon(getPedWeapon(localPlayer, prevSlot)))
	end
end
addEventHandler("onClientPlayerWeaponSwitch", getRootElement(), removeWeaponOnSwitch)


addEvent("Weapon_Attach:recheckWeapons")
function recheckAllWeapons( slot ) 
	removeWeaponOnSwitch(slot, slot)
	setPedWeaponSlot(localPlayer,0)
end
addEventHandler("Weapon_Attach:recheckWeapons", localPlayer, recheckAllWeapons)