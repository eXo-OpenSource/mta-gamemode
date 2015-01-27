-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/PlaceableItem.lua
-- *  PURPOSE:     Base class for items which are placeable
-- *
-- ****************************************************************************
PlaceableItem = inherit(Item)

PlaceableItem.onClick = pure_virtual
