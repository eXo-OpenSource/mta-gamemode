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
