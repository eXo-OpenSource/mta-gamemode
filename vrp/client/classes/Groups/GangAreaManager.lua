-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/GangAreaManager.lua
-- *  PURPOSE:     Gangarea manager class
-- *
-- ****************************************************************************
GangAreaManager = inherit(Singleton)

function GangAreaManager:constructor()
	self.m_Map = {}
	self.m_Font = VRPFont(32, Fonts.Ghetto) --dxCreateFont("files/fonts/Ghetto.ttf", 20, false)

	for i, info in ipairs(GangAreaData) do
		self.m_Map[i] = GangArea:new(i, info.wallPosition, info.wallRotation, info.areaPosition, info.width, info.height)
	end

	addRemoteEvents{"gangAreaTurfStart", "gangAreaTurfUpdate", "gangAreaTurfStop", "gangAreaOnGroupNameChange"}
	addEventHandler("gangAreaTurfStart", root, bind(self.Event_gangAreaTurfStart, self))
	addEventHandler("gangAreaTurfUpdate", root, bind(self.Event_gangAreaTurfUpdate, self))
	addEventHandler("gangAreaTurfStop", root, bind(self.Event_gangAreaTurfStop, self))
	addEventHandler("gangAreaOnGroupNameChange", root, bind(self.Event_onGroupChangeName, self))
end

function GangAreaManager:getFont()
	return getVRPFont(self.m_Font)
end

function GangAreaManager:Event_gangAreaTurfStart(Id, gangName, progress)
	local gangArea = self.m_Map[Id]
	if not gangArea then return end

	local width, height = screenWidth*0.3, screenHeight*0.05
	self.m_GUIBar = GUIProgressBar:new(screenWidth/2 - width/2, screenHeight*0.02, width, height)
	self.m_GUIBar:setProgress(progress or 100)

	if gangName then
		gangArea:setTagInstantly(gangName)
	end
	gangArea:setIsTurfingInProgress(true)
end

function GangAreaManager:Event_gangAreaTurfUpdate(progress)
	self.m_GUIBar:setProgress(progress)
end

function GangAreaManager:Event_gangAreaTurfStop(Id, reason, turfingGroupName)
	if self.m_GUIBar then
		delete(self.m_GUIBar)
		self.m_GUIBar = nil
	end

	local gangArea = self.m_Map[Id]
	if not gangArea then return end

	gangArea:setIsTurfingInProgress(false)

	if reason == TURFING_STOPREASON_LEAVEAREA then
		ShortMessage:new(_"Du bist durch das Verlassen des Gebiets aus dem Gangwar ausgetreten. Du kannst jedoch jederzeit wieder eintreten!")
	elseif reason == TURFING_STOPREASON_NEWOWNER then
		ShortMessage:new(_("Gangwar beendet! Das Gebiet gehört nun %s", turfingGroupName))
	elseif reason == TURFING_STOPREASON_DEFENDED then
		ShortMessage:new(_("Gangwar beendet! Das Gebiet wurde erfolgreich vor %s verteidigt", turfingGroupName))
		gangArea:resetTag(true) -- Reset the gang tag and restore the old one
	end
end

function GangAreaManager:Event_onGroupChangeName(oldname, newname)
	for i, v in pairs(self.m_Map) do
		local ele = getElementByID("GangArea"..v.m_Id)
		if isElement(ele) then
			if getElementData(ele, "OwnerName") == oldname then
				setElementData(ele, "OwnerName", newname)

				v.m_OldTagText = ""
				v.m_TagText = newname
			end
		end
	end
end
