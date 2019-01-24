-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/DrugFactories/DrugFactoryManager.lua
-- *  PURPOSE:     Drug Factory Manager class
-- *
-- ****************************************************************************

DrugFactoryManager = inherit(Singleton)
DrugFactoryManager.Map = {}

function DrugFactoryManager:constructor()
    self.m_FactoryTypes = {
        [1] = {DrugFactory, 2, 2570.18, -1301.94, 1044.13, 90},
        [2] = {WeedFactory, 1, 2132.84, -2297.11, 960.42, 0},
        [3] = {DrugFactory, 0, 0, 0, 0, 0}
    }
    self.m_FactoryColors = {
        [1] = {255, 255, 255},
        [2] = {0, 200, 50},
        [3] = {0, 0, 0}
    }
    self:loadFactories()
end

function DrugFactoryManager:destructor()
    
end

function DrugFactoryManager:loadFactories()
	local result = sql:queryFetch("SELECT * FROM ??_drug_factories", sql:getPrefix())
    for k, row in ipairs(result) do
        if self.m_FactoryTypes[row.type] then
            DrugFactoryManager.Map[row.id] = self.m_FactoryTypes[row.type][1]:new(row.type, row.progress, row.x, row.y, row.z, row.rot, row.dimension, self.m_FactoryTypes[row.type][2], self.m_FactoryTypes[row.type][3], self.m_FactoryTypes[row.type][4], self.m_FactoryTypes[row.type][5], self.m_FactoryTypes[row.type][6], self.m_FactoryColors[row.type])
        end
	end
end

function DrugFactoryManager:updateFactoryWorkStates()
    
end