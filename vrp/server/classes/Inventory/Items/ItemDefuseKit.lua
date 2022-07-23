-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/Items/ItemDefuseKit.lua
-- *  PURPOSE:     Smoke Grenade Item
-- *
-- ****************************************************************************
ItemDefuseKit = inherit(Item)
ItemDefuseKit.Map = { }

function ItemDefuseKit:constructor()

end

function ItemDefuseKit:destructor()

end


function ItemDefuseKit:use(player)
    for i, slam in pairs(ItemSlam.EntityMap) do
        if (slam:getPosition() - player:getPosition()):getLength() <= 1.5 then
            player:setAnimation("bomber", "bom_plant_loop", -1, true, false, false, false, 250, true)
            setPedAnimationSpeed(player, "bom_plant_loop", .5)
            toggleAllControls(player, false)
            player:triggerEvent("Countdown", 10, "Entschärft in")
            player:getInventory():removeItem(self:getName(), 1)

            addEventHandler("onPedWasted", player, bind(self.onWasted, self))
            self.m_DefuseSlam = bind(self.defuse, self)
            self.m_DefuseTimer = setTimer(self.m_DefuseSlam, 10000, 1, player, slam)
            break
        end
    end
end

function ItemDefuseKit:defuse(player, slam)
    if math.random(1, 10) ~= 1 then
	    ItemManager:getSingleton():getInstance("SLAM"):deleteSlam(ItemSlam.Map[slam])
    else
        ItemManager:getSingleton():getInstance("SLAM"):detonateSlam(ItemSlam.Map[slam], player)
    end
    player:setAnimation(nil)
    toggleAllControls(player, true)
    removeEventHandler("onPedWasted", player, bind(self.onWasted, self))
end

function ItemDefuseKit:onWasted()
    source:triggerEvent("CountdownStop", "Entschärft in")
    killTimer(self.m_DefuseTimer) 
    removeEventHandler("onPedWasted", player, bind(self.onWasted, self))
end