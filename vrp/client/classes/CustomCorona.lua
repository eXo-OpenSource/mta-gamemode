-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/CustomCorona.lua
-- *  PURPOSE:     Custom Corona class
-- *
-- ****************************************************************************

CustomCorona = inherit(Object)
CustomCorona.Map = {}

function CustomCorona:constructor(x, y, z, size, r, g, b, a)
    self.m_X = x
    self.m_Y = y
    self.m_Z = z
    self.m_Size = size
    self.m_Color = {r, g, b, a}
    self.m_Corona = exports["custom_coronas"]:createCorona(x, y, z, size, r, g, b, a)
    CustomCorona.Map[self] = self
end


function CustomCorona:setPosition(x, y, z)
    if exports["custom_coronas"]:setCoronaPosition(self.m_Corona, x, y, z) then
        self.m_X = x
        self.m_Y = y
        self.m_Z = z
    end
end

function CustomCorona:attachTo(element, setPositionAsOffset)   
    if exports["custom_coronas"]:attachCoronaTo(self.m_Corona, element) then 
        if setPositionAsOffset then
            self:setAttachedOffsets(self.m_X, self.m_Y, self.m_Z)
        end
    end
end

function CustomCorona:setAttachedOffsets(x, y, z)   
    exports["custom_coronas"]:setAttachedOffsets(self.m_Corona, x, y, z)
end

function CustomCorona:destructor()
    self.m_Corona = exports["custom_coronas"]:destroyCorona(self.m_Corona)
    CustomCorona.Map[self] = nil
end