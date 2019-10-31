-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Events/Halloween/HalloweenTotem.lua
-- *  PURPOSE:     Halloween Totem class
-- *
-- ****************************************************************************

HalloweenTotem = inherit(Object)

function HalloweenTotem:constructor(position, rotation, callback)
    self.m_Totem = createObject(3524, position + Vector3(0, 0, -1), rotation+Vector3(0, 0, 180))
    self.m_Totem:setScale(0.35)
    self.m_Totem:setCollisionsEnabled(false)
    self.m_ClickObject = createObject(3407, position + Vector3(0, 0, -1.35), rotation)
    self.m_ClickObject:setAlpha(0)
    setElementData(self.m_ClickObject, "clickable", true)
    self.m_ClickObject:setData("onClickEvent", 
        function()
            SuccessBox:new("Totem abgebaut!")
            if self.m_CallBack then
                self.m_CallBack()
            end
            delete(self)
        end
    )
    self.m_CallBack = callback
end

function HalloweenTotem:destructor()
    self.m_Totem:destroy()
    self.m_ClickObject:destroy()
end