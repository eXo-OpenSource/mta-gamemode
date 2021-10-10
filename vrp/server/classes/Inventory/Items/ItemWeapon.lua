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

        local ammoAmount = self.m_Inventory:getItemAmount(INVENTORY_MUNITION_ID_TO_NAME[weaponId]) or 0
        if self.m_Item.Metadata.AmmoInClip == 0 and INVENTORY_NON_RELOADABLE_WEAPON_ID[weaponId] then
            local weaponSkill = (INVENTORY_WEAPON_AKIMBO_ID_TO_STAT[weaponId] and player:getStat(INVENTORY_WEAPON_AKIMBO_ID_TO_STAT[weaponId]) or 0) >= 999 and "pro" or "poor"
            local maximumClipAmmo = getWeaponProperty(weaponId, weaponSkill, "maximum_clip_ammo") or 1

            if maximumClipAmmo <= ammoAmount then
                self.m_Item.Metadata.AmmoInClip = maximumClipAmmo
                ammoAmount = ammoAmount - maximumClipAmmo
            else
                self.m_Item.Metadata.AmmoInClip = ammoAmount
                ammoAmount = 0
            end

            if INVENTORY_MUNITION_ID_TO_NAME[weaponId] then
                if not self.m_Inventory:takeItem(INVENTORY_MUNITION_ID_TO_NAME[weaponId], self.m_Item.Metadata.AmmoInClip) then
                    self.m_Item.Metadata.AmmoInClip = 0
                end
            else
                self.m_Item.Metadata.AmmoInClip = 1
            end
        end

        if self.m_Item.Metadata.AmmoInClip == 0 and ammoAmount == 0 then
            return player:sendError(_("Du hast nicht genügend Munition für diese Waffe!"))
        end

        giveWeapon(player, weaponId, 0)
        setWeaponAmmo(player, weaponId, ammoAmount + self.m_Item.Metadata.AmmoInClip, self.m_Item.Metadata.AmmoInClip)
        self.m_Inventory:setItemEquipped(self.m_Item.Id, true)
    else
        self.m_Item.Metadata.AmmoInClip = player:getAmmoInClip(weaponSlot)
        takeWeapon(player, weaponId)
        self.m_Inventory:setItemEquipped(self.m_Item.Id, false)
    end
    self.m_Inventory:onInventoryChanged()
end

function ItemWeapon:useSecondary()
    if self.m_Inventory:getItemEquipped(self.m_Item.Id) then
        local player = self.m_Inventory:getPlayer()
        if player then
            player:sendError(_("Lege die Waffe zunächst ab bevor du die Munition entnimmst!"))
        end
        return false
    end

    if self.m_Inventory:giveItem(INVENTORY_MUNITION_ID_TO_NAME[INVENTORY_WEAPON_NAME_TO_ID[self:getTechnicalName()]], self.m_Item.Metadata.AmmoInClip) then
        self.m_Item.Metadata.AmmoInClip = 0
    end

    self.m_Inventory:onInventoryChanged()
end