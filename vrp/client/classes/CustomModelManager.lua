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

	self:createObjectsForMods()

	--world objects
	--self:loadImportCOL("files/models/buildings/mech.col", 7520)
	--self:loadImportDFF("files/models/buildings/mech.dff", 7520)

	--Kart-Track
	self:loadImportCOL("files/models/buildings/kart.col", 13083)
	self:loadImportTXD("files/models/buildings/kart.txd", 13083)
	self:loadImportDFF("files/models/buildings/kart.dff", 13083)
	self:loadImportCOL("files/models/objects/bed.col", 1879)
	self:loadImportTXD("files/models/objects/bed.txd", 1879)
	self:loadImportDFF("files/models/objects/bed.dff", 1879)
	-- Army Fence 1
	self:loadImportCOL("files/models/objects/a51fencing.col", 16094)
	self:loadImportTXD("files/models/objects/a51fencing.txd", 16094)
	self:loadImportDFF("files/models/objects/a51fencing.dff", 16094)
	-- Army Fence 2
	self:loadImportCOL("files/models/objects/a51fensin.col", 974)
	self:loadImportTXD("files/models/objects/a51fencing.txd", 974)
	self:loadImportDFF("files/models/objects/a51fensin.dff", 974)
	-- Ammunation Street hedge
	self:loadImportCOL("files/models/objects/hedge01_law.col", 6046)
	self:loadImportDFF("files/models/objects/hedge01_law.dff", 6046)
	self:setLODDistance(6046, 500)

	--bank
	self:loadImportTXD("files/models/buildings/casino_heist/bank_fence.txd", 8481)
	self:loadImportCOL("files/models/buildings/casino_heist/bank_fence.col", 8481)

	--fishing shop
	self:loadImportCOL("files/models/buildings/fishshop.col", 6289)
	self:loadImportTXD("files/models/buildings/fishshop.txd", 6289)
	self:loadImportDFF("files/models/buildings/fishshop.dff", 6289)
	--ammunation
	self:loadImportCOL("files/models/buildings/ammunation.col", 4552)
	self:loadImportDFF("files/models/buildings/ammunation.dff", 4552)
	self:loadImportCOL("files/models/buildings/ammunation_int.col", 18049)
	self:loadImportDFF("files/models/buildings/ammunation_int.dff", 18049)
	self:loadImportCOL("files/models/buildings/ammunation2.col", 5106)
	self:loadImportDFF("files/models/buildings/ammunation2.dff", 5106)
	self:loadImportCOL("files/models/buildings/ammunation2_int.col", 18033)
	self:loadImportDFF("files/models/buildings/ammunation2_int.dff", 18033)

	--ferris wheel
	self:loadImportCOL("files/models/objects/ferrisWheel/ferrisBase.col", FERRIS_IDS.Base)
	self:loadImportDFF("files/models/objects/ferrisWheel/ferrisBase.dff", FERRIS_IDS.Base)
	self:loadImportTXD("files/models/objects/ferrisWheel/ferris.txd", FERRIS_IDS.Gond)
	self:loadImportCOL("files/models/objects/ferrisWheel/ferrisGond.col", FERRIS_IDS.Gond)
	self:loadImportDFF("files/models/objects/ferrisWheel/ferrisGond.dff", FERRIS_IDS.Gond)
	self:loadImportCOL("files/models/objects/ferrisWheel/ferrisWheel.col", FERRIS_IDS.Wheel)
	self:loadImportDFF("files/models/objects/ferrisWheel/ferrisWheel.dff", FERRIS_IDS.Wheel)
	self:loadImportCOL("files/models/objects/fence.col", 1866)
	self:loadImportTXD("files/models/objects/fence.txd", 1866)
	self:loadImportDFF("files/models/objects/fence.dff", 1866)

	-- fuel nozzle
	self:loadImportCOL("files/models/wearables/fuelnozzle.col", 1909)
	self:loadImportTXD("files/models/wearables/fuelnozzle.txd", 1909)
	self:loadImportDFF("files/models/wearables/fuelnozzle.dff", 1909)

	self:loadImportDFF("files/models/objects/gasstation.dff", 1676)

	--other objects
	self:loadImportTXD("files/models/objects/Singleweed.txd", 1870)
	self:loadImportDFF("files/models/objects/Singleweed.dff", 1870)
	self:setLODDistance(1870, 50)
	-- Blitzer
	self:loadImportCOL("files/models/objects/blitzer.col", 3902)
	self:loadImportTXD("files/models/objects/blitzer.txd", 3902)
	self:loadImportDFF("files/models/objects/blitzer.dff", 3902)
	-- Mushrooms
	self:loadImportCOL("files/models/objects/worldItems/mushroom01.col", 1882)
	self:loadImportTXD("files/models/objects/worldItems/mushrooms.txd", 1882)
	self:loadImportDFF("files/models/objects/worldItems/mushroom01.dff", 1882)
	self:loadImportCOL("files/models/objects/worldItems/mushroom02.col", 1947)
	self:loadImportTXD("files/models/objects/worldItems/mushrooms.txd", 1947)
	self:loadImportDFF("files/models/objects/worldItems/mushroom02.dff", 1947)
	--Wanted board of LSPD
	self:loadImportCOL("files/models/objects/mostWanted.col", 1903)
	self:loadImportTXD("files/models/objects/mostWanted.txd", 1903)
	self:loadImportDFF("files/models/objects/mostWanted.dff", 1903)
	--water can
	self:loadImportCOL("files/models/wearables/waterCan.col", 1902)
	self:loadImportTXD("files/models/wearables/waterCan.txd", 1902)
	self:loadImportDFF("files/models/wearables/waterCan.dff", 1902)
	-- Helmet FullFace
	self:loadImportTXD("files/models/wearables/helmet.txd", 2052)
	self:loadImportDFF("files/models/wearables/helmet.dff", 2052)
	-- Helmet Cross
	self:loadImportCOL("files/models/wearables/crosshelmet.col", 1924)
	self:loadImportTXD("files/models/wearables/crosshelmet.txd", 1924)
	self:loadImportDFF("files/models/wearables/crosshelmet.dff", 1924)
	-- Helmet Biker ( pot )
	self:loadImportTXD("files/models/wearables/bikerhelmet.txd", 3911)
	self:loadImportDFF("files/models/wearables/bikerhelmet.dff", 3911)
	-- Gas Mask
	self:loadImportTXD("files/models/wearables/gasmask.txd", 3890)
	self:loadImportDFF("files/models/wearables/gasmask.dff", 3890)
	-- Kevlar
	self:loadImportTXD("files/models/wearables/kevlar.txd", 3916)
	self:loadImportDFF("files/models/wearables/kevlar.dff", 3916)
	-- Dufflebag
	self:loadImportTXD("files/models/wearables/dufflebag.txd", 3915)
	self:loadImportDFF("files/models/wearables/dufflebag.dff", 3915)
	-- Swatshield
	self:loadImportCOL("files/models/wearables/riot_shield.col",1631)
	self:loadImportTXD("files/models/wearables/riot_shield.txd",1631)
	self:loadImportDFF("files/models/wearables/riot_shield.dff",1631)
	-- Tardis EasterEgg
	self:loadImportCOL("files/models/wearables/pickaxe.col", 1858)
	self:loadImportTXD("files/models/wearables/pickaxe.txd", 1858)
	self:loadImportDFF("files/models/wearables/pickaxe.dff", 1858)
	self:loadImportCOL("files/models/wearables/donut.col", 1915)
	self:loadImportTXD("files/models/wearables/donut.txd", 1915)
	self:loadImportDFF("files/models/wearables/donut.dff", 1915)
	self:loadImportCOL("files/models/wearables/FishingRod.col", 1826)
	self:loadImportTXD("files/models/wearables/FishingRod.txd", 1826)
	self:loadImportDFF("files/models/wearables/FishingRod.dff", 1826)
	self:loadImportTXD("files/models/objects/tardis.txd", 1881)
	self:loadImportDFF("files/models/objects/tardis.dff", 1881)

	self:loadImportDFF("files/models/piss.dff", 1904)
	--wood
	self:loadImportCOL("files/models/objects/holzstamm.col", 837)
	self:loadImportTXD("files/models/objects/holzstamm.txd", 837)
	self:loadImportDFF("files/models/objects/holzstamm.dff", 837)


	--pickups
	self:loadImportTXD("files/models/pickups/exo_logo.txd", 2836)
	self:loadImportDFF("files/models/pickups/exo_logo.dff", 2836)
	self:loadImportTXD("files/models/pickups/arrow.txd", 1868)
	self:loadImportDFF("files/models/pickups/arrow.dff", 1868)

	--vehicles
	--vehicle extensions
	self:loadImportCOL("files/models/vehicles/extensions/lightbar.col", 1921)
	self:loadImportTXD("files/models/vehicles/extensions/lightbar.txd", 1921)
	self:loadImportDFF("files/models/vehicles/extensions/lightbar.dff", 1921)
	self:loadImportCOL("files/models/vehicles/extensions/fire_ladder.col", 1931)
	self:loadImportTXD("files/models/vehicles/extensions/fire_ladder.txd", 1931)
	self:loadImportDFF("files/models/vehicles/extensions/fire_ladder.dff", 1931)
	self:loadImportCOL("files/models/vehicles/extensions/fire_main.col", 1932)
	self:loadImportTXD("files/models/vehicles/extensions/fire_main.txd", 1932)
	self:loadImportDFF("files/models/vehicles/extensions/fire_main.dff", 1932)
	self:loadImportTXD("files/models/vehicles/extensions/taxi_sign.txd", 1853)
	self:loadImportDFF("files/models/vehicles/extensions/taxi_sign.dff", 1853)

	self:loadImportDFF("files/models/vehicles/dozer.dff", 486)
	self:loadImportDFF("files/models/vehicles/dumper.dff", 406)
	self:loadImportTXD("files/models/vehicles/sandking.txd", 495)
	self:loadImportDFF("files/models/vehicles/sandking.dff", 495)
	self:loadImportTXD("files/models/vehicles/uranus.txd", 558)
	self:loadImportDFF("files/models/vehicles/uranus.dff", 558)
	self:loadImportDFF("files/models/vehicles/dft30.dff", 578)

	-- Firework
	self:loadImportCOL("files/models/firework.col", 1941)
	self:loadImportTXD("files/models/firework.txd", 1941)
	self:loadImportDFF("files/models/firework.dff", 1941)

	--skins
	-- Zombie
	self:loadImportTXD("files/models/skins/zombie.txd", 310)
	self:loadImportDFF("files/models/skins/zombie.dff", 310)
	self:loadImportTXD("files/models/skins/santaclaus.txd", 244)
	self:loadImportDFF("files/models/skins/santaclaus.dff", 244)
	-- Halloween Smode
	if EVENT_HALLOWEEN then
		self:loadImportTXD("files/models/skins/ghost.txd", 260)
		self:loadImportDFF("files/models/skins/ghost.dff", 260)
		self:loadImportCOL("files/models/objects/headstone.col", 3878)
		self:loadImportTXD("files/models/objects/headstone.txd", 3878)
		self:loadImportDFF("files/models/objects/headstone.dff", 3878)
	end

	if EVENT_CHRISTMAS then
		self:loadImportCOL("files/models/objects/XmasTree1.col", 6972)
		self:loadImportTXD("files/models/objects/XmasTree1.txd", 6972)
		self:loadImportDFF("files/models/objects/XmasTree1.dff", 6972)

		self:loadImportCOL("files/models/objects/XmasBox.col", 3878)
		self:loadImportTXD("files/models/objects/XmasBox.txd", 3878)
		self:loadImportDFF("files/models/objects/XmasBox.dff", 3878)

		self:loadImportCOL("files/models/objects/fortuneWheel.col", 1895)
		self:loadImportTXD("files/models/objects/fortuneWheel.txd", 1895)
		self:loadImportDFF("files/models/objects/fortuneWheel.dff", 1895)

		self:loadImportTXD("files/models/skins/snowman.txd", 260)
		self:loadImportDFF("files/models/skins/snowman.dff", 260)

		self:loadImportTXD("files/models/vehicles/reindeerSledge.txd", 609)
		self:loadImportDFF("files/models/vehicles/reindeerSledge.dff", 609)
	end

	--Easter Event:
	self:loadImportCOL("files/models/objects/worldItems/easter_egg.col", 1933)
	self:loadImportTXD("files/models/objects/worldItems/easter_egg.txd", 1933)
	self:loadImportDFF("files/models/objects/worldItems/easter_egg.dff", 1933)
	self:loadImportTXD("files/models/wearables/BunnyEars.txd", 1934)
	self:loadImportDFF("files/models/wearables/BunnyEars.dff", 1934)

	self:loadImportCOL("files/models/objects/worldItems/pumpkin.col", 1935)
	self:loadImportTXD("files/models/objects/worldItems/pumpkin.txd", 1935)
	self:loadImportDFF("files/models/objects/worldItems/pumpkin.dff", 1935)

	self:loadImportTXD("files/models/wearables/ChristmasHat.txd", 1936)
	self:loadImportDFF("files/models/wearables/ChristmasHat.dff", 1936)

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
	if type(modelId) == "table" then
		if not txd then return false, txd end
		for i, id in pairs(modelId) do
			engineImportTXD(txd, id)
		end
		return true, txd
	else
		return txd and engineImportTXD(txd, modelId), txd
	end
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

function CustomModelManager:createObjectsForMods()
	local objs = {
		--objid, radius, x, y, z, lodid
		{4027, 48.207302, 1783.1016, -1702.3047, 14.35156, 4076}, --rescue
		{4552, 75.657227, 1391.125, -1318.0937, 24.66406, 4632}, --ammu nation central
	}
	for i,v in pairs(objs) do
		removeWorldModel(v[1], v[2], v[3], v[4], v[5])
		local obj = createObject(v[1], v[3], v[4], v[5])
		if v[6] then --lod
			removeWorldModel(v[6], v[2], v[3], v[4], v[5])
			setLowLODElement(obj, createObject(v[6], v[3], v[4], v[5], 0, 0, 0, true))
		end
	end
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
