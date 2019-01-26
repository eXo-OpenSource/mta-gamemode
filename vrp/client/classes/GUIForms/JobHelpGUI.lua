-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/JobHelpGUI.lua
-- *  PURPOSE:     Job GUI class
-- *
-- ****************************************************************************
JobHelpGUI = inherit(GUIForm)
inherit(Singleton, JobHelpGUI)

function JobHelpGUI:constructor()
	GUIForm.constructor(self, screenWidth/2-300, screenHeight/2-230, 600, 460)

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, "Job Info", true, true, self)
	self.m_InfoLabel = GUILabel:new(5, 35, self.m_Width-10, 20, "Doppelklicke um die Position auf der Karte zu markieren!", self):setColor(Color.Red)
	self.m_InfoLabel:setFont(VRPFont(24))

	self.m_JobList = GUIGridList:new(5, 60, self.m_Width-10, self.m_Height-60, self)
	self.m_JobList:addColumn(_"Jobs", 0.7)
	self.m_JobList:addColumn(_"Min. Job-Level", 0.3)

	local pos
	for index, job in pairs(JobManager:getSingleton().m_Jobs) do
		pos = job.m_Ped:getPosition()
		item = self.m_JobList:addItem(job.m_Name, job.m_Level)
		item.onLeftDoubleClick = function () self:showJob( pos, job.m_Ped ) end
	end
end

function JobHelpGUI:showJob( pos, ped )
	if self.m_JobBlip then
		delete(self.m_JobBlip)
	end
	self.m_JobBlip = Blip:new("Marker.png", pos.x, pos.y,9999)
	self.m_JobBlip:attachTo(ped)
end
