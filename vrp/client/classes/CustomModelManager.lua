-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/CustomModelManager.lua
-- *  PURPOSE:     Easy way to load custom models
-- *
-- ****************************************************************************
CustomModelManager = inherit(Singleton)

function CustomModelManager:constructor()
	--self:loadImportDFF("files/models/dead_tree_18.dff", 846)

	-- Yoda
	self:loadImportTXD("files/models/yoda.txd", 41)
	self:loadImportDFF("files/models/yoda.dff", 41)

	-- Zombie
	self:loadImportTXD("files/models/zombie.txd", 310)
	self:loadImportDFF("files/models/zombie.dff", 310)

	-- vRP Logo
	self:loadImportTXD("files/models/exo_logo.txd", 2836)
	self:loadImportDFF("files/models/exo_logo.dff", 2836)
	self:loadImportCOL("files/models/exo_logo.col", 2836)

	-- Race pickups
	self:loadImportTXD("files/models/nitro.txd", 2839)
	self:loadImportDFF("files/models/nitro.dff", 2839)
	self:loadImportTXD("files/models/repair.txd", 2837)
	self:loadImportDFF("files/models/repair.dff", 2837)
	self:loadImportTXD("files/models/vehiclechange.txd", 2838)
	self:loadImportDFF("files/models/vehiclechange.dff", 2838)

	--Mushrooms
	self:loadImportTXD("files/models/mushrooms.txd", 1882)
	self:loadImportCOL("files/models/mushroom01.col", 1882)
	self:loadImportDFF("files/models/mushroom01.dff", 1882)

	self:loadImportTXD("files/models/mushrooms.txd", 1947)
	self:loadImportCOL("files/models/mushroom02.col", 1947)
	self:loadImportDFF("files/models/mushroom02.dff", 1947)

	self:loadImportTXD("files/models/waterCan.txd", 1902)
	self:loadImportCOL("files/models/waterCan.col", 1902)
	self:loadImportDFF("files/models/waterCan.dff", 1902)

	self:loadImportTXD("files/models/mostWanted.txd", 10823)
	self:loadImportCOL("files/models/mostWanted.col", 10823)
	self:loadImportDFF("files/models/mostWanted.dff", 10823)

end

function CustomModelManager:loadImportDFF(filePath, modelId)
	local dff = engineLoadDFF(filePath, 0)
	return engineReplaceModel(dff, modelId)
end

function CustomModelManager:loadImportTXD(filePath, modelId)
	local txd = engineLoadTXD(filePath)
	return engineImportTXD(txd, modelId)
end

function CustomModelManager:loadImportCOL(filePath, modelId)
	local col = engineLoadCOL(filePath)
	engineReplaceCOL(col, modelId)
end
