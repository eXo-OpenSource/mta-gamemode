function removeWeaponOnSwitch(prevSlot, newSlot)
	triggerServerEvent("createWepObject", localPlayer, localPlayer, getPedWeapon(localPlayer, newSlot), 0, getSlotFromWeapon(getPedWeapon(localPlayer, newSlot)))
	triggerServerEvent("createWepObject", localPlayer, localPlayer, getPedWeapon(localPlayer, prevSlot), 1, getSlotFromWeapon(getPedWeapon(localPlayer, prevSlot)))
end
addEventHandler("onClientPlayerWeaponSwitch", getRootElement(), removeWeaponOnSwitch)

