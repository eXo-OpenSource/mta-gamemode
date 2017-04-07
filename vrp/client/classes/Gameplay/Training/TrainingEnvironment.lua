-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Gameplay/Training/TrainingEnvironment.lua
-- *  PURPOSE:     Training Environment
-- *
-- ****************************************************************************

TrainingEnvironment = inherit(Object)

-- Create an dummy object with the ground id so we can get its bounds via getElementBoundingBox then destroy it
local CONST_GROUND_ID = 8661
local DUMMY_OBJ_GROUND = createObject ( CONST_GROUND_ID,0,0,3) 
local CONST_GROUND_BOX = {getElementBoundingBox ( DUMMY_OBJ_GROUND )}
destroyElement(DUMMY_OBJ_GROUND)
local ORIGIN_VECTOR = {0,0,300}
local x_max = 50 
local y_max = 50


currentActiveEnviroment = nil --// if you just allow one enviroment at a time

function TrainingEnvironment:constructor( dim, bIsAlpha, bGroundTexture )
	outputDebugString("Trying to generate enviroment at "..dim.."!", 3, 50, 200, 200)
	self.m_Env = {}
	self.m_bIsAlpha = bIsAlpha
	self:createGround()
	if bGroundTexture then 
		self.m_TexReplace = TextureReplace:new("greyground256", bGroundTexture)
	end
	self:setEnvDimension(dim)
	self.m_Dimension = dim
end

function TrainingEnvironment:createGround() 
	local x,y,z = unpack(ORIGIN_VECTOR)
	local minx, miny,minz,maxx,maxy,maxz = CONST_GROUND_BOX[1],CONST_GROUND_BOX[2],CONST_GROUND_BOX[3],CONST_GROUND_BOX[4],CONST_GROUND_BOX[5],CONST_GROUND_BOX[6]
	local bound_x = math.floor(math.abs(minx) + math.abs( maxx) )-0.5
	local bound_y = math.floor(math.abs(miny) + math.abs( maxy) )-0.5
	local bound_z = math.floor(math.abs(minz) + math.abs( maxz) )-0.5
	local width_area = bound_x * x_max 
	local height_area = bound_y * y_max
	local col_width = 0
	local col_height = 0
	self.m_CenterPos = {}
	for i_x = 1, x_max  do 
		for i_y = 1, y_max do 
			self.m_Env[#self.m_Env+1] = createObject(CONST_GROUND_ID, (x+(bound_x+0.48)*i_x), (y+(bound_y+0.5)*i_y), z)
			col_width = col_width + bound_x+0.48
			col_height = col_height + bound_y+0.5
			if bIsAlpha then
				setElementAlpha(self.m_Env[#self.m_Env], 0)
			end
			if i_x == math.floor(x_max/2) then 
				if i_y == math.floor(y_max/2) then 
					self.m_CenterPos = {x+bound_x*i_x, y+bound_y*i_y, z}
				end
			end
		end
	end
	self.m_Col = createColCuboid ( x, y, z, col_width, col_height, 20)
	addEventHandler("onClientColShapeHit", self.m_Col, bind(self.Event_OnColShapeHit, self))
	addEventHandler("onClientColShapeLeave", self.m_Col, bind(self.Event_OnColShapeLeave, self))
end

function TrainingEnvironment:setEnvDimension( dim, int) 
	if dim then
		local obj
		for i = 1, # self.m_Env do 
			obj = self.m_Env[i]
			if obj then 
				setElementDimension(obj, dim)
				if int then 
					setElementInterior(obj, int)
				end
			end
		end
	end
end

function TrainingEnvironment:Event_OnColShapeHit( element, dimension)
	if localPlayer == element then 
		if dimension then 
			self:spawnIntoTraining()
		end
	end
end

function TrainingEnvironment:Event_OnColShapeLeave()
	if localPlayer == element then 
		if dimension then 

		end
	end
end

function TrainingEnvironment:spawnIntoTraining() 
	setSkyGradient(0, 0, 0, 0, 0, 0)
	setFarClipDistance(300)
	setWeather(20)
	setCloudsEnabled(false)
	local x,y,z = unpack(self.m_CenterPos)
	setElementAlpha(localPlayer, 255)
	setElementPosition(localPlayer, x,y,z+1 )
	setElementDimension(localPlayer, self.m_Dimension)
end

function TrainingEnvironment:removeFromTraining()
	resetSkyGradient()
	resetFarClipDistance()
	setWeather(1)
	engineRestoreModel(7)
	setCloudsEnabled(true)
end

function TrainingEnvironment:destructor()
	if self.m_Env then 
		local obj
		for i = 1,#self.m_Env do 
			obj = self.m_Env[i]
			destroyElement(obj)
		end
	end
	if self.m_TexReplace then 
		delete(self.m_TexReplace)
	end
end

addEvent("TrainingEnv:generate", true)
addEventHandler("TrainingEnv:generate", root, function( dim, isAlpha, texName) 
	if currentActiveEnviroment then 
		delete(currentActiveEnviroment)
	end
	currentActiveEnviroment = TrainingEnvironment:new(dim, isAlpha, texName)
end)