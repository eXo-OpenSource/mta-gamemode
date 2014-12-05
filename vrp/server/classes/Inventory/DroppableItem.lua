-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/DroppableItem.lua
-- *  PURPOSE:     Base class for items which are droppable/placeable
-- *
-- ****************************************************************************
DroppableItem = inherit(Item)

DroppableItem.getModelId = pure_virtual
DroppableItem.onClick = pure_virtual
