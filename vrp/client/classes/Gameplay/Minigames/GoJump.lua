-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Gameplay/Minigames/GoJump.lua
-- *  PURPOSE:     Minigame - GoJump vRP Edition (Original: https://github.com/HorrorClown/MTAGoJump)
-- *
-- ****************************************************************************
GoJump = inherit(Object)

function GoJump:constructor()
    self.font_JosefinSans50 = VRPFont(80, Fonts.JosefinSansThin) --dxCreateFont("files/fonts/JosefinSans-Thin.ttf", 50)
    self.font_JosefinSans20 = VRPFont(32, Fonts.JosefinSansThin) --dxCreateFont("files/fonts/JosefinSans-Thin.ttf", 20)
    self.font_JosefinSans20B = VRPFont(32, Fonts.JosefinSansThin, true) --dxCreateFont("files/fonts/JosefinSans-Thin.ttf", 20, true)
    self.font_JosefinSans13 = VRPFont(21, Fonts.JosefinSansThin) --dxCreateFont("files/fonts/JosefinSans-Thin.ttf", 13)

    self.state = "Home"
    self.width, self.height = 400, 600

    self.renderTarget = DxRenderTarget(self.width, self.height, false)
    self.white = tocolor(255, 255, 255)
    self.bg_white = tocolor(255, 255, 255, 50)
    self.currentID = 0
    self.sounds = true

    self.staticFloorHeight = 200
    self.staticOffset = 35
    self.staticDrawRange = 4
    self.staticJumpSpeed = 500

    self.Scores = {}
    self.Lines = {}
    self.Blocks = {}

    self:createLines()
    self:createBlocks()

    self:loadStatistics()
    self:loadImages()
    self:initAnimations()

    self:updateRenderTarget()
    self:keyBinds()

    self._onClientRender = bind(GoJump.onClientRender, self)
	self.m_fnRestore = bind(GoJump.onClientRestore, self)
    addEventHandler("onClientRender", root, self._onClientRender)
    addEventHandler("onClientResourceStop", resourceRoot, self._closeFunc)
	addEventHandler("onClientRestore", root, self.m_fnRestore)
	localPlayer:setFrozen(true)
end

function GoJump:destructor()
	--Save stats
	self:saveStatistics()

    --Kill timer
    if self.timer and self.timer:isValid() then self.timer:destroy() end

    --Remove Events
    removeEventHandler("onClientRender", root, self._onClientRender)
    removeEventHandler("onClientResourceStop", resourceRoot, self._closeFunc)
	removeEventHandler("onClientRestore", root, self.m_fnRestore)

    --unbind keys
    unbindKey("backspace", "down", self._closeFunc)
    unbindKey("space", "both", self._bindKeySpaceFunc)
    unbindKey("m", "down", self._bindKeyMusicFunc)
    unbindKey("c", "down", self._bindKeyBackgroundFunc)

	localPlayer:setFrozen(false)

    --Stop/delete animations
    delete(self.anim_player)
    delete(self.anim_player2)
    delete(self.anim_offset)

	self.threadClearFunc = function()
		for k, v in pairs(self.Blocks) do
			v.anim:delete()
		end
	end

	Thread:new(self.threadClearFunc, THREAD_PRIORITY_HIGHEST)
end

function GoJump:loadImages()
    self.images = {
        "titlescreen",
        "howto",
        "circle_play",
        "circle_stats",
        "circle_color",
        "circle_sound",
        "circle_sound_off",
        "player_l",
        "player_r",
        "arrow_down",
        "bg_1",
        "bg_2",
        "bg_3",
        "bg_4",
        "bg_5",
        "bg_6"
    }

    for _, img in ipairs(self.images) do
        self[img] = DxTexture(("files/images/GoJump/%s.png"):format(img))
    end

    self.background = math.random(1, 6)
end

function GoJump:keyBinds()
    self._bindKeySpaceFunc = bind(GoJump.onJump, self)

    self._bindKeyMusicFunc =
        function()
            self.sounds = not self.sounds
            self:updateRenderTarget()
        end

    self._bindKeyBackgroundFunc =
        function()
            --self.background = self[("bg_%s"):format(math.random(1,6))]

            self.background = self.background + 1
            if self.background > 6 then
                self.background = 1
            end

            self:updateRenderTarget()
        end

    self._bindKeyStatsFunc =
        function()
            if self.state == "Home" then
                self.state = "Stats"
                self:updateRenderTarget()

				triggerServerEvent("MinigameRequestHighscores", resourceRoot, "GoJump")
                --RPC:call("requestStats")
            elseif self.state == "Stats" then
                self.state = "Home"
                self:updateRenderTarget()
            end
        end

    self._closeFunc = bind(GoJump.destructor, self)

    bindKey("backspace", "down", self._closeFunc)
    bindKey("space", "both", self._bindKeySpaceFunc)
    bindKey("m", "down", self._bindKeyMusicFunc)
    bindKey("c", "down", self._bindKeyBackgroundFunc)
    --bindKey("s", "down", self._bindKeyStatsFunc)
end

function GoJump:initAnimations()
    self.playerHeight = self.Lines[self.currentID] - 32
    self.moveState = "r"
    self.playerX = 0
    self.heightOffset = 0
    self.anim_player = new(CAnimation, self, bind(GoJump.jumpDone, self), "playerHeight")
    self.anim_player2 = new(CAnimation, self, bind(GoJump.movePlayer, self), "playerX")
    self.anim_offset = new(CAnimation, self, "heightOffset")
end

function GoJump:loadStatistics()
    if fileExists("GoJump.stats") then
        local file = fileOpen("GoJump.stats", true)
        local fileContent = file:read(file:getSize())
        file:close()

        if fileContent then
            local decryptedContent = teaDecode(fileContent, getPlayerSerial())

            if fromJSON(decryptedContent) then
                self.stats = fromJSON(decryptedContent)

                self.highscore = self.stats.highscore
                self.average = self.stats.average
                return
            end
        end
    end

    self.stats = {
        playedCount = 0,
        totalScore = 0,
        totalJumps = 0,
        highscore = 0,
        average = 0,
    }

    self.highscore = self.stats.highscore
    self.average = self.stats.average
end

function GoJump:saveStatistics()
    local fileContent = toJSON(self.stats)
    local encryptedContent = teaEncode(fileContent, getPlayerSerial())
    local file = fileCreate("GoJump.stats")
    file:write(encryptedContent)
    file:close()
end

function GoJump:createLines()
	--TODO: Create lines dynamic
	for i = 0, 500 do
        local lineHeight = self.height - self.staticOffset - self.staticFloorHeight*i
        self.Lines[i] = lineHeight
    end
end

function GoJump:createBlocks()
	--TODO: Create blocks dynamic
    for i = 0, 500 do
		if self.Blocks[i] and self.Blocks[i].anim then
			self.Blocks[i].anim:delete()
		end

		local blockHeight = (self.height - self.staticOffset - self.staticFloorHeight*i) - 32
        local blockAnim = new(CAnimation, self, ("blockX_%s"):format(i))
        local moveState = math.random(1,2) == 1 and "l" or "r"
        local moveSpeed = self:getRandomSpeed(i)
        self[("blockX_%s"):format(i)] =  moveState == "r" and 0 or self.width-32

        self.Blocks[i] = {height = blockHeight, anim = blockAnim, state = moveState, speed = moveSpeed}
    end

    --Clear Blocks
    for _, c in ipairs({0, 2, 5, 10, 15, 20, 50, 75, 100, 140, 180, 200}) do
       self.Blocks[c].state = "none"
    end
end

function GoJump:getRandomSpeed(blockID)
    local def = {
        [1] = {min = 2000, max = 2100},
        [2] = {min = 2100, max = 2400},
        [3] = {min = 2400, max = 2700},
        [4] = {min = 2700, max = 3000},
        [5] = {min = 800, max = 1000},
    }

    local sep = math.random(1, math.random(1, 5) == 3 and 5 or 4)
    local randomSpeed = math.random(def[sep].min, def[sep].max)

    --Check speed of previous block
    if self.Blocks[blockID-1] then
        local previousBlockSpeed = self.Blocks[blockID-1].speed

        local diff = math.abs(previousBlockSpeed - randomSpeed)
        while diff <= 350 do
            sep = math.random(1, math.random(1, 5) == 2 and 5 or 4)
            randomSpeed = math.random(def[sep].min, def[sep].max)

            diff = math.abs(previousBlockSpeed - randomSpeed)
        end

    end

    return randomSpeed
end

function GoJump:movePlayer()
    if self.moveState == "r" then
        self.anim_player2:startAnimation(1500, "Linear", self.width-32)
        self.moveState = "l"
    elseif self.moveState == "l" then
        self.anim_player2:startAnimation(1500, "Linear", 0)
        self.moveState = "r"
    end
end

function GoJump:onJump(_, str_State)
    if self.state ~= "Play" then
        if str_State == "down" and self.state == "Home" then
			self.showHelp = getTickCount()
            self.state = "Play"
            self.ignoreUp = true
            self:movePlayer()
        end
        return
    end

    if str_State == "down" then
        if self.anim_player:isAnimationRendered() then
            self.ignoreUp = true
            return
        end

        --playSound("res/sound/jump.wav")
        self:playSound("jump")
        self.anim_player:startAnimation(self.staticJumpSpeed, "OutQuad",  self.Lines[self.currentID + 1] - 32)
        self.stats.totalJumps = self.stats.totalJumps + 1
    elseif str_State == "up" then
        if self.ignoreUp then
            self.ignoreUp = false
            return
        end

        if self.anim_player:isAnimationRendered() then
           --Calculate down speed based on playerheight
           local targetHeight = self.height - (self.Lines[self.currentID + 1] + self.heightOffset)
           local currentHeight = self.height - (self.playerHeight + self.heightOffset)

           local process = 1/targetHeight*currentHeight
           local duration = self.staticJumpSpeed*process
           --outputChatBox(("Process: %s | duration: %s"):format(process, duration))

            self.anim_player:startAnimation(duration, "InQuad", self.Lines[self.currentID] - 32)
        else
            --playSound("res/sound/point.wav")
            self:playSound("point")
            self.currentID = self.currentID + 1
            self.anim_offset:startAnimation(2500, "OutQuad", self.currentID*self.staticFloorHeight)

            if self.currentID == self.average then
               --playSound("res/sound/average.wav")
               self:playSound("average")
            end

            if self.highscore and self.currentID == self.highscore then
                --playSound("res/sound/highscore.wav")
                self:playSound("highscore")
			end

			self:clearBlocksBelow()
        end
    end
end

function GoJump:clearBlocksBelow()
	local blockBelow = self.Blocks[self.currentID-2]
	if blockBelow and blockBelow.anim then
		blockBelow.anim:delete()
	end
end

function GoJump:jumpDone()
    --Todo: improve jump method with callback function
end

function GoJump:playerDied()
    if self.state == "dead" then return end
    --playSound("res/sound/dead.wav")
    self:playSound("dead")

    self.state = "dead"
    self.lastScore = self.currentID

    --Highscore
    if self.lastScore > self.highscore then
        self.highscore = self.lastScore
        self.stats.highscore = self.lastScore
    end
	triggerServerEvent("MinigameSendHighscore", resourceRoot, "GoJump", self.lastScore)

    --Average
    self.stats.totalScore = self.stats.totalScore + self.lastScore
    self.stats.playedCount = self.stats.playedCount + 1
    self.stats.average = math.floor(self.stats.totalScore/self.stats.playedCount)
    self.average = self.stats.average

    --Reset values
    self.currentID = 0
    self.playerHeight = self.Lines[self.currentID] - 32
    self.moveState = "r"
    self.playerX = 0
    self.heightOffset = 0

    --Stop animations
    self.anim_player:stopAnimation()
    self.anim_player2:stopAnimation()
    self.anim_offset:stopAnimation()

    for i = 0, #self.Blocks do
        self.Blocks[i].anim:stopAnimation()
    end

    --Back to titlescreen
    self.timer = setTimer(
        function()
            --Recreate blocks
            self:createBlocks()

            self.state = "Home"
            self:updateRenderTarget()
            self.currentID = 0
        end
        , 2500, 1)
end

function GoJump:updateRenderTarget()
    if not self.renderTarget then return end
    self.renderTarget:setAsTarget(true)

    dxDrawImage(0, 0, 400, 600, self[("bg_%s"):format(self.background)])

    if self.state == "Home" then
        dxDrawImage(0, 0, 400, 600, self.titlescreen)

        if self.lastScore then
            dxDrawText(self.lastScore, 0, 120, self.width, 0, self.white, 1, getVRPFont(self.font_JosefinSans50), "center")
        end

        if self.highscore then
            dxDrawText("Best: " .. self.highscore, 0, 200, self.width, 0, self.white, 1, getVRPFont(self.font_JosefinSans20), "center")
        end

        dxDrawImage(self.width/2 - 96/2, self.height/2 - 96/2, 96, 96, self.circle_play)
        dxDrawImage(self.width/2 - 48/2 - 120, self.height/2 - 48/2, 48, 48, self.circle_color)
        dxDrawImage(self.width/2 - 48/2 + 120, self.height/2 - 48/2, 48, 48, self.sounds and self.circle_sound or self.circle_sound_off)

        dxDrawImage(self.width/2 - 18/2, self.height/2 + 96/2, 18, 18, self.arrow_down)
        dxDrawImage(self.width/2 - 48/2 - 120 + (48/2-18/2), self.height/2 - 48/2 + 48, 18, 18, self.arrow_down)
        dxDrawImage(self.width/2 - 48/2 + 120 + (48/2-18/2), self.height/2 - 48/2 + 48, 18, 18, self.arrow_down)

        dxDrawText("space", self.width/2 - 48 , self.height/2 + 96/2 + 5, self.width/2 + 48, 0, self.white, 1, getVRPFont(self.font_JosefinSans13), "center")
        dxDrawText("c", self.width/2 - 48/2 - 120, self.height/2 - 48/2 + 48 + 5, self.width/2 - 48/2 - 120 + 48, 0, self.white, 1, getVRPFont(self.font_JosefinSans13), "center")
        dxDrawText("m", self.width/2 - 48/2 + 120, self.height/2 - 48/2 + 48 + 5, self.width/2 - 48/2 + 120 + 48, 0, self.white, 1, getVRPFont(self.font_JosefinSans13), "center")
    end

    if self.state == "Stats" then
        dxDrawImageSection(0, 0, 400, 400, 0, 0, 400, 400, self.titlescreen)
        dxDrawText("Pos.", 10, 165, x, y, self.white, 1, getVRPFont(self.font_JosefinSans20B))
        dxDrawText("Name", 70, 165, x, y, self.white, 1, getVRPFont(self.font_JosefinSans20B))
        dxDrawText("Score", 320, 165, x, y, self.white, 1, getVRPFont(self.font_JosefinSans20B))

        for i, score in ipairs(self.Scores) do
            if i <= 10 then
                --First row
                dxDrawText(i, 10, 200 + (i-1)*30, x, y, self.white, 1, getVRPFont(self.font_JosefinSans20))

                --Secconds row
                dxDrawText(clearText(score.name), 70, 200 + (i-1)*30, x, y, self.white, 1, getVRPFont(self.font_JosefinSans20))

                --Third row
                dxDrawText(score.score, 320, 200 + (i-1)*30, x, y, self.white, 1, getVRPFont(self.font_JosefinSans20))
            end
        end

        dxDrawText("Press 's' again to go back", 0, 550, 400, 600, self.white, 1, getVRPFont(self.font_JosefinSans20B), "center")
    end

    if self.state == "Play" then
        for i = 0, #self.Lines do
			if i - self.staticDrawRange < self.currentID and i + self.staticDrawRange > self.currentID  then
				local lineColor = self.white
				if self.currentID == 0 and not (i == 0 or i == 1) then lineColor = self.bg_white end

				dxDrawLine(0, self.Lines[i] + self.heightOffset, self.width, self.Lines[i] + self.heightOffset, lineColor, 3)
                dxDrawText(i, 0, self.Lines[i] + self.heightOffset, self.width, 0, lineColor, 1, getVRPFont(self.font_JosefinSans20), "right")

                if i == self.average then
                    dxDrawText("average score", 5, self.Lines[i] + self.heightOffset - 5, self.width, 0, self.currentID ~= 0 and self.white or self.bg_white, 1, getVRPFont(self.font_JosefinSans20), self.average == self.highscore and "center" or "left", "top", false, false, false, true)
                end

                if i == self.highscore then
                    dxDrawText("highscore", 5, self.Lines[i] + self.heightOffset - 5, self.width, 0, self.currentID ~= 0 and self.white or self.bg_white, 1, getVRPFont(self.font_JosefinSans20), "left", "top", false, false, false, true)
                end
            end
        end

        for i = 0, #self.Blocks do
            if self.Blocks[i].state ~= "none" then
                if i - self.staticDrawRange < self.currentID and i + self.staticDrawRange > self.currentID  then
                    dxDrawRectangle(self[("blockX_%s"):format(i)], self.Blocks[i].height + self.heightOffset, 32, 32, self.white)

                    if not self.Blocks[i].anim:isAnimationRendered() then
                        if self.Blocks[i].state == "r" then
                            self.Blocks[i].state = "l"
                            self.Blocks[i].anim:startAnimation(self.Blocks[i].speed, "Linear", self.width-32)
                        else
                            self.Blocks[i].state = "r"
                            self.Blocks[i].anim:startAnimation(self.Blocks[i].speed, "Linear", 0)
                        end
                    end
                end
            end
        end

		dxDrawText(self.currentID, 0, 0, self.width, 100, self.currentID ~= 0 and self.white or self.bg_white, 1, getVRPFont(self.font_JosefinSans50), "center", "center")
		if self.currentID == 0 then	dxDrawImage(self.width/2 - 535/4, 50, 535/2, 463/2, self.howto) end

        dxDrawImage(self.playerX, self.playerHeight + self.heightOffset, 32, 32, self[("player_%s"):format(self.moveState == "r" and "l" or "r")])
    end

    dxSetRenderTarget()
end

function GoJump:onClientRender()
    if not self.renderTarget then return end

    --Collide detection
    if self.state == "Play" then
        for i = 0, #self.Blocks do
            if self.Blocks[i].state ~= "none" then
                if i - self.staticDrawRange < self.currentID and i + self.staticDrawRange > self.currentID  then
                    local playerX = self.playerX
                    local playerY = self.playerHeight + self.heightOffset
                    local blockX = self[("blockX_%s"):format(i)]
                    local blockY = self.Blocks[i].height + self.heightOffset

                    local dis = math.floor(getDistanceBetweenPoints2D(playerX, playerY, blockX, blockY))
                    --dxDrawText(("Distance to '%s': %s"):format(i, dis), 20, (y/2-100) + (i - self.currentID)*25, x, y, tocolor(0, 0, 0), 2)

                    if dis <= 25 then
                        self:playerDied()
                    end
                end
            end
        end
    end

    --dxDrawImage(x/2-200 / 1920*x, y/2-300 / 1080*y, 400 / 1920 * x, 600 / 1080 * y, self.renderTarget)
    dxDrawImage(screenWidth/2-200, screenHeight/2-300, 400, 600, self.renderTarget)
end

function GoJump:onClientRestore(didClearRenderTargets)
	if didClearRenderTargets then
		self:updateRenderTarget()
	end
end

function GoJump:playSound(sSound)
    if self.sounds then
        playSound(("files/audio/GoJump/%s.wav"):format(sSound))
    end
end
