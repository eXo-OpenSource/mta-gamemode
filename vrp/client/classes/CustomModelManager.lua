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

	-- Blitzer
	self:loadImportTXD("files/models/blitzer.txd", 3902)
	self:loadImportDFF("files/models/blitzer.dff", 3902)
	self:loadImportCOL("files/models/blitzer.col", 3902)

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

	-- Mushrooms
	self:loadImportTXD("files/models/mushrooms.txd", 1882)
	self:loadImportCOL("files/models/mushroom01.col", 1882)
	self:loadImportDFF("files/models/mushroom01.dff", 1882)

	-- Replace dozer/dumper dff to improve stone handling ("schubsing") :D
	self:loadImportDFF("files/models/dozer.dff", 486)
	self:loadImportDFF("files/models/dumper.dff", 406)

	self:loadImportTXD("files/models/mushrooms.txd", 1947)
	self:loadImportCOL("files/models/mushroom02.col", 1947)
	self:loadImportDFF("files/models/mushroom02.dff", 1947)

	self:loadImportTXD("files/models/waterCan.txd", 1902)
	self:loadImportCOL("files/models/waterCan.col", 1902)
	self:loadImportDFF("files/models/waterCan.dff", 1902)

	self:loadImportTXD("files/models/mostWanted.txd", 1903)
	self:loadImportCOL("files/models/mostWanted.col", 1903)
	self:loadImportDFF("files/models/mostWanted.dff", 1903)

	self:loadImportTXD("files/models/medic.txd", 4027)
	self:loadImportCOL("files/models/medic.col", 4027)
	self:loadImportDFF("files/models/medic.dff", 4027)
	self:setLODDistance(4027, 500)

	self:loadImportTXD("files/models/medicLOD.txd", 4076)
	self:loadImportCOL("files/models/medicLOD.col", 4076)
	self:loadImportDFF("files/models/medicLOD.dff", 4076)

	self:loadImportTXD("files/models/holzstamm.txd", 837)
	self:loadImportCOL("files/models/holzstamm.col", 837)
	self:loadImportDFF("files/models/holzstamm.dff", 837)

	--Kart-Track
	self:loadImportTXD("files/models/kart.txd", 13083)
	self:loadImportCOL("files/models/kart.col", 13083)
	self:loadImportDFF("files/models/kart.dff", 13083)

	self:loadImportTXD("files/models/bed.txd", 1879)
	self:loadImportCOL("files/models/bed.col", 1879)
	self:loadImportDFF("files/models/bed.dff", 1879)

	self:loadImportTXD("files/models/pickaxe.txd", 1858)
	self:loadImportCOL("files/models/pickaxe.col", 1858)
	self:loadImportDFF("files/models/pickaxe.dff", 1858)

	self:loadImportTXD("files/models/donut.txd", 1915)
	self:loadImportCOL("files/models/donut.col", 1915)
	self:loadImportDFF("files/models/donut.dff", 1915)

	self:loadImportTXD("files/models/FishingRod.txd", 1826)
	self:loadImportCOL("files/models/FishingRod.col", 1826)
	self:loadImportDFF("files/models/FishingRod.dff", 1826)

	self:loadImportTXD("files/models/pickaxe.txd", 1858)
	self:loadImportCOL("files/models/pickaxe.col", 1858)
	self:loadImportDFF("files/models/pickaxe.dff", 1858)

	self:loadImportTXD("files/models/topfun.txd", 459)
	self:loadImportDFF("files/models/topfun.dff", 459)

	-- Tardis EasterEgg
	self:loadImportTXD("files/models/tardis.txd", 1881)
	self:loadImportDFF("files/models/tardis.dff", 1881)

	self:loadImportDFF("files/models/piss.dff", 1904)

	self:loadShader("files/images/Other/parking1.png", "noparking2_128")
	self:loadShader("files/images/Other/parking2.png", "roadsign01_128")

	self:loadShader("files/images/Other/trans.png", "txgrass0_1")
	self:loadShader("files/images/Other/trans.png", "txgrass1_1")


	-- Helmet FullFace
	self:loadImportTXD("files/models/Wearables/helmet.txd", 2052)
	self:loadImportDFF("files/models/Wearables/helmet.dff", 2052)

	-- Helmet Cross
	self:loadImportTXD("files/models/Wearables/crosshelmet.txd", 2799)
	self:loadImportCOL("files/models/Wearables/crosshelmet.col", 2799)
	self:loadImportDFF("files/models/Wearables/crosshelmet.dff", 2799)

	-- Helmet Biker ( pot )
	self:loadImportTXD("files/models/Wearables/bikerhelmet.txd", 3911)
	self:loadImportDFF("files/models/Wearables/bikerhelmet.dff", 3911)

	-- Gas Mask
	self:loadImportTXD("files/models/Wearables/gasmask.txd", 3890)
	self:loadImportDFF("files/models/Wearables/gasmask.dff", 3890)

	-- Kevlar
	self:loadImportTXD("files/models/Wearables/kevlar.txd", 3916)
	self:loadImportDFF("files/models/Wearables/kevlar.dff", 3916)

	-- Dufflebag
	self:loadImportTXD("files/models/Wearables/dufflebag.txd", 3915)
	self:loadImportDFF("files/models/Wearables/dufflebag.dff", 3915)

	-- Swatshield
	self:loadImportTXD("files/models/Wearables/riot_shield.txd",1631)
	self:loadImportDFF("files/models/Wearables/riot_shield.dff",1631)
	self:loadImportCOL("filEs/models/Wearables/riot_shield.col",1631)

end

function CustomModelManager:loadImportDFF(filePath, modelId)
	local dff = engineLoadDFF(filePath, 0)
	return engineReplaceModel(dff, modelId)
end

function CustomModelManager:loadImportTXD(filePath, modelId)
	local txd = engineLoadTXD(filePath)
	return engineImportTXD(txd, modelId), txd
end

function CustomModelManager:loadImportCOL(filePath, modelId)
	local col = engineLoadCOL(filePath)
	engineReplaceCOL(col, modelId)
end

function CustomModelManager:setLODDistance(modelId, distance)
	engineSetModelLODDistance(modelId, distance)
end

function CustomModelManager:restoreModel(modelId)
	return engineRestoreModel(modelId)
end

function CustomModelManager:loadShader(filePath, textureName)
	local shader = dxCreateShader("files/shader/texreplace.fx")
	local texture = dxCreateTexture(filePath)
	dxSetShaderValue(shader, "gTexture", texture)
	engineApplyShaderToWorldTexture(shader, textureName)
end
