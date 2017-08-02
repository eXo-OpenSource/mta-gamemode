-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Jobs/Job.lua
-- *  PURPOSE:     Abstract job class
-- *
-- ****************************************************************************
Job = inherit(Singleton)

function Job:constructor(skin, posX, posY, posZ, rotZ, blipPath, blipColor, headerImage, name, description, tutorial)
	-- Create the customblip
	self.m_Blip = Blip:new(blipPath, posX, posY,500)
	self.m_Blip:setDisplayText(name, BLIP_CATEGORY.Job)
	self.m_Blip:setOptionalColor(blipColor)
	self.m_Name = name
	self.m_HeaderImage = headerImage
	self.m_Description = description
	self.m_Tutorial = tutorial
	self.m_Level = 0
	-- Create a job marker
	self.m_Ped = createPed(skin, posX, posY, posZ, rotZ)
	setElementData(self.m_Ped, "clickable", true)
	self.m_Ped:setData("Job", self)
	self.m_Ped:setData("NPC:Immortal", true)
	self.m_Ped:setFrozen(true)
	SpeakBubble3D:new(self.m_Ped, _("Job: %s", self.m_Name), _"Für einen Job klicke mich an!")
end

function Job:onPedClick()
	local jobGUI = JobGUI:getSingleton()
	jobGUI:setDescription(self.m_Description)
	jobGUI:setHeaderImage(self.m_HeaderImage)
	jobGUI:setAcceptCallback(bind(Job.acceptHandler, self))
	jobGUI:setDeclineCallback(bind(Job.declineHandler, self))
	jobGUI:setInfoCallback(bind(Job.InfoMessage, self, self.m_Name, self.m_Description, self.m_Tutorial))
	jobGUI:open()
end

function Job:InfoMessage(name, description, tutorial)
	HelpBar:getSingleton():addTempText(_("Job: %s", name), description, false, tutorial and function () HelpBar:getSingleton():fadeOut() tutorial() end or nil, 10000, true)
end

function Job:acceptHandler()
	triggerServerEvent("jobAccepted", root, self:getId())
end

function Job:declineHandler()
	triggerServerEvent("jobDecline", root, self:getId())
end

function Job:setJobLevel(level)
	self.m_Level = level
end

function Job:getId()
	return self.m_Id
end

function Job:setId(Id)
	self.m_Id = Id
end

function Job:getName()
	return self.m_Name
end

Job.start = pure_virtual
