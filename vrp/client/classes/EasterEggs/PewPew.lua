-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        TODO
-- *  PURPOSE:     TODO
-- *
-- ****************************************************************************
EasterEgg.PewPew = inherit(Object)

addRemoteEvents{"renderPewPewAchievement"}

function EasterEgg.PewPew:constructor()
	self.m_RenderPewPewAchievement = bind(EasterEgg.PewPew.render, self)

	addEventHandler("renderPewPewAchievement", root, bind(EasterEgg.PewPew.startRender, self))
end

function EasterEgg.PewPew:destructor()
end

local rndText = {"Pew Pew!", "PEW", "PewX", "#PewPorn.com", "<3", "50", "CATS", "meow", "OMG", "PR0N", "grills"}
local colors = {Color.DarkLightBlue, Color.Red, Color.Blue, Color.Green, Color.Orange, Color.Brown, Color.White}
function EasterEgg.PewPew:startRender()
	playSound("http://pewx.de/res/sounds/tactical_nuke.mp3")
	playSound("http://pewx.de/res/sounds/SKRILLEX_Scary.mp3")
	playSound("http://pewx.de/res/sounds/OMG_TRICKSHOT_CHILD.mp3")

	self.m_OffsetX = -452
	self.m_Wank = -10
	self.m_SizeX, self.m_SizeY, self.m_Alpha = 2200, 2200, 255
	self.m_TextMoveOut = false
	self.m_Texts = {}

	for i = 1, 100 do
		local text = rndText[math.random(1, #rndText)]
		table.insert(self.m_Texts, {text = text, x = math.random(0, screenWidth), y = math.random(0, screenHeight), w = dxGetTextWidth(text, 3), h = dxGetFontHeight(3), color = colors[math.random(1, #colors)], moveDown = math.random(0,1) == 1, moveRight = math.random(0,1) == 1})
	end
	table.insert(self.m_Texts, {text = "Cpen", x = math.random(0, screenWidth), y = math.random(0, screenHeight), w = dxGetTextWidth("Cpen", 3), h = dxGetFontHeight(3), color = colors[math.random(1, #colors)], moveDown = math.random(0,1) == 1, moveRight = math.random(0,1) == 1})
	table.insert(self.m_Texts, {text = "Panda", x = math.random(0, screenWidth), y = math.random(0, screenHeight), w = dxGetTextWidth("Panda", 3), h = dxGetFontHeight(3), color = colors[math.random(1, #colors)], moveDown = math.random(0,1) == 1, moveRight = math.random(0,1) == 1})
	table.insert(self.m_Texts, {text = "Skoph", x = math.random(0, screenWidth), y = math.random(0, screenHeight), w = dxGetTextWidth("Skoph", 3), h = dxGetFontHeight(3), color = colors[math.random(1, #colors)], moveDown = math.random(0,1) == 1, moveRight = math.random(0,1) == 1})

	self.m_Animation = CAnimation:new(self, "m_OffsetX"):callRenderTarget(false)
	self.m_Animation2 = CAnimation:new(self, "m_Wank"):callRenderTarget(false)
	self.m_Animation3 = CAnimation:new(self, "m_SizeX", "m_SizeY", "m_Alpha"):callRenderTarget(false)

	addEventHandler("onClientRender", root, self.m_RenderPewPewAchievement)

	self.m_Animation:startAnimation(6000, "Linear", screenWidth)
	self.m_Animation2:startAnimation(2000, "SineCurve", 20)
	self.m_Animation3:startAnimation(3000, "OutQuad", 0, 0, 0)

	setTimer(
		function()
			self.m_Wank = -10
			self.m_Animation2:startAnimation(2000, "SineCurve", 20)
		end, 2000, 4
	)

	setTimer(
		function()
			self.m_TextMoveOut = true
			playSound("http://pewx.de/res/sounds/SPOOKY.mp3")
			playSound("http://pewx.de/res/sounds/AIRPORN.mp3")
			playSound("http://pewx.de/res/sounds/wow.mp3")
		end, 20000, 1
	)

	setTimer(
		function()
			playSound("http://pewx.de/res/sounds/DAMN_SON_WHERED_YOU_FIND_THIS.mp3")
			removeEventHandler("onClientRender", root, self.m_RenderPewPewAchievement)
		end, 23000, 1
	)
end

function EasterEgg.PewPew:render()
	dxDrawImage(screenWidth/2 - self.m_SizeX/2, screenHeight/2 - self.m_SizeY/2, self.m_SizeX, self.m_SizeY, "files/images/Other/PewPew/head.png", self.m_Wank, 0, 0, tocolor(255, 255, 255, self.m_Alpha))

	local multi = {{.5, .5}, {.5, 1.5}, {1.5, .5}, {1.5, 1.5}}
	for _, v in pairs(multi) do
		dxDrawImage((screenWidth/2 - self.m_SizeX/2)*v[1], (screenHeight/2 - self.m_SizeY/2)*v[2], self.m_SizeX, self.m_SizeY, "files/images/Other/PewPew/head.png", self.m_Wank, 0, 0, tocolor(255, 255, 255, self.m_Alpha))
	end

	local width, height = 415/1600*screenWidth, 452/1024*screenHeight
	dxDrawImage(self.m_OffsetX, screenHeight - height, width, height, "files/images/Other/PewPew/body.png")
	dxDrawImage(self.m_OffsetX, screenHeight - height + 10, width, height, "files/images/Other/PewPew/head.png", self.m_Wank)

	for _, v in pairs(self.m_Texts) do
		if not self.m_TextMoveOut then
			if v.x + v.w > screenWidth and v.moveRight then
				v.moveRight = false
				v.color = colors[math.random(1, #colors)]
			end
			if v.y + v.h > screenHeight and v.moveDown then
				v.moveDown = false
				v.color = colors[math.random(1, #colors)]
			end
			if v.x < 0 and not v.moveRight then
				v.moveRight = true
				v.color = colors[math.random(1, #colors)]
			end
			if v.y < 0 and not v.moveDown then
				v.moveDown = true
				v.color = colors[math.random(1, #colors)]
			end
		end

		if v.moveRight then v.x = v.x + 5 else v.x = v.x - 5 end
		if v.moveDown then v.y = v.y + 5 else v.y = v.y - 5 end

		dxDrawText(v.text, v.x, v.y, v.w, v.h, v.color, 3)
	end

	if math.random(1, 10) == 5 then
		dxDrawImage(screenWidth/2-25, screenHeight/2-25, 50, 50, "files/images/Other/PewPew/hit.png")
		playSound("http://pewx.de/res/sounds/HITMARKER.mp3")
	end
end
