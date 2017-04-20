-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/HelpTextManager.lua
-- *  PURPOSE:     Responsible for managing help texts
-- *
-- ****************************************************************************
HelpTextManager = inherit(Singleton)

function HelpTextManager:constructor()
	self.m_Texts = {}

	-- General purpose texts here
	self:addText("Allgemein", HelpTextTitles.General.Main, HelpTexts.General.Main)
	self:addText("Allgemein", HelpTextTitles.General.Team, HelpTexts.General.Team)
	self:addText("Fahrzeuge", HelpTextTitles.Vehicles.Info, HelpTexts.Vehicles.Info)
	self:addText("Fahrzeuge", HelpTextTitles.Vehicles.CustomTextures, HelpTexts.Vehicles.CustomTextures)
	self:addText("Freizeit", HelpTextTitles.Leisure.Kart, HelpTexts.Leisure.Kart)
	self:addText("Freizeit", HelpTextTitles.Leisure.Fishing, HelpTexts.Leisure.Fishing)
	self:addText("Freizeit", HelpTextTitles.Leisure.Boxing, HelpTexts.Leisure.Boxing)
	self:addText("Freizeit", HelpTextTitles.Leisure.Bars, HelpTexts.Leisure.Bars)
	self:addText("Freizeit", HelpTextTitles.Leisure.Minigames,HelpTexts.Leisure.Minigames)
	self:addText("Freizeit", HelpTextTitles.Leisure.Horserace, HelpTexts.Leisure.Horserace)
	self:addText("Credits", HelpTextTitles.Credits.OldVRPTeam, HelpTexts.Credits.OldVRPTeam)
	self:addText("Credits", HelpTextTitles.Credits.Other, HelpTexts.Credits.Other)

end

function HelpTextManager:addText(category, title, text)
	-- First, translate all parameters
	category, title, text = _(category), _(title), _(text)

	if not self.m_Texts[category] then
		self.m_Texts[category] = {}
	end

	self.m_Texts[category][title] = text
end

function HelpTextManager:getTexts()
	return self.m_Texts
end

-- Le Easteregg
-- Todo: Other file?
Easteregg = {
	{position = Vector3(1516.93, -1666.06, 13.80), colsize = 10, title = "Le Easteregg.", text = "Such Text. So Easteregg. Wow."}
}

for i, v in pairs(Easteregg) do
	local col = createColSphere(v.position, v.colsize)
	addEventHandler("onClientColShapeHit", col, function (ele)
		if ele == localPlayer then
			HelpBar:getSingleton():addText(v.title, v.text)
			localPlayer:giveAchievement(49)
		end
	end)
	addEventHandler("onClientColShapeLeave", col, function ()
		if ele == localPlayer then
			HelpBar:getSingleton():addText(localPlayer.m_oldHelp.title or _(HelpTextTitles.General.Main), localPlayer.m_oldHelp.text or _(HelpTexts.General.Main), false, localPlayer.m_oldHelp.tutorial or false)
		end
	end)
end
