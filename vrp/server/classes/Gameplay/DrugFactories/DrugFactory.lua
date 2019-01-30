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
    if self.m_EnterExit then
        self.m_EnterExit:delete()
    end
    if self.m_Blip then
        self.m_Blip:delete()
    end
end

function DrugFactory:create(id, type, owner, progress, managerPos, workingstations, workers, lastattack, x, y, z, rot, dim, int, intX, intY, intZ, intRot, color)
    self.m_EnterExit = InteriorEnterExit:new(Vector3(x, y, z), Vector3(intX, intY, intZ), intRot, rot, int, dim, 0, 0)
    self.m_Blip = Blip:new("Factory.png", x, y, root, 400, color)
    self.m_Blip:setDisplayText("Fabrik")
    self.Id = id
    self.m_Type = type
    self.m_Owner = owner
    self.m_Progress = progress
    self.m_Dimension = dim
    self.m_Interior = int
    self.m_WorkingStations = workingstations
    self.m_Workers = workers
    self.m_LastAttack = lastattack
    self.m_ManagerPos = managerPos

    self:spawnNPC()
end

function DrugFactory:spawnNPC()
    self.m_Manager = ShopNPC:new(276, self.m_ManagerPos.x, self.m_ManagerPos.y, self.m_ManagerPos.z, self.m_ManagerPos.rot)
    self.m_Manager:setInterior(self.m_Interior)
    self.m_Manager:setDimension(self.m_Dimension)
    self.m_Manager:setImmortal(true)
    self.m_Manager:setFrozen(true)
    self.m_Manager.m_Warning = "Du überfällst den Fabrik Manager in 5 Sekunden, wenn du weiter auf ihn zielst!"
    self.m_Manager.onTargetted = bind(self.PedTargetted, self)
end

function DrugFactory:PedTargetted(ped, attacker)
    FactoryWarManager:getSingleton():startAttack(self.Id, attacker:getFaction():getId(), attacker)
end

function DrugFactory:getOwner()
    return self.m_Owner
end

function DrugFactory:getProgress()
    return self.m_Progress
end

function DrugFactory:getType()
    return DrugFactoryManager:getSingleton().m_FactoryTypes[self.m_Type][2]
end

function DrugFactory:getWorkingStationCount()
    return self.m_WorkingStations
end

function DrugFactory:getWorkerCount()
    return self.m_Workers
end

function DrugFactory:getLastAttack()
    return self.m_LastAttack
end

function DrugFactory:setWorkingStationCount(amount)
    self.m_WorkingStations = amount
end

function DrugFactory:setWorkerCount(amount)
    self.m_Workers = amount
end