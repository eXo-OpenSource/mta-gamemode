-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Gameplay/Training/TrainingEnvironment.lua
-- *  PURPOSE:     Training Environment
-- *
-- ****************************************************************************

TrainingEnvironment = inherit(Singleton)

local CONST_GROUND_ID = 8661
local DUMMY_OBJ_GROUND = createObject ( CONST_GROUND_ID,0,0,3) 
local CONST_GROUND_BOX = {getElementBoundingBox ( DUMMY_OBJ_GROUND )}
local ORIGIN_VECTOR = {0,0,300}
local x_max = 50 
local y_max = 50
function TrainingEnvironment:constructor( dim )
	outputDebugString("// Building Training-Env //")
	self.m_Env = {}
	self:createGround()
end

function TrainingEnvironment:createGround() 
	local x,y,z = unpack(ORIGIN_VECTOR)
	local minx, miny,minz,maxx,maxy,maxz = CONST_GROUND_BOX[1],CONST_GROUND_BOX[2],CONST_GROUND_BOX[3],CONST_GROUND_BOX[4],CONST_GROUND_BOX[5],CONST_GROUND_BOX[6]
	local bound_x = math.floor(math.abs(minx) + math.abs( maxx) )-0.5
	local bound_y = math.floor(math.abs(miny) + math.abs( maxy) )-0.5
	local bound_z = math.floor(math.abs(minz) + math.abs( maxz) )-0.5
	local width_area = bound_x * x_max 
	local height_area = bound_y * y_max
	self.m_CenterPos = {}
	for i_x = 1, x_max  do 
		for i_y = 1, y_max do 
			self.m_Env[#self.m_Env+1] = createObject(CONST_GROUND_ID, (x+(bound_x+0.3)*i_x), (y+(bound_y+0.3)*i_y), z)
			setElementAlpha(self.m_Env[#self.m_Env], 0)
			if i_x == math.floor(x_max/2) then 
				if i_y == math.floor(y_max/2) then 
					self.m_CenterPos = {x+bound_x*i_x, y+bound_y*i_y, z}
				end
			end
		end
	end
	self.m_Col = createColCuboid ( x+bound_x, y+bound_y, z, width_area+(0.3*x_max), height_area+(0.3*y_max), 20)
	addEventHandler("onClientColShapeHit", self.m_Col, bind(self.Event_OnColShapeHit, self))
	addEventHandler("onClientColShapeLeave", self.m_Col, bind(self.Event_OnColShapeLeave, self))
end

function TrainingEnvironment:Event_OnColShapeHit( element, dimension)
	if localPlayer == element then 
		if dimension then 
			setSkyGradient(200,200,200,200,200,200)
			setFarClipDistance(300)
			setWeather(20)
			local txd = engineLoadTXD("files/models/fbi.txd")
			engineImportTXD(txd, 7)
			local dff = engineLoadDFF ( "files/models/fbi.dff" )
			engineReplaceModel ( dff, 7 )
			local x,y,z = unpack(self.m_CenterPos)
			setElementPosition(localPlayer, x,y,z)
			local px,py
			local rot
			for i_dist = 1,5 do
				for i = 1, 9 do 
					
					px, py = getPointFromDistanceRotation(x+math.random(-2,2),y+math.random(-2,2),i_dist*4,  360 * (i/9))
					rot = findRotation( px,py, x,y)
					createPed(7, px,py,z,rot)
				end
			end
			setCloudsEnabled(false)
		end
	end
end

function TrainingEnvironment:Event_OnColShapeLeave()
	if localPlayer == element then 
		if dimension then 
			resetSkyGradient()
			resetFarClipDistance()
			setWeather(1)
			engineRestoreModel(7)
			setCloudsEnabled(true)
		end
	end
end

function TrainingEnvironment:destructor()

end