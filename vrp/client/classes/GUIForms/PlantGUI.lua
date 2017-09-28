-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/PlantGUI.lua
-- *  PURPOSE:     PlantGUI class
-- *
-- ****************************************************************************

PlantGUI = inherit(GUIForm)
inherit(Singleton, PlantGUI)

function PlantGUI.load()
	addRemoteEvents{"showPlantGUI", "hidePlantGUI"}

	addEventHandler("showPlantGUI", root,
		function(id, type, lastGrow, size, maxSize, item, itemsPerSize, owner, lastWatered, wateredTime)
			PlantGUI:new(id, type, lastGrow, size, maxSize, item, itemsPerSize, owner, lastWatered, wateredTime)
		end
	)

	addEventHandler("hidePlantGUI", root,
		function()
			delete(PlantGUI:getSingleton())
		end
	)
end

function PlantGUI:constructor(id, type, lastGrow, size, maxSize, item, itemsPerSize, owner, lastWatered, wateredTime)
	GUIForm.constructor(self, screenWidth-270, screenHeight/2-160/2, 250, 160, false)

	if not id or not size then delete(self) end
	self.m_Id = id

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, type, true, false, self)
	local ts = getRealTime().timestamp

	self.m_Progress = GUIProgressBar:new(10, 40, self.m_Width-20, 25, self)
	self.m_Progress:setProgress(size/maxSize*100)
	self.m_Progress:setForegroundColor(tocolor(50,200,255))
	self.m_Progress:setBackgroundColor(tocolor(180,240,255))
	GUILabel:new(10, 40, self.m_Width-20, 25, _("Größe: %d/%d", size, maxSize), self):setAlignX("center")
	if size < maxSize then
		local nextGrow = lastGrow+60*60
		nextGrow = math.floor((nextGrow-ts)/60)
		GUILabel:new(10, 70, self.m_Width-20, 20, _("Nächster Wachstum in ~%d Minuten", nextGrow), self):setAlignX("center")
	end
	GUILabel:new(10, 90, self.m_Width-20, 20, _("Derzeitige Ernte: %d/%d %s", size*itemsPerSize, maxSize*itemsPerSize, item), self):setAlignX("center")
	local watered = math.floor(lastWatered+wateredTime*60*60-ts)
	if watered > 0 then
		local wateredOptical = timespanArray(watered)
		GUILabel:new(10, 110, self.m_Width-20, 20, _("Bewässert für %s Stunden", wateredOptical["hour"]..":"..wateredOptical["min"]), self):setAlignX("center")
	else
		GUILabel:new(10, 110, self.m_Width-20, 20, _"nicht bewässert", self):setColor(Color.Red):setAlignX("center")
	end
	GUILabel:new(10, 130, self.m_Width-20, 20, _"Drücke [E] zum ernten!", self):setColor(Color.LightBlue):setAlignX("center")
	self.m_HarvestBind = bind(self.harvest, self)
	bindKey("e", "down", self.m_HarvestBind)
end

function PlantGUI:destructor()
	unbindKey("e", "down", self.m_HarvestBind)
	GUIForm.destructor(self)
end

function PlantGUI:harvest(key, state)
	if state == "down" then
		if self.m_Id and self.m_Id > 0 then
			triggerServerEvent("plant:harvest", localPlayer, self.m_Id)
		end
	end
end
