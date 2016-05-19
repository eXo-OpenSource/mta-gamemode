-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/PlantGUI.lua
-- *  PURPOSE:     PlantGUI class
-- *
-- ****************************************************************************

PlantGUI = inherit(GUIForm)
inherit(Singleton, PlantGUI)

addRemoteEvents{"showPlantGUI", "hidePlantGUI"}

function PlantGUI:constructor(type, lastGrow, size, maxSize, items, owner, lastWatered, wateredTime)

	GUIForm.constructor(self, screenWidth-270, screenHeight/2-150/2, 250, 150, false)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, type, true, false, self)

	local ts = getRealTime().timestamp
	local nextGrow = math.floor((ts-lastGrow)/60)
	self.m_Progress = GUIProgressBar:new(10, 40, self.m_Width-20, 25, self)
	self.m_Progress:setProgress(size/maxSize*100)
	GUILabel:new(10, 40, self.m_Width-20, 25, _("Größe: %d/%d", size, maxSize), self):setAlignX("center")
	GUILabel:new(10, 70, self.m_Width-20, 20, _("Nächster Wachstum in ~%d Minuten", nextGrow), self)
	local watered = math.floor(lastWatered+wateredTime*60*60-ts)
	if watered > 0 then

		local wateredOptical = timespanArray(watered)
		GUILabel:new(10, 90, self.m_Width-20, 20, _("Bewässert für %s Stunden", wateredOptical["hour"]..":"..wateredOptical["min"]), self)
	else
		GUILabel:new(10, 90, self.m_Width-20, 20, _"nicht bewässert", self):setColor(Color.Red)
	end
end

addEventHandler("showPlantGUI", root,
	function(type, lastGrow, size, maxSize, items, owner, lastWatered, wateredTime)
		PlantGUI:new(type, lastGrow, size, maxSize, items, owner, lastWatered, wateredTime)
	end
)

addEventHandler("hidePlantGUI", root,
	function()
		delete(PlantGUI:getSingleton())
	end
)
