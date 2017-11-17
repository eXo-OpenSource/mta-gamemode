-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/CustomModelManager.lua
-- *  PURPOSE:     Easy way to load custom models
-- *
-- ****************************************************************************
CustomModelManager = inherit(Singleton)

function CustomModelManager:constructor()
	self.m_DFFMap = {}
	self.m_COLMap = {}
	self.m_TXDMap = {}
	self.m_TextureReplaces = {}
	--self:loadImportDFF("files/models/dead_tree_18.dff", 846)


	--world objects
	self:loadImportCOL("files/models/mech.col", 7520)
	self:loadImportDFF("files/models/mech.dff", 7520)

	--rescue base
	self:loadImportCOL("files/models/medic.col", 4027)
	self:loadImportTXD("files/models/medic.txd", 4027)
	self:loadImportDFF("files/models/medic.dff", 4027)
	self:setLODDistance(4027, 500)
	self:loadImportCOL("files/models/medicLOD.col", 4076)
	self:loadImportTXD("files/models/medicLOD.txd", 4076)
	self:loadImportDFF("files/models/medicLOD.dff", 4076)
	--Kart-Track
	self:loadImportCOL("files/models/kart.col", 13083)
	self:loadImportTXD("files/models/kart.txd", 13083)
	self:loadImportDFF("files/models/kart.dff", 13083)
	self:loadImportCOL("files/models/bed.col", 1879)
	self:loadImportTXD("files/models/bed.txd", 1879)
	self:loadImportDFF("files/models/bed.dff", 1879)
	-- Army Fence 1
	self:loadImportCOL("files/models/a51fencing.col", 16094)
	self:loadImportTXD("files/models/a51fencing.txd", 16094)
	self:loadImportDFF("files/models/a51fencing.dff", 16094)
	-- Army Fence 2
	self:loadImportCOL("files/models/a51fensin.col", 974)
	self:loadImportTXD("files/models/a51fencing.txd", 974)
	self:loadImportDFF("files/models/a51fensin.dff", 974)
		-- Building fixes
	self:loadImportCOL("files/models/academi.col", 6389)
	self:loadImportDFF("files/models/academi.dff", 6389)
	-- Ammunation Street hedge
	self:loadImportCOL("files/models/hedge01_law.col", 6046)
	self:loadImportDFF("files/models/hedge01_law.dff", 6046)
	self:setLODDistance(6046, 500)
	--pd
	self:loadImportCOL("files/models/PD_Garage.col", 4232)
	self:loadImportDFF("files/models/PD_Garage.dff", 4232)
	self:loadImportCOL("files/models/PD_int.col", 14846)
	self:loadImportDFF("files/models/PD_int.dff", 14846)
	self:loadImportCOL("files/models/PD_main.col", 3976)
	self:loadImportDFF("files/models/PD_main.dff", 3976)
	--bank
	self:loadImportCOL("files/models/bank.col", 4600)
	self:loadImportTXD("files/models/bank.txd", 4600)
	self:loadImportDFF("files/models/bank.dff", 4600)
	self:loadImportCOL("files/models/bankServer.col", 1880)
	self:loadImportTXD("files/models/bankServer.txd", 1880)
	self:loadImportDFF("files/models/bankServer.dff", 1880)
	self:loadImportCOL("files/models/bankDoor.col", 1930)
	self:loadImportTXD("files/models/bankDoor.txd", 1930)
	self:loadImportDFF("files/models/bankDoor.dff", 1930)
	--fishing shop
	self:loadImportCOL("files/models/fishshop.col", 6289)
	self:loadImportTXD("files/models/fishshop.txd", 6289)
	self:loadImportDFF("files/models/fishshop.dff", 6289)
	--ammunation
	self:loadImportCOL("files/models/ammunation.col", 4552)
	self:loadImportDFF("files/models/ammunation.dff", 4552)
	self:loadImportCOL("files/models/ammunation_int.col", 18049)
	self:loadImportDFF("files/models/ammunation_int.dff", 18049)

	self:loadImportCOL("files/models/ammunation2.col", 5106)
	self:loadImportDFF("files/models/ammunation2.dff", 5106)
	self:loadImportCOL("files/models/ammunation2_int.col", 18033)
	self:loadImportDFF("files/models/ammunation2_int.dff", 18033)

	--fence (?)
	self:loadImportCOL("files/models/fence.col", 1866)
	self:loadImportTXD("files/models/fence.txd", 1866)
	self:loadImportDFF("files/models/fence.dff", 1866)

	-- fuel nozzle
	self:loadImportCOL("files/models/fuelnozzle.col", 1909)
	self:loadImportTXD("files/models/fuelnozzle.txd", 1909)
	self:loadImportDFF("files/models/fuelnozzle.dff", 1909)

	self:loadImportDFF("files/models/gasstation.dff", 1676)

	--other objects
	-- Blitzer
	self:loadImportCOL("files/models/blitzer.col", 3902)
	self:loadImportTXD("files/models/blitzer.txd", 3902)
	self:loadImportDFF("files/models/blitzer.dff", 3902)
	-- Mushrooms
	self:loadImportCOL("files/models/mushroom01.col", 1882)
	self:loadImportTXD("files/models/mushrooms.txd", 1882)
	self:loadImportDFF("files/models/mushroom01.dff", 1882)
	--Wanted board of LSPD
	self:loadImportCOL("files/models/mostWanted.col", 1903)
	self:loadImportTXD("files/models/mostWanted.txd", 1903)
	self:loadImportDFF("files/models/mostWanted.dff", 1903)
	--mushrooms
	self:loadImportCOL("files/models/mushroom02.col", 1947)
	self:loadImportTXD("files/models/mushrooms.txd", 1947)
	self:loadImportDFF("files/models/mushroom02.dff", 1947)
	--water can
	self:loadImportCOL("files/models/waterCan.col", 1902)
	self:loadImportTXD("files/models/waterCan.txd", 1902)
	self:loadImportDFF("files/models/waterCan.dff", 1902)
	-- Helmet FullFace
	self:loadImportTXD("files/models/Wearables/helmet.txd", 2052)
	self:loadImportDFF("files/models/Wearables/helmet.dff", 2052)
	-- Helmet Cross
	self:loadImportCOL("files/models/Wearables/crosshelmet.col", 1924)
	self:loadImportTXD("files/models/Wearables/crosshelmet.txd", 1924)
	self:loadImportDFF("files/models/Wearables/crosshelmet.dff", 1924)
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
	self:loadImportCOL("files/models/Wearables/riot_shield.col",1631)
	self:loadImportTXD("files/models/Wearables/riot_shield.txd",1631)
	self:loadImportDFF("files/models/Wearables/riot_shield.dff",1631)
	-- Tardis EasterEgg
	self:loadImportCOL("files/models/pickaxe.col", 1858)
	self:loadImportTXD("files/models/pickaxe.txd", 1858)
	self:loadImportDFF("files/models/pickaxe.dff", 1858)
	self:loadImportCOL("files/models/donut.col", 1915)
	self:loadImportTXD("files/models/donut.txd", 1915)
	self:loadImportDFF("files/models/donut.dff", 1915)
	self:loadImportCOL("files/models/FishingRod.col", 1826)
	self:loadImportTXD("files/models/FishingRod.txd", 1826)
	self:loadImportDFF("files/models/FishingRod.dff", 1826)
	self:loadImportTXD("files/models/tardis.txd", 1881)
	self:loadImportDFF("files/models/tardis.dff", 1881)
	--firetruck-ladder
	self:loadImportCOL("files/models/fire_ledder.col", 1931)
	self:loadImportTXD("files/models/fire_ledder.txd", 1931)
	self:loadImportDFF("files/models/fire_ledder.dff", 1931)
	self:loadImportCOL("files/models/fire_main.col", 1932)
	self:loadImportTXD("files/models/fire_main.txd", 1932)
	self:loadImportDFF("files/models/fire_main.dff", 1932)

	self:loadImportDFF("files/models/piss.dff", 1904)
	--wood
	self:loadImportCOL("files/models/holzstamm.col", 837)
	self:loadImportTXD("files/models/holzstamm.txd", 837)
	self:loadImportDFF("files/models/holzstamm.dff", 837)


	--pickups
	-- vRP Logo
	self:loadImportCOL("files/models/exo_logo.col", 2836)
	self:loadImportTXD("files/models/exo_logo.txd", 2836)
	self:loadImportDFF("files/models/exo_logo.dff", 2836)
	-- Race pickups
	self:loadImportTXD("files/models/nitro.txd", 2839)
	self:loadImportDFF("files/models/nitro.dff", 2839)
	self:loadImportTXD("files/models/repair.txd", 2837)
	self:loadImportDFF("files/models/repair.dff", 2837)
	self:loadImportTXD("files/models/vehiclechange.txd", 2838)
	self:loadImportDFF("files/models/vehiclechange.dff", 2838)


	--vehicles
	-- Replace dozer/dumper dff to improve stone handling ("schubsing") :D
	self:loadImportDFF("files/models/dozer.dff", 486)
	self:loadImportDFF("files/models/dumper.dff", 406)
	--self:loadImportDFF("files/models/vehicles/infernus.dff", 411)
	self:loadImportTXD("files/models/vehicles/sandking.txd", 495)
	self:loadImportDFF("files/models/vehicles/sandking.dff", 495)
	self:loadImportTXD("files/models/vehicles/uranus.txd", 558)
	self:loadImportDFF("files/models/vehicles/uranus.dff", 558)
	self:loadImportTXD("files/models/vehicles/supergt.txd", 506)
	self:loadImportDFF("files/models/vehicles/supergt.dff", 506)
	self:loadImportDFF("files/models/vehicles/dft30.dff", 578)
	--RC Van
	self:loadImportTXD("files/models/vehicles/topfun.txd", 459)
	self:loadImportDFF("files/models/vehicles/topfun.dff", 459)


	--skins
	-- Zombie
	self:loadImportTXD("files/models/zombie.txd", 310)
	self:loadImportDFF("files/models/zombie.dff", 310)

	-- Halloween Smode
	if EVENT_HALLOWEEN then
		self:loadImportTXD("files/models/ghost.txd", 260)
		self:loadImportDFF("files/models/ghost.dff", 260)

		self:loadImportCOL("files/models/headstone.col", 3878)
		self:loadImportTXD("files/models/headstone.txd", 3878)
		self:loadImportDFF("files/models/headstone.dff", 3878)
	end

	if EVENT_CHRISTMAS then
		self:loadImportCOL("files/models/XmasTree1.col", 6972)
		self:loadImportTXD("files/models/XmasTree1.txd", 6972)
		self:loadImportDFF("files/models/XmasTree1.dff", 6972)

		self:loadImportCOL("files/models/XmasBox.col", 3878)
		self:loadImportTXD("files/models/XmasBox.txd", 3878)
		self:loadImportDFF("files/models/XmasBox.dff", 3878)
	end

	--Easter Event:
	self:loadImportCOL("files/models/easter_egg.col", 1933)
	self:loadImportTXD("files/models/easter_egg.txd", 1933)
	self:loadImportDFF("files/models/easter_egg.dff", 1933)
	self:loadImportTXD("files/models/Wearables/BunnyEars.txd", 1934)
	self:loadImportDFF("files/models/Wearables/BunnyEars.dff", 1934)

	self:loadImportCOL("files/models/pumpkin.col", 1935)
	self:loadImportTXD("files/models/pumpkin.txd", 1935)
	self:loadImportDFF("files/models/pumpkin.dff", 1935)

	--shader
	self:loadShader("RoadSigns/parking1.png", "noparking2_128")
	self:loadShader("RoadSigns/parking2.png", "roadsign01_128")
	--self:loadShader("RoadSigns/trans.png", "txgrass0_1")
	self:loadShader("Other/trans.png", "txgrass1_1")
end

function CustomModelManager:loadImportDFF(filePath, modelId)
	local dff = engineLoadDFF(filePath, 0)
	self.m_DFFMap[modelId] = dff
	return dff and engineReplaceModel(dff, modelId)
end

function CustomModelManager:loadImportTXD(filePath, modelId)
	local txd = engineLoadTXD(filePath)
	self.m_TXDMap[modelId] = txd
	return txd and engineImportTXD(txd, modelId), txd
end

function CustomModelManager:loadImportCOL(filePath, modelId)
	local col = engineLoadCOL(filePath)
	self.m_COLMap[modelId] = col
	return col and engineReplaceCOL(col, modelId)
end

function CustomModelManager:setLODDistance(modelId, distance)
	engineSetModelLODDistance(modelId, distance)
end

function CustomModelManager:restoreModel(modelId)
	local success = engineRestoreModel(modelId)
	if success then
		if self.m_DFFMap[modelId] then
			if isElement(self.m_DFFMap[modelId]) then destroyElement(self.m_DFFMap[modelId]) end
			self.m_DFFMap[modelId] = nil
		end
		if self.m_TXDMap[modelId] then
			if isElement(self.m_TXDMap[modelId]) then destroyElement(self.m_TXDMap[modelId]) end
			self.m_TXDMap[modelId] = nil
		end
	end
	return success
end

function CustomModelManager:restoreCOL(modelId)
	if self.m_COLMap[modelId] then
		if isElement(self.m_COLMap[modelId]) then destroyElement(self.m_COLMap[modelId]) end
		self.m_COLMap[modelId] = nil
		return engineRestoreCOL(modelId)
	end
end

function CustomModelManager:unloadAllModels()
	for modelId in pairs(self.m_COLMap) do
		self:restoreCOL(modelId)
	end
	for modelId in pairs(self.m_DFFMap) do
		self:restoreModel(modelId)
	end
	for modelId in pairs(self.m_TXDMap) do
		self:restoreModel(modelId)
	end
	for _, instance in pairs(self.m_TextureReplaces) do
		delete(instance)
	end
end

function CustomModelManager:loadShader(filePath, textureName)
	table.insert(self.m_TextureReplaces, StaticFileTextureReplacer:new(filePath, textureName, {}))
end

function CustomModelManager:destructor()
	self:unloadAllModels()
end


--[[addCommandHandler("load", function()
	iprint(CustomModelManager:getSingleton():loadImportCOL("files/models/medic.col", 4027))
	iprint(CustomModelManager:getSingleton():loadImportTXD("files/models/medic.txd", 4027))
	iprint(CustomModelManager:getSingleton():loadImportDFF("files/models/medic.dff", 4027))
	CustomModelManager:getSingleton():setLODDistance(4027, 500)

	iprint(CustomModelManager:getSingleton():loadImportCOL("files/models/medicLOD.col", 4076))
	iprint(CustomModelManager:getSingleton():loadImportTXD("files/models/medicLOD.txd", 4076))
	iprint(CustomModelManager:getSingleton():loadImportDFF("files/models/medicLOD.dff", 4076))
end)
addCommandHandler("unload", function()
	iprint(CustomModelManager:getSingleton():restoreModel(4027))
	iprint(CustomModelManager:getSingleton():restoreCOL(4027))
	iprint(CustomModelManager:getSingleton():restoreModel(4076))
	iprint(CustomModelManager:getSingleton():restoreCOL(4076))
end)]]
