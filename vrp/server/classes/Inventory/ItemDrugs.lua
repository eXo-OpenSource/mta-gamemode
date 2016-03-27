-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/ItemDrugs.lua
-- *  PURPOSE:     Drugs Super class
-- *
-- ****************************************************************************
ItemDrugs = inherit(Item)

--CONSTANTS
-- units in ms
WEED_EXPIRETIME = 60 * 1000
HEROIN_EXPIRETIME = 50 * 1000
SHROOM_EXPIRETIME = 60 * 1000

function ItemDrugs:constructor()

end

function ItemDrugs:destructor()

end

function ItemDrugs:use( )

end
