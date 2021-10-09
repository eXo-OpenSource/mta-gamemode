-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/Items/Managers/ItemWeaponManager.lua
-- *  PURPOSE:     ItemWeaponManager Manager class
-- *
-- ****************************************************************************

ItemWeaponManager = inherit(Singleton)

addRemoteEvents{"ItemWeaponManager:onClientProjectileCreation", "ItemWeaponManager:onClientWeaponReload"}

function ItemWeaponManager:constructor()
    self.m_OnClientProjectileCreationBind = bind(self.onClientProjectileCreation, self)
    addEventHandler("ItemWeaponManager:onClientProjectileCreation", root, self.m_OnClientProjectileCreationBind)

    self.m_OnClientWeaponReloadBind = bind(self.onClientWeaponReload, self)
    addEventHandler("ItemWeaponManager:onClientWeaponReload", root, self.m_OnClientWeaponReloadBind)

    PlayerManager:getSingleton():getQuitHook():register(bind(self.onPlayerQuit, self))
	PlayerManager:getSingleton():getWastedHook():register(bind(self.onPlayerWasted, self))
end

function ItemWeaponManager:onClientProjectileCreation(weaponId)
    client:getInventory():takeItem(INVENTORY_WEAPON_ID_TO_NAME[weaponId], 1)
end

function ItemWeaponManager:onClientWeaponReload(weaponId, reloadedAmount)
    client:getInventory():takeItem(INVENTORY_MUNITION_ID_TO_NAME[weaponId], reloadedAmount)
end

function ItemWeaponManager:onPlayerQuit(player)
    local inventory = player:getInventory()
    for i = 2, 9 do
        local item = inventory:getItem(INVENTORY_WEAPON_ID_TO_NAME[player:getWeapon(i)])
        if item then
            item.Metadata.AmmoInClip = player:getAmmoInClip(i)
        end
    end
    player:getInventory():onInventoryChanged()
end

function ItemWeaponManager:onPlayerWasted(player)
    local inventory = player:getInventory()
    for i = 2, 9 do
        local item = inventory:getItem(INVENTORY_WEAPON_ID_TO_NAME[player:getWeapon(i)])
        if item and item.Equipped == 1 then
            inventory:useItem(item.Id)
        end
    end
    inventory:onInventoryChanged()
 end

 --[[
    TODO:
    - Parachute removal, or sell as "repackable parachutes"?
    - When ammunition gets traded, remove from equipped weapons
    - rework migration for weapon ammunition
    - replace all native weapon functions to work with inventory weapons
    - rework sniper / rpg showing on back when not equipped
    - rework weapon pickup on death
    - add ammunition icons
    - add function to add / remove ammo from clip to bullet stack
]]