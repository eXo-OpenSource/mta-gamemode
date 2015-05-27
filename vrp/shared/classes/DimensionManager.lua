-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        shared/classes/DimensionManager.lua
-- *  PURPOSE:     DimensionManager class
-- *
-- ****************************************************************************
DimensionManager = inherit(Singleton)

function DimensionManager:constructor()
    self.m_Dimensions = {
      [1] = true, -- reserved
      [2] = true, -- reserved
      [PRIVATE_DIMENSION_SERVER] = true, -- reserved
    }

    -- Reserve interiors
    if SERVER then
        for k, dimension in pairs(Interiors) do
            self.m_Dimensions[dimension] = true
        end
    end
end

function DimensionManager:getFreeDimension()
    local dim = #self.m_Dimensions + 1
    self.m_Dimensions[dim] = true

    return dim
end

function DimensionManager:freeDimension(dim)
    self.m_Dimensions[dim] = nil
end
