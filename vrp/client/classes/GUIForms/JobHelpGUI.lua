-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/JobHelpGUI.lua
-- *  PURPOSE:     Job GUI class
-- *
-- ****************************************************************************
JobHelpGUI = inherit(GUIForm)
inherit(Singleton, JobHelpGUI)
local jobNames = 
{
	{"Trashman",1
	{"Roadsweeper",0},
	{"Lumberjack",3},
	{"Farmer",4},
	{"Pizza",0},
	{"HeliTransport",0},
	{"Logistiker",0},
	{"Gabelstapler",0},
	{"Schatzsucher",0},
}

function JobHelpGUI:constructor()
	GUIForm.constructor(self, screenWidth/2-300, screenHeight/2-230, 600, 460)

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, "JobGUI", true, true, self)
	self.m_InfoLabel = GUILabel:new(30, 180, 540, 200, "Hier eine Liste von Jobs!", self)
	self.m_InfoLabel:setFont(VRPFont(24))
	
	self.m_JobList = GUIGridList:new(5, 35, self.m_Width-10, self.m_Height-60, self)
	self.m_JobList:addColumn(_"Jobs", 1)
	local pos
	for index, job in pairs(JobManager:getSingleton().m_Jobs) do 
		pos = job.m_Ped:getPosition()
		item = self.m_JobList:addItem(jobNames[index][1].." - Level "..jobNames[index][2])
		item.onLeftDoubleClick = function () self:showJob( pos, job.m_Ped ) end
	end
end

function JobHelpGUI:destructor()
	GUIForm.destructor(self)
end


function JobHelpGUI:showJob( pos, ped )
	if self.m_JobBlip then 
		delete(self.m_JobBlip)
	end
	self.m_JobBlip = Blip:new("Marker.png", pos.x, pos.y,9999)
	self.m_JobBlip:attachTo(ped)
end
