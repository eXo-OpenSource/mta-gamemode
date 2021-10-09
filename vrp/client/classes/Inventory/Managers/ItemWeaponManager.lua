-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Inventory/Managers/ItemWeaponManager.lua
-- *  PURPOSE:     ItemWeaponManager Manager class
-- *
-- ****************************************************************************

ItemWeaponManager = inherit(Singleton)

function ItemWeaponManager:constructor()
    self.m_OnClientProjectileCreationBind = bind(self.onClientProjectileCreation, self)
    addEventHandler("onClientProjectileCreation", root, self.m_OnClientProjectileCreationBind)

    self.m_OnWeaponReload = bind(self.onWeaponReload, self)
    Timer(self.m_OnWeaponReload, 50, 0)

    self.m_WeaponAmmunitionInClip = {}
end

function ItemWeaponManager:onClientProjectileCreation(player)
    if player == localPlayer then
        local weapon = getProjectileType(source)
        if weapon ~= 19 and weapon ~= 20 then
            triggerServerEvent("ItemWeaponManager:onClientProjectileCreation", localPlayer, weapon)
        end
    end
end

function ItemWeaponManager:onWeaponReload()
    local weaponId = localPlayer:getWeapon()
    local weaponSlot = getSlotFromWeapon(weaponId)
    local currentAmmoInClip = localPlayer:getAmmoInClip(weaponSlot)

    if self.m_WeaponAmmunitionInClip[weaponId] and self.m_WeaponAmmunitionInClip[weaponId] < currentAmmoInClip then
        local weaponSkill = (INVENTORY_WEAPON_AKIMBO_ID_TO_STAT[weaponId] and localPlayer:getStat(INVENTORY_WEAPON_AKIMBO_ID_TO_STAT[weaponId]) or 0) >= 999 and "pro" or "poor"
        local maxAmmoInClip = getWeaponProperty(weaponId, weaponSkill, "maximum_clip_ammo")
        local maxAmmoInClip = localPlayer:getTotalAmmo(weaponSlot) >= maxAmmoInClip and maxAmmoInClip or localPlayer:getTotalAmmo(weaponSlot)
        local reloadedAmount = maxAmmoInClip - self.m_WeaponAmmunitionInClip[weaponId]
        if reloadedAmount ~= 0 then
            triggerServerEvent("ItemWeaponManager:onClientWeaponReload", localPlayer, weaponId, reloadedAmount)
        end
    end

    self.m_WeaponAmmunitionInClip[weaponId] = currentAmmoInClip
end