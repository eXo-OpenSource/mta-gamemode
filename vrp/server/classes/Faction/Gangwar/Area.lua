-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Faction/Gangwar/Area.lua
-- *  PURPOSE:     Gangwar Area Class
-- *
-- ****************************************************************************

Area = inherit(Object)

function Area:constructor( dataset )
	self.m_Name = dataset["Name"]
	self.m_ID = dataset["ID"]
	self.m_Owner = dataset["Besitzer"]
	self.m_LastAttack = dataset["lastAttack"]
	self.m_Position = {dataset["x"],dataset["y"],dataset["z"]}
	self.m_PositionRadar = {dataset["cX"],dataset["cY"],dataset["cX2"],dataset["cY2"]}
	self:createCenterCol( )
end	


function Area:createCenterCol() 
	local x,y,z = self.m_Position[1],self.m_Position[2],self.m_Position[3]
	self.m_CenterSphere = createColSphere(x,y,z,GANGWAR_CENTER_HOLD_RANGE)
end

function Area:attack()
	if not self.m_IsAttacked then 
		self.m_IsAttacked = true
		
	end
end

function Area:onCenterLeave( leaveElement,dimension )
	if dimension then 
		
	end
end

function Area:onCenterEnter( leaveElement,dimension )
	if dimension then 
		
	end
end

--// :attackEnd //
-- @param_desc: id = WinnerID
function Area:attackEnd( id ) 
	if self.m_IsAttacked then 
		self.m_IsAttacked = false
		self.m_Owner = id
		self:update()
	end
end

--// :update //
--// @desc: update sql values
function Area:update() 
	local sql_query = "UPDATE ??_gangwar Besitzer=?,lastAttack=?"
	sql:queryFetch(sql_query,sql:getPrefix(),self.m_Owner,self.m_LastAttack)
end

function Area:destructor() 
	--// Do some delete
	self:update()
end