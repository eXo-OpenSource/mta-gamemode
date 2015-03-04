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
	self:loadImportTXD("files/models/vrp_logo.txd", 2903)
	self:loadImportDFF("files/models/vrp_logo.dff", 2903)
	self:loadImportCOL("files/models/vrp_logo.col", 2903)

	-- Race pickups
	self:loadImportTXD("files/models/nitro.txd", 2221)
	self:loadImportDFF("files/models/nitro.dff", 2221)
	self:loadImportTXD("files/models/repair.txd", 2222)
	self:loadImportDFF("files/models/repair.dff", 2222)
	self:loadImportTXD("files/models/vehiclechange.txd", 2223)
	self:loadImportDFF("files/models/vehiclechange.dff", 2223)
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
