-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Gameplay/Minigames/SideSwipe.lua
-- *  PURPOSE:     Minigame - SideSwipe vRP Edition (Original: https://github.com/HorrorClown/MTASideSwipe)
-- *
-- ****************************************************************************
SideSwipe = inherit(Object)

function SideSwipe:constructor()
	self.JosefinSans30 = VRPFont(48, Fonts.JosefinSansRegular) -- dxCreateFont("files/fonts/JosefinSans-Regular.ttf", 30)
	self.JosefinSans100 = VRPFont(160, Fonts.JosefinSansRegular) --dxCreateFont("files/fonts/JosefinSans-Regular.ttf", 100)

	self.state = "Home"
	self.width, self.height = 400, 600
	self.dropX, self.dropY = 94, 256

	self.renderTarget = DxRenderTarget(self.width, self.height, false)
	self.Score = 0
	self.sounds = true

	--Preloads
	self:loadImages()
	self:loadAnimations()
	self:loadColors()
	self:loadDropPositions()
	self:bindKeys()
	--Update the render target
	self:updateRenderTarget()

	self._onClientRender = bind(SideSwipe.onClientRender, self)
	addEventHandler("onClientRender", root, self._onClientRender)

	localPlayer:setFrozen(true)
end

function SideSwipe:destructor()
	--Remove Events
	removeEventHandler("onClientRender", root, self._onClientRender)
	--removeEventHandler("onClientResourceStop", resourceRoot, self._closeFunc)

	--unbind keys
	unbindKey("backspace", "down", self._closeFunc)
	unbindKey("arrow_l", "down", self._swipeFunc)
	unbindKey("arrow_r", "down", self._swipeFunc)

	--Stop/delete animations
	delete(self.anim_swipeRight)
	delete(self.anim_swipeLeft)
	delete(self.anim_failMove)

	for k, v in pairs(self) do
		if isElement(v) and v.destroy then
			v:destroy()
		end

		self[k] = nil
	end

	collectgarbage()
	localPlayer:setFrozen(false)
end

----
-- Methode: loadImages, loadAnimations, loadColors, loadDropPositions, bindKeys
-- Preload on startup
---
function SideSwipe:loadImages()
	self.images = {
		"titlescreen",
		"filled_circle",
		"drop",
		"play",
		"direction",
	}

	for _, img in ipairs(self.images) do
		self[img] = DxTexture(("files/images/SideSwipe/%s.png"):format(img))
	end

	self.background = math.random(1, 6)
end

function SideSwipe:loadAnimations()
	self.swipeToRightWidth = 0      --Blue
	self.swipeToLeftWidth = 0       --Orange

	self.anim_swipeRight = new(CAnimation, self, bind(SideSwipe.swipeDone, self), "swipeToRightWidth")
	self.anim_swipeLeft = new(CAnimation, self, bind(SideSwipe.swipeDone, self), "swipeToLeftWidth")
	self.anim_failMove = new(CAnimation, self, "blackY", "blackWidth")
end

function SideSwipe:loadColors()
	self.white = tocolor(255, 255, 255)
	self.orange = tocolor(255, 70, 0)
	self.blue = tocolor(0, 150, 255)
end

function SideSwipe:loadDropPositions()
	self.dropStartY = -self.dropY - 20
	self.dropPositions = {
		--Single drops
		[1] = {
			self.width/2 - self.dropX/2,
		},

		--Dual drops
		[2] = {
			self.width/2 - self.dropX - 10,
			self.width/2 + 10,
		},

		--Triple drops
		[3] = {
			(self.width/3/2 - self.dropX/2) + 30,
			self.width/2 - self.dropX/2,
			self.width/3*2 + (self.width/3/2 - self.dropX/2) - 30,
		},
	}
end

function SideSwipe:bindKeys()
	self._closeFunc = bind(SideSwipe.destructor, self)
	self._swipeFunc = bind(SideSwipe.swipe, self)

	bindKey("backspace", "down", self._closeFunc)
	--bindKey("arrow_l", "down", self._swipeFunc)
	bindKey("arrow_l", "down", self._swipeFunc)
	bindKey("arrow_r", "down", self._swipeFunc)
	--bindKey("arrow_r", "down", self._swipeFunc)
end

----
-- Methode: swipe, swipeDone
-- start playing / swipe left/right / reset
---
function SideSwipe:swipe(sKey)
	if self.state == "Home" then
		self.state = "Play"
		self:createDrops()
		self:updateRenderTarget()
		return
	end

	if sKey == "arrow_r" or sKey == "num_6" then    --Blue
		--if self.swipeToRightWidth ~= 0 then return end
		if not self.dropsFalling then return end
		self.swipeToRightWidth = 0

		for ID, drop in ipairs(self.Drops) do
			if not drop.killed and drop.type == "b" then
				self.anim_swipeRight:startAnimation(150, "Linear", self.width + 200) -- + 200 looks better
				drop.anim:stopAnimation()
				drop.killed = true
				self:explode(drop.startX, self[("DropY_%s"):format(ID)], "b")

				self:checkDrops()
				return
			end
		end

		self:failed()
	elseif sKey == "arrow_l" or sKey == "num_4" then   --Orange
		--if self.swipeToLeftWidth ~= 0 then return end
		if not self.dropsFalling then return end
		self.swipeToLeftWidth = 0

		for ID, drop in ipairs(self.Drops) do
			if not drop.killed and drop.type == "o" then
				self.anim_swipeLeft:startAnimation(150, "Linear", self.width + 200) -- + 200 looks better
				drop.anim:stopAnimation()
				drop.killed = true
				self:explode(drop.startX, self[("DropY_%s"):format(ID)], "o")

				self:checkDrops()
				return
			end
		end

		self:failed()
	end
end

function SideSwipe:checkDrops()
	if self.state ~= "Play" then return end

	--Check if all drops get killed
	local killedDrops = {}
	for _, drop in ipairs(self.Drops) do
		if drop.killed then
			table.insert(killedDrops, drop)
		end
	end

	if #killedDrops == #self.Drops then
		self.Score = self.Score + 1

		self.dropsFalling = false
		self:createDrops()
	end
end

function SideSwipe:swipeDone()
	self.swipeToRightWidth = 0      --Blue
	self.swipeToLeftWidth = 0       --Orange
	self:updateRenderTarget()
end

function SideSwipe:failed(type)
	if self.state == "Died" then return end

	if type == "black" then
		for _, drop in ipairs(self.Drops) do
			if drop.type == "black" then
				drop.killed = true
			end
		end

		self:checkDrops()
		return
	end

	self.state = "Died"
	self.blackY = self.height
	self.blackWidth = 0

	if self.anim_failMove then
		self.anim_failMove:startAnimation(450, "OutQuad", 0, self.width)
	end

	for ID, drop in ipairs(self.Drops) do
		if not drop.killed then
			drop.anim:stopAnimation()
			drop.killed = true
			self:explode(drop.startX, self[("DropY_%s"):format(ID)], drop.type)
		end
	end

	setTimer(function() self.Score = 0 self.state = "Home" self:updateRenderTarget() end, 3000, 1)
end

----
-- Methode: createDrops
-- create drops based on score
---
function SideSwipe:createDrops()
	--- logic                                           (Include this each level)
	-- 0  to 10 -> 1                                    Only orange/blue
	-- 10 to 20 -> 1                                    Include black
	-- 20 to 30 -> 2               paired               (orange/orange - blue/blue)
	-- 30 to 40 -> 2               paired/unpaired      (orange/blue - blue/orange)
	-- 40 to 50 -> 2                                    higher chance for unpaired & unpaired drops
	-- 50 to 70 -> 2               paired/unpaired      (orange/black - blue/black)
	-- 70 to 80 -> 3               paired               (orange/orange/orange - blue/blue/blue)
	-- 80 to 90 -> 3               unpaired
	-- 90 to XX -> 3               unpaired + black


	if self.state ~= "Play" then return end
	self.Drops = {}
	--Beginning
	if self.Score >= 0 and self.Score < 10 then                     --Just 1 orange/blue drop
	self:createSingleDrop()
	elseif self.Score >= 10 and self.Score < 20 then
		self:createSingleDrop(true)
	elseif self.Score >= 20 and self.Score < 30 then
		if math.random(1, 2) == 1 then                              --Single drop (ofc include black)
		self:createSingleDrop(true)
		else                                                            --Paired drops
		self:createDoublePairedDrop()
		end
	elseif self.Score >= 30 and self.Score < 40 then
		if math.random(1, 4) == 1 then                              --Unpaired drops
		self:createDoubleUnpairedDrop()
		else
			if math.random(1, 3) == 1 then                          --Single drop (ofc include black)
			self:createSingleDrop(true)
			else                                                    --Paired drops
			self:createDoublePairedDrop()
			end
		end
	elseif self.Score >= 40 and self.Score < 50 then
		if math.random(1, 3) == 1 then                              --Unpaired drops
		self:createDoubleUnpairedDrop()
		else
			if math.random(1, 4) == 1 then                          --Single drop (ofc include black)
			self:createSingleDrop(true)
			else                                                    --Paired drops
			self:createDoublePairedDrop()
			end
		end
	elseif self.Score >= 50 and self.Score < 70 then
		if math.random(1, 3) == 1 then                           --Unpaired drops
		self:createDoubleUnpairedDrop(true)
		else
			if math.random(1, 3) == 1 then                          --Single drop (ofc include black)
			self:createSingleDrop(true)
			else                                                    --Paired drops
			self:createDoublePairedDrop()
			end
		end
	elseif self.Score >= 70 and self.Score < 80 then
		if math.random(1, 3) == 2 then
			self:createTriplePairedDrop()
		else
			if math.random(1, 3) == 1 then                           --Unpaired drops
			self:createDoubleUnpairedDrop(true)
			else
				if math.random(1, 3) == 1 then                          --Single drop (ofc include black)
				self:createSingleDrop(true)
				else                                                    --Paired drops
				self:createDoublePairedDrop()
				end
			end
		end
	elseif self.Score >= 80 and self.Score < 90 then
		self:createTripleUnpairedDrop()
	elseif self.Score >= 90 then
		self:createTripleUnpairedDrop(true)
	end

	--Start drops
	self.startDropsTimer = setTimer(
		function()
			--Calc speed
			local speed = 1500 - (self.Score/10*75)

			for _, drop in ipairs(self.Drops) do
				drop.anim:startAnimation(speed, "Linear", self.height)
			end
			self.dropsFalling = true
		end,
		1000, 1
	)
end

function SideSwipe:createSingleDrop(bIncludeBlack)
	local startX = self.width/2 - self.dropX/2
	local startY = self.dropStartY
	local type

	if bIncludeBlack then
		if math.random(1, 4) == 3 then
			type = "black"
		else return self:createSingleDrop() end
	else
		type = math.random(1, 2) == 1 and "o" or "b"
	end

	local anim = new(CAnimation, self, bind(SideSwipe.failed, self, type),("DropY_%s"):format(1))
	self[("DropY_%s"):format(1)] = startY

	table.insert(self.Drops, {startX = startX, type = type, anim = anim})
end

function SideSwipe:createDoublePairedDrop()
	local startY = self.dropStartY
	local type = math.random(1, 2) == 1 and "o" or "b"

	local startX1 = self.dropPositions[2][1]
	local startX2 = self.dropPositions[2][2]

	table.insert(self.Drops, {startX = startX1, type = type})
	table.insert(self.Drops, {startX = startX2, type = type})

	if type == "o" then table.sort(self.Drops, function(a, b) return a.startX > b.startX end) else table.sort(self.Drops, function(a, b) return a.startX < b.startX end) end

	for ID, drop in ipairs(self.Drops) do
		drop.anim = new(CAnimation, self, bind(SideSwipe.failed, self, type),("DropY_%s"):format(ID))
		self[("DropY_%s"):format(ID)] = startY
	end
end

function SideSwipe:createDoubleUnpairedDrop(bIncludeBlack)
	local startY = self.dropStartY
	local firstType = math.random(1, 2) == 1 and "o" or "b"
	local secondType = firstType == "b" and "o" or "b"

	if bIncludeBlack then
		if math.random(1, 3) == 1 then firstType = "black" end
		if math.random(1, 3) == 1 then secondType = "black" end
	end

	local startX1 = self.dropPositions[2][1]
	local startX2 = self.dropPositions[2][2]

	table.insert(self.Drops, {startX = startX1, type = firstType})
	table.insert(self.Drops, {startX = startX2, type = secondType})

	for ID, drop in ipairs(self.Drops) do
		drop.anim = new(CAnimation, self, bind(SideSwipe.failed, self, drop.type),("DropY_%s"):format(ID))
		self[("DropY_%s"):format(ID)] = startY
	end
end

function SideSwipe:createTriplePairedDrop()
	local startY = self.dropStartY
	local type = math.random(1, 2) == 1 and "o" or "b"

	local startX1 = self.dropPositions[3][1]
	local startX2 = self.dropPositions[3][2]
	local startX3 = self.dropPositions[3][3]

	table.insert(self.Drops, {startX = startX1, type = type})
	table.insert(self.Drops, {startX = startX2, type = type})
	table.insert(self.Drops, {startX = startX3, type = type})

	if type == "o" then table.sort(self.Drops, function(a, b) return a.startX > b.startX end) else table.sort(self.Drops, function(a, b) return a.startX < b.startX end) end

	for ID, drop in ipairs(self.Drops) do
		drop.anim = new(CAnimation, self, bind(SideSwipe.failed, self, type),("DropY_%s"):format(ID))
		self[("DropY_%s"):format(ID)] = startY
	end
end

function SideSwipe:createTripleUnpairedDrop(bIncludeBlack)
	local startY = self.dropStartY
	local firstType = math.random(1, 2) == 1 and "o" or "b"
	local secondType = math.random(1, 2) == 1 and "o" or "b"
	local thirdType = math.random(1, 2) == 1 and "o" or "b"

	if bIncludeBlack then
		if math.random(1, 2) == 1 then firstType = "black" end
		if math.random(1, 2) == 1 then secondType = "black" end
		if math.random(1, 2) == 1 then thirdType = "black" end
	end

	local startX1 = self.dropPositions[3][1]
	local startX2 = self.dropPositions[3][2]
	local startX3 = self.dropPositions[3][3]

	table.insert(self.Drops, {startX = startX1, type = firstType})
	table.insert(self.Drops, {startX = startX2, type = secondType})
	table.insert(self.Drops, {startX = startX3, type = thirdType})

	for ID, drop in ipairs(self.Drops) do
		drop.anim = new(CAnimation, self, bind(SideSwipe.failed, self, drop.type),("DropY_%s"):format(ID))
		self[("DropY_%s"):format(ID)] = startY
	end
end

----
-- Methode: explode
-- explode effect if a drop was successfully killed
---
function SideSwipe:explode(startX, startY, sColor)
	if self.explosionBalls then
		for _, anim in ipairs(self.explosionBalls) do
			delete(anim)
		end
	else self.explosionBalls = {} end

	local startX = startX
	local startY = startY + self.dropY*0.75
	playSound("files/audio/SideSwipe/blop.mp3")
	for i = 1, 15 do
		self[("BallX_%s"):format(i)] = startX + math.random(-20, 20)
		self[("BallY_%s"):format(i)] = startY + math.random(-20, 20)
		self[("BallA_%s"):format(i)] = 255
		self.ballExplodeColor = sColor

		self.explosionBalls[i] = new(CAnimation, self, ("BallX_%s"):format(i), ("BallY_%s"):format(i), ("BallA_%s"):format(i))
		self.explosionBalls[i]:startAnimation(1000, "OutQuad", startX + math.random(-200, 200), startY +math.random(-300, 300), 0)
	end
end

----
-- Methode: updateRenderTarget
---
function SideSwipe:updateRenderTarget()
	if not self.renderTarget then return end
	self.renderTarget:setAsTarget(true)

	dxDrawRectangle(0, 0, self.width, self.height, tocolor(230, 230, 230))

	if self.state == "Home" then
		dxDrawImage(0, 0, self.width, self.height, self.titlescreen)
		dxDrawImage(self.width/2-196/2, self.height/2-196/2 + 50, 196, 196, self.play)
	end

	if self.state == "Play" then
		dxDrawRectangle(0, 0, self.swipeToRightWidth, self.height - 60, tocolor(0, 150, 255, 100))
		dxDrawRectangle(self.width - self.swipeToLeftWidth, 0, self.swipeToLeftWidth, self.height - 60, tocolor(255, 70, 0, 100))

		dxDrawText(self.Score, 0, 0, self.width, self.height, self.white, 1, getVRPFont(self.JosefinSans100), "center", "center")
		dxDrawLine(self.width/2 - 60, self.height/2 + 65, self.width/2+60, self.height/2 + 65, self.white, 1)
		dxDrawText("Score", 0, self.height/2 + 85, self.width, self.height/2 + 85, self.white, 1, getVRPFont(self.JosefinSans30), "center", "center")

		for ID, drop in ipairs(self.Drops) do
			if not drop.killed then
				dxDrawImageSection(drop.startX, self[("DropY_%s"):format(ID)], self.dropX, self.dropY, 0, 10, self.dropX, self.dropY - 10, self.drop, 0, 0, 0, drop.type == "o" and self.orange or drop.type == "b" and self.blue or tocolor(0, 0, 0, 150))
			end
		end

		dxDrawRectangle(0, self.height - 60, self.width/2, 60, tocolor(255, 70, 0, 100))
		dxDrawRectangle(self.width/2, self.height - 60, self.width/2, 60, tocolor(0, 150, 255, 100))
		for i = 0, 4 do
			dxDrawImage(8 + 40*i, self.height - 60/2 - 48/2, 23, 48, self.direction, 0, 0, 0, tocolor(255, 255, 255, 150))
			dxDrawImage(self.width/2 + 8 + 40*i, self.height - 60/2 - 48/2, 23, 48, self.direction, 180, 0, 0, tocolor(255, 255, 255, 150))
		end

		if self.explosionBalls then
			for ID in ipairs(self.explosionBalls) do
				local color = self.ballExplodeColor == "o" and tocolor(255, 70, 0, self[("BallA_%s"):format(ID)]) or  self.ballExplodeColor == "b" and tocolor(0, 150, 255, self[("BallA_%s"):format(ID)]) or tocolor(0, 0, 0, self[("BallA_%s"):format(ID)])
				dxDrawImage(self[("BallX_%s"):format(ID)], self[("BallY_%s"):format(ID)], 18, 18, self.filled_circle, 0, 0, 0, color)
			end
		end
	end

	if self.state == "Died" then
		dxDrawRectangle(self.width/2 - self.blackWidth/2, self.blackY, self.blackWidth, self.height, tocolor(0, 0, 0, 100))

		dxDrawText(self.Score, 0, 0, self.width, self.height, self.white, 1, getVRPFont(self.JosefinSans100), "center", "center")
		dxDrawLine(self.width/2 - 60, self.height/2 + 65, self.width/2+60, self.height/2 + 65, self.white, 1)
		dxDrawText("Score", 0, self.height/2 + 85, self.width, self.height/2 + 85, self.white, 1, getVRPFont(self.JosefinSans30), "center", "center")

		if self.explosionBalls then
			for ID in ipairs(self.explosionBalls) do
				local color = self.ballExplodeColor == "o" and tocolor(255, 70, 0, self[("BallA_%s"):format(ID)]) or  self.ballExplodeColor == "b" and tocolor(0, 150, 255, self[("BallA_%s"):format(ID)]) or tocolor(0, 0, 0, self[("BallA_%s"):format(ID)])
				dxDrawImage(self[("BallX_%s"):format(ID)], self[("BallY_%s"):format(ID)], 18, 18, self.filled_circle, 0, 0, 0, color)
			end
		end
	end

	dxSetRenderTarget()
end

----
-- Methode: onClientRender
-- Render
---
function SideSwipe:onClientRender()
	if not self.renderTarget then return end

	dxDrawImage(screenWidth/2-self.width/2, screenHeight/2-self.height/2, self.width, self.height, self.renderTarget)
end
