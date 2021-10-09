-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/Items/ItemWeapon.lua
-- *  PURPOSE:     Weapons class
-- *
-- ****************************************************************************
ItemWeapon = inherit(ItemNew)

function ItemWeapon:use()
	local player = self.m_Inventory:getPlayer()
	if not player then return false end

    --DEBUG
    self.m_Item.Metadata = self.m_Item.Metadata and self.m_Item.Metadata or {}
    self.m_Item.Metadata.AmmoInClip = self.m_Item.Metadata.AmmoInClip and self.m_Item.Metadata.AmmoInClip or 0
    
    local weaponId = INVENTORY_WEAPON_NAME_TO_ID[self:getTechnicalName()]
    local weaponSlot = getSlotFromWeapon(weaponId)

    if not self.m_Inventory:getItemEquipped(self.m_Item.Id) or player.m_loadAllEquippedItems then
        local currentWeaponIdInSlot = player:getWeapon(weaponSlot)
        if currentWeaponIdInSlot ~= 0 then
            local currentItem = self.m_Inventory:getItem(INVENTORY_WEAPON_ID_TO_NAME[currentWeaponIdInSlot])
            if currentItem then
                self.m_Inventory:setItemEquipped(currentItem.Id, false)
                currentItem.Metadata.AmmoInClip = player:getAmmoInClip(getSlotFromWeapon(currentWeaponIdInSlot))
                takeWeapon(player, currentWeaponIdInSlot)
            end
        end
        self.m_Inventory:setItemEquipped(self.m_Item.Id, true)
        local ammoAmount = self.m_Inventory:getItemAmount(INVENTORY_MUNITION_ID_TO_NAME[weaponId]) or 0
        if self.m_Item.Metadata.AmmoInClip == 0 and (weaponId == 25 or (weaponSlot ~= 2 and weaponSlot ~= 3 and weaponSlot ~= 4 and weaponSlot ~= 5)) then
            local weaponSkill = INVENTORY_WEAPON_AKIMBO_ID_TO_STAT[weaponId] and player:getStat(INVENTORY_WEAPON_AKIMBO_ID_TO_STAT[weaponId]) or 0
            local weaponSkill = weaponSkill >= 999 and "pro" or "poor"
            local maxAmmoInClip = getWeaponProperty(weaponId, weaponSkill, "maximum_clip_ammo") and getWeaponProperty(weaponId, weaponSkill, "maximum_clip_ammo") or 1
            local ammoToClip = maxAmmoInClip <= ammoAmount and maxAmmoInClip or ammoAmount
            local ammoToClip = ammoToClip ~= 0 and ammoToClip or 1
            self.m_Item.Metadata.AmmoInClip = ammoToClip
            if INVENTORY_MUNITION_ID_TO_NAME[weaponId] then
                if not self.m_Inventory:takeItem(INVENTORY_MUNITION_ID_TO_NAME[weaponId], ammoToClip) then
                    self.m_Item.Metadata.AmmoInClip = 0
                end
            end
        end
        giveWeapon(player, weaponId, 0)
        setWeaponAmmo(player, weaponId, ammoAmount + self.m_Item.Metadata.AmmoInClip, self.m_Item.Metadata.AmmoInClip)
    else
        self.m_Inventory:setItemEquipped(self.m_Item.Id, false)
        self.m_Item.Metadata.AmmoInClip = player:getAmmoInClip(weaponSlot)
        takeWeapon(player, weaponId)
    end
    self.m_Inventory:onInventoryChanged()
end