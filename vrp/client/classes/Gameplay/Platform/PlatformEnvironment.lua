-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Gameplay/Training/PlatformEnvironment.lua
-- *  PURPOSE:     Training Environment
-- *
-- ****************************************************************************

PlatformEnvironment = inherit(Object)

-- Create an dummy object with the ground id so we can get its bounds via getElementBoundingBox then destroy it
local CONST_GROUND_ID = 8661 --// "greyground256"
local DUMMY_OBJ_GROUND = createObject ( CONST_GROUND_ID,0,0,3)
local CONST_GROUND_BOX = {getElementBoundingBox ( DUMMY_OBJ_GROUND )}
destroyElement(DUMMY_OBJ_GROUND)
local ORIGIN_VECTOR = {0,0,4000}
local x_max = 50
local y_max = 50


currentActiveEnviroment = nil --// if you just allow one enviroment at a time

function updateBounds( object )
	CONST_GROUND_ID = object
	DUMMY_OBJ_GROUND = createObject ( CONST_GROUND_ID,0,0,3)
	CONST_GROUND_BOX = {getElementBoundingBox ( DUMMY_OBJ_GROUND )}
	destroyElement(DUMMY_OBJ_GROUND)
	ORIGIN_VECTOR = {0,0,4000}
	x_max = 50
	y_max = 50
end

function PlatformEnvironment:constructor( x, y, z, width, height, dim, bIsAlpha, bGroundTexture, bReplaceName, iObject)
	outputDebugString("Trying to generate enviroment at "..dim.."!", 3, 50, 200, 200)
	if iObject then
		updateBounds(iObject)
	end
	if bGroundTexture and bReplaceName then
		self.m_TexReplace = TextureReplace:new(bReplaceName, bGroundTexture)
	end
	self.m_HitRespawn = true
	self.m_OriginVector = {x,y,z}
	self.m_Env = {}
	self.m_EnvWalls = {}
	self.m_bIsAlpha = bIsAlpha
	self.m_Width = width or x_max
	self.m_Height = height or  y_max
	self:createGround()
	self:setEnvDimension(dim)
	self.m_Dimension = dim
	self:setWallAlpha()

end

function PlatformEnvironment:createGround()
	local x,y,z = unpack(self.m_OriginVector)
	local minx, miny,minz,maxx,maxy,maxz = CONST_GROUND_BOX[1],CONST_GROUND_BOX[2],CONST_GROUND_BOX[3],CONST_GROUND_BOX[4],CONST_GROUND_BOX[5],CONST_GROUND_BOX[6]
	local bound_x = math.floor(math.abs(minx) + math.abs( maxx) )-0.5
	local bound_y = math.floor(math.abs(miny) + math.abs( maxy) )-0.5
	local bound_z = math.floor(math.abs(minz) + math.abs( maxz) )-0.5
	local width_area = bound_x * self.m_Width
	local height_area = bound_y * self.m_Height
	local col_width = 0
	local col_height = 0
	self.m_CenterPos = {}
	local isWall
	local bound_x_off = bound_x+0.48
	local bound_y_off = bound_y+0.5
	local lx,ly,lz
	for i_x = 1, self.m_Width  do
		for i_y = 1,  self.m_Height do
			self.m_Env[#self.m_Env+1] = createObject(CONST_GROUND_ID, (x+(bound_x_off)*i_x), (y+(bound_y_off)*i_y), z)
			outputChatBox((x+(bound_x_off)*i_x)..", "..(y+(bound_y_off)*i_y)..", "..z)
			setElementDoubleSided(self.m_Env[#self.m_Env], true)
			col_width = col_width + bound_x+0.48
			col_height = col_height + bound_y+0.5
			if bIsAlpha then
				setElementAlpha(self.m_Env[#self.m_Env], 0)
			end
			if i_x == math.floor(self.m_Width/2) then
				if i_y == math.floor( self.m_Height/2) then
					self.m_CenterPos = {x+bound_x*i_x, y+bound_y*i_y, z}
				end
			end
			lx,ly,lz = getElementPosition( self.m_Env[#self.m_Env]  )
			isWall = false
			if i_y ==  self.m_Height then
				self.m_EnvWalls[#self.m_EnvWalls+1] = createObject (CONST_GROUND_ID, lx,ly+(bound_y_off*0.5),lz,90,0,180)
				setElementDoubleSided(self.m_EnvWalls[#self.m_EnvWalls], true)
				isWall = true
				for i = 1,5 do
					self.m_EnvWalls[#self.m_EnvWalls+1] = createObject (CONST_GROUND_ID,  lx,ly+(bound_y_off*0.5),lz+(bound_y_off*i),90,0,180)
					setElementDoubleSided(self.m_EnvWalls[#self.m_EnvWalls], true)
				end
			end
			if i_y == 1 then
				self.m_EnvWalls[#self.m_EnvWalls+1] = createObject (CONST_GROUND_ID, lx,ly-(bound_y_off*0.5),lz,90,0,0)
				setElementDoubleSided(self.m_EnvWalls[#self.m_EnvWalls], true)
				isWall = true
				for i = 1,5 do
					self.m_EnvWalls[#self.m_EnvWalls+1] = createObject (CONST_GROUND_ID, lx,ly-(bound_y_off*0.5),lz+(bound_y_off*i),90,0,0)
					setElementDoubleSided(self.m_EnvWalls[#self.m_EnvWalls], true)
				end
			end
			if i_x == 1 then
				self.m_EnvWalls[#self.m_EnvWalls+1] = createObject (CONST_GROUND_ID, lx-(bound_x_off*0.5),ly,lz,90,0,90-180)
				setElementDoubleSided(self.m_EnvWalls[#self.m_EnvWalls], true)
				isWall = true
				for i = 1,5 do
					self.m_EnvWalls[#self.m_EnvWalls+1] = createObject (CONST_GROUND_ID, lx-(bound_x_off*0.5),ly,lz+(bound_y_off*i),90,0,90-180)
					setElementDoubleSided(self.m_EnvWalls[#self.m_EnvWalls], true)
				end
			end
			if i_x == self.m_Width  then
				self.m_EnvWalls[#self.m_EnvWalls+1] = createObject (CONST_GROUND_ID, lx+(bound_x_off*0.5),ly,lz,90,0,90)
				setElementDoubleSided(self.m_EnvWalls[#self.m_EnvWalls], true)
				isWall = true
				for i = 1,5 do
					self.m_EnvWalls[#self.m_EnvWalls+1] = createObject (CONST_GROUND_ID, lx+(bound_x_off*0.5),ly,lz+(bound_y_off*i),90,0,90)
					setElementDoubleSided(self.m_EnvWalls[#self.m_EnvWalls], true)
				end
			end
		end
	end
	self.m_Col = createColCuboid ( x, y, z, col_width, col_height, 20)
	addEventHandler("onClientColShapeHit", self.m_Col, bind(self.Event_OnColShapeHit, self))
	addEventHandler("onClientColShapeLeave", self.m_Col, bind(self.Event_OnColShapeLeave, self))
end

function PlatformEnvironment:parseMap( tMap )
	if self.m_CurrentMap then
		self:destroyMap()
	end
	self.m_CurrentMap = {}
	self.m_CurrentMap["object"] = {}
	self.m_CurrentMap["spawn"] = {}
	local node, obj, pos, rot
	for i = 1, #tMap do
		node = tMap[i]
		obj, type_, pos, rot = tMap[1], tMap[2], tMap[3], tMap[4]
		if type_ == "object" then
			if obj and pos and rot then
				self.m_CurrentMap["object"][#self.m_CurrentMap["object"]+1] = createObject( obj, pos[1], pos[2], pos[3], rot[1], rot[2], rot[3])
				setElementDimension(self.m_CurrentMap["object"][#self.m_CurrentMap["object"]], self.m_Dimension)
			end
		elseif type_ == "spawn" then
			if pos and rot then
				self.m_CurrentMap["spawn"][#self.m_CurrentMap["spawn"]+1] = {pos,rot}
			end
		end
	end
end

function PlatformEnvironment:destroyMap()
	if self.m_CurrentMap then
		local obj
		if self.m_CurrentMap["object"] then
			for i = 1,#self.m_CurrentMap["object"] do
				obj = self.m_CurrentMap[i]
				if obj then
					if isElement(obj) then
						destroyElement(obj)
					end
				end
			end
		end
	end
	self.m_CurrentMap = {}
end

function PlatformEnvironment:setEnvDimension( dim, int)
	if dim then
		local obj
		for i = 1, #self.m_Env do
			obj = self.m_Env[i]
			if obj then
				setElementDimension(obj, dim)
				if int then
					setElementInterior(obj, int)
				end
			end
		end
		for i = 1, #self.m_EnvWalls do
			obj = self.m_EnvWalls[i]
			if obj then
				setElementDimension(obj, dim)
				if int then
					setElementInterior(obj, int)
				end
			end
		end
	end
end

function PlatformEnvironment:setWallAlpha()
	local obj
	for i = 1,#self.m_EnvWalls do
		obj = self.m_EnvWalls[i]
		setElementAlpha(obj,0)
	end
end

function PlatformEnvironment:Event_OnColShapeHit( element, dimension)
	if self.m_HitRespawn then
		if localPlayer == element then
			if dimension then
				self:spawnIntoPlatform()
			end
		end
	end
end

function PlatformEnvironment:Event_OnColShapeLeave()
	if localPlayer == element then
		if dimension then

		end
	end
end

function PlatformEnvironment:spawnIntoPlatform()
	--[[
	if self.m_Shader then
		delete(self.m_Shader)
	end
	self.m_Shader =  CylinderShader:new()
	--]]
	--setSkyGradient(0, 0, 0, 0, 0, 0)
	--setFarClipDistance(300)
	--setWeather(20)
	--setCloudsEnabled(false)
	--[[
	local txd = engineLoadTXD("files/models/fbi.txd")
	engineImportTXD(txd,7)
	local dff = engineLoadDFF("files/models/fbi.dff")
	engineReplaceModel(dff,7)
	]]
	local x,y,z = unpack(self.m_CenterPos)
	setElementAlpha(localPlayer, 255)
	setElementPosition(localPlayer, x,y,z+2 )
	setElementDimension(localPlayer, self.m_Dimension)
	HUDRadar:getSingleton():hide()
	showChat(false)
end

function PlatformEnvironment:removeFromPlatform()
	resetSkyGradient()
	resetFarClipDistance()
	setWeather(1)
	engineRestoreModel(7)
	setCloudsEnabled(true)
	--[[
	if self.m_Shader then
		delete(self.m_Shader)
	end
	--]]
	HUDRadar:getSingleton():show()
	showChat(true)
	engineRestoreModel(7)
end

function PlatformEnvironment:toggleWallCollission(state)
	for i = 1,#self.m_EnvWalls do
		obj = self.m_EnvWalls[i]
		if isElement(obj) then
			obj:setCollisionsEnabled(state)
		end
	end
end

function PlatformEnvironment:toggleColShapeHitRespawn(state)
	self.m_HitRespawn = state
end

function PlatformEnvironment:rotateTile( index, time)
	if index and time then
		if self.m_Env[index] then
			local x,y,z = getElementPosition(self.m_Env[index])
			moveObject(self.m_Env[index], time, x, y, z, 360, 0, 0, "Linear")
		end
	end
end

function PlatformEnvironment:resetAllTiles()
	local obj
	for i = 1,#self.m_Env do
		obj = self.m_Env[i]
		stopObject(obj)
		setElementRotation(obj, 0, 0, 0)
	end
end

function PlatformEnvironment:destructor()
	if self.m_Env then
		local obj
		for i = 1,#self.m_Env do
			obj = self.m_Env[i]
			destroyElement(obj)
		end
		for i = 1,#self.m_EnvWalls do
			obj = self.m_EnvWalls[i]
			destroyElement(obj)
		end
	end
	if self.m_TexReplace then
		delete(self.m_TexReplace)
	end
end

addEvent("PlatformEnv:generate", true)
addEventHandler("PlatformEnv:generate", root, function( x, y, z, width, height, dim, isAlpha, texPath, texReplace, iObject)
	if currentActiveEnviroment then
		delete(currentActiveEnviroment)
	end
	currentActiveEnviroment = PlatformEnvironment:new(x, y, z, width, height, dim, isAlpha, texPath, texReplace, iObject)
end)

addEvent("PlatformEnv:toggleWallCollission", true)
addEventHandler("PlatformEnv:toggleWallCollission", root, function(state)
	currentActiveEnviroment:toggleWallCollission(state)
end)

addEvent("PlatformEnv:toggleColShapeHitRespawn", true)
addEventHandler("PlatformEnv:toggleColShapeHitRespawn", root, function(state)
	currentActiveEnviroment:toggleColShapeHitRespawn(state)
end)


addEvent("PlatformEnv:parseMap", true)
addEventHandler("PlatformEnv:parseMap", root, function( objTable )
	if currentActiveEnviroment then
		currentActiveEnviroment:parseMap( objTable )
	end
end)

addEvent("PlatformEnv:rotateTile", true)
addEventHandler("PlatformEnv:rotateTile", root, function( tileIndex, time )
	if currentActiveEnviroment then
		currentActiveEnviroment:rotateTile(tileIndex, time)
	end
end)

addEvent("PlatformEnv:resetAllTiles", true)
addEventHandler("PlatformEnv:resetAllTiles", root, function( tileIndex, time )
	if currentActiveEnviroment then
		currentActiveEnviroment:resetAllTiles()
	end
end)
