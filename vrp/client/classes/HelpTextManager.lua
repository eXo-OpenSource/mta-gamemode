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
	-- TODO: rework the whole thing - RB 28.05.2017
	self:addText("Allgemein", HelpTextTitles.General.Main, "general.main")
	self:addText("Allgemein", HelpTextTitles.General.Team, "general.team")
	self:addText("Fahrzeuge", HelpTextTitles.Vehicles.Info, "vehicles.info")
	self:addText("Fahrzeuge", HelpTextTitles.Vehicles.CustomTextures, "vehicles.customtextures")
	self:addText("Freizeit", HelpTextTitles.Leisure.Kart, "leisure.kart")
	self:addText("Freizeit", HelpTextTitles.Leisure.Fishing, "leisure.fishing")
	self:addText("Freizeit", HelpTextTitles.Leisure.Boxing, "leisure.boxing")
	self:addText("Freizeit", HelpTextTitles.Leisure.Bars, "leisure.bars")
	self:addText("Freizeit", HelpTextTitles.Leisure.Minigames, "leisure.minigames")
	self:addText("Freizeit", HelpTextTitles.Leisure.Horserace, "leisure.horserace")
	self:addText("Credits", HelpTextTitles.Credits.OldVRPTeam, "credits.oldvrpteam")
	self:addText("Credits", HelpTextTitles.Credits.Other, "credits.other")

end

function HelpTextManager:addText(category, title, helpId)
	-- First, translate all parameters
	category, title = _(category), _(title)

	if not self.m_Texts[category] then
		self.m_Texts[category] = {}
	end

	self.m_Texts[category][title] = helpId
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
