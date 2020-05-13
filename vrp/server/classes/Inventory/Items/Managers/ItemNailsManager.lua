-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/Items/Managers/ItemNailsManager.lua
-- *  PURPOSE:     Item Nails Manager class
-- *
-- ****************************************************************************
ItemNailsManager = inherit(Singleton)
addRemoteEvents{"Nails:flattenWheel"}

function ItemNailsManager:constructor()
    self.m_WheelFlattenBind = bind(self.Event_flattenWheel, self)
    addEventHandler("Nails:flattenWheel", root, self.m_WheelFlattenBind)
end

function ItemNailsManager:destructor()
    removeEventHandler("Nails:flattenWheel", root, self.m_WheelFlattenBind)
end

function ItemNailsManager:Event_flattenWheel(vehicle, wheels)
    if not client then 
        return 
    end

    vehicle:setWheelStates(unpack(wheels))
end