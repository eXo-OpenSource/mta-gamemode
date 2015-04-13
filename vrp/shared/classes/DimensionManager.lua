-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        shared/classes/DimensionManager.lua
-- *  PURPOSE:     DimensionManager class
-- *
-- ****************************************************************************
DimensionManager = inherit(Singleton)

function DimensionManager:constructor ()
    self.m_Dimensions = {
      [1] = true, -- reserved
      [2] = true -- reserved
    }
end

function DimensionManager:getFreeDimension ()
    local dim = #self.m_Dimensions + 1
    self.m_Dimensions[dim] = true

    return dim
end

function DimensionManager:freeDimension (dim)
    self.m_Dimensions[dim] = nil
end
