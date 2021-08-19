-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/Items/Managers/ItemWeaponManager.lua
-- *  PURPOSE:     ItemWeaponManager Manager class
-- *
-- ****************************************************************************

ItemWeaponManager = inherit(Singleton)

function ItemWeaponManager:constructor()

end

function ItemWeaponManager:updatePlayerWeapons(player)

end

function ItemWeaponManager:takePlayerWeapons(player)

end


function ItemWeaponManager:removeWeaponsFromPlayerInventory(player, takeFromTemporaryInventory)
    local inventory = takeFromTemporaryInventory and player:getTemporaryInventory() or player:getInventory()
    if not inventory then
        return false
    end

    for weaponId, itemName in pairs(ItemsWeaponMapping) do
        local ammoItem = ItemsWeaponMappingAmmunition[weaponId]
        inventory:removeAllItem()
    end
end