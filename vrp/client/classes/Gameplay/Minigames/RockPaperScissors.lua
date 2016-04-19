-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Gameplay/Minigames/RockPaperScissors.lua
-- *  PURPOSE:     RockPaperScissors Game - Client
-- *
-- ****************************************************************************

RockPaperScissorsSelection = inherit(GUIForm)
inherit(Singleton, RockPaperScissorsSelection)
addRemoteEvents{"rockPaperScissorsSelection", "rockPaperScissorsShowResult"}

local RockPaperScissorsSettings = {}
RockPaperScissorsSettings.Images = {
	["Scissors"] = "files/images/RockPaperScissors/scissors.png",
	["Rock"] = "files/images/RockPaperScissors/rock.png",
	["Paper"] = "files/images/RockPaperScissors/paper.png",
 }

 RockPaperScissorsSettings.Names = {
 	["Scissors"] = "Schere",
 	["Rock"] = "Stein",
 	["Paper"] = "Papier",
  }

RockPaperScissorsSettings.WinText = {
	["win"] = "Gewonnen",
	["loose"] = "Verloren",
	["draw"] = "Unentschieden",

}

function RockPaperScissorsSelection:constructor()
	GUIForm.constructor(self, screenWidth/2-420/2, screenHeight/2-200/2, 420, 200, true, true)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Schere Stein Papier", true, true, self)
	self.m_Scissors = GUIImage:new(30, 40, 100, 166, RockPaperScissorsSettings.Images.Scissors, self.m_Window)
	self.m_Scissors.onLeftClick = function () self:select("Scissors") end
	self.m_Rock = GUIImage:new(160, 40, 100, 166, RockPaperScissorsSettings.Images.Rock, self.m_Window)
	self.m_Rock.onLeftClick = function () self:select("Rock") end
	self.m_Paper = GUIImage:new(290, 40, 100, 166, RockPaperScissorsSettings.Images.Paper, self.m_Window)
	self.m_Paper.onLeftClick = function () self:select("Paper") end
end

function RockPaperScissorsSelection:select(selection)
	triggerServerEvent("rockPaperScissorsSelect", localPlayer, selection)
	delete(self)
end

addEventHandler("rockPaperScissorsSelection", root,
	function()
		RockPaperScissorsSelection:new()
	end
)

RockPaperScissorsResult = inherit(GUIForm)
inherit(Singleton, RockPaperScissorsResult)

function RockPaperScissorsResult:constructor(result, pTable)
	GUIForm.constructor(self, screenWidth/2-420/2, screenHeight/2-240/2, 420, 240, true, true)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Schere Stein Papier - Ergebnis", true, true, self)


	self.m_AnimationBG =  GUIImage:new(-self.m_Width, 30, self.m_Width, self.m_Height-30, "files/images/Other/trans.png", self.m_Window)
	self.m_AnimationIcon = GUIImage:new(60, 30, 100, 166, RockPaperScissorsSettings.Images[type], self.m_AnimationBG)
	self.m_AnimationLabel = GUILabel:new(210, 104, 140, 40, RockPaperScissorsSettings.Names[type], self.m_AnimationBG):setAlignX("center")

	self:showAnimation("Scissors", "left")
	setTimer(function()
		self:showAnimation("Rock", "right")
		setTimer(function()
			self:showAnimation("Paper", "left")
			setTimer(function()
				self:showResult(result, pTable)
			end, 2500, 1)
		end, 2500, 1)
	end, 2500, 1)
end

function RockPaperScissorsResult:showAnimation(type, direction)
	self.m_AnimationIcon:setImage(RockPaperScissorsSettings.Images[type])
	self.m_AnimationLabel:setText(RockPaperScissorsSettings.Names[type])
	local target = (self.m_Width*2)-100
	if direction == "right" then
		target = 0 - self.m_Width+100
	end
	Animation.Move:new(self.m_AnimationBG, 2500, target, 30)
end

function RockPaperScissorsResult:showResult(result, pTable)
	GUILabel:new(30, 30, 100, 30, _"Du:", self.m_Window):setAlignX("center")
	GUIImage:new(30, 60, 100, 166, RockPaperScissorsSettings.Images[pTable[localPlayer]], self.m_Window)
	GUILabel:new(140, 104, 140, 35, RockPaperScissorsSettings.WinText[result], self.m_Window):setAlignX("center")

	local opponent
	for player, selection in pairs(pTable) do
		if player ~= localPlayer then
			 opponent = player
		end
	end
	if isElement(opponent) then
		GUILabel:new(270, 30, 160, 30, opponent:getName(), self.m_Window):setAlignX("center")
		GUIImage:new(290, 60, 100, 166, RockPaperScissorsSettings.Images[pTable[opponent]], self.m_Window)
	end
end

addEventHandler("rockPaperScissorsShowResult", root,
	function(result, pTable)
		RockPaperScissorsResult:new(result, pTable)
	end
)
