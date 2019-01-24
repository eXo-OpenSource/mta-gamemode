-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/DrugFactories/DrugFactory.lua
-- *  PURPOSE:     Drug Factory class
-- *
-- ****************************************************************************

DrugFactory = inherit(Object)

function DrugFactory:constructor()

end

function DrugFactory:destructor()

end

function DrugFactory:create(type, progress, x, y, z, rot, dim, int, intX, intY, intZ, intRot, color)
    self.m_EnterExit = InteriorEnterExit:new(Vector3(x, y, z), Vector3(intX, intY, intZ), intRot, rot, int, dim, 0, 0)
    self.m_Blip = Blip:new("Factory.png", x, y, root, 400, color)
    self.m_Blip:setDisplayText("Fabrik")
    self.m_Progress = progress
end