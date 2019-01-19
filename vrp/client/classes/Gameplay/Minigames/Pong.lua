-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Gameplay/Minigames/Pong.lua
-- *  PURPOSE:     Pong Game - Client
-- *
-- ****************************************************************************
Pong = inherit(Singleton)
addRemoteEvents{"pongGameSession", "pongUpdateGameplay", "pongSetGameState", "pongSetEnemyPosition", "pongInterpolateEnemyPosition"}

function Pong:constructor(eTargetPlayer, playerType)
    self.m_TargetPlayer = eTargetPlayer
    self.m_LocalPlayerType = playerType
    self.FPS = {startTick = getTickCount(), counter = 0, frames = 0}

    self.WIDTH = 960
    self.HEIGHT = 540
    self.m_SoundsEnabled = true

    self.m_RT_Background = DxRenderTarget(self.WIDTH,  self.HEIGHT)

    self.m_State = "lobby"
    self:initAnimations()
    self:updateRenderTarget()
    self:keyBinds()

    self.fn_Render =                    bind(Pong.render, self)
    self.fn_SetGameState =              bind(Pong.setGameState, self)
    self.fn_SetEnemyPosition =          bind(Pong.setEnemyPosition, self)
    self.fn_InterpolateEnemyPosition =  bind(Pong.interpolateEnemyPosition, self)
    self.fn_UpdateGameplay =            bind(Pong.updateGameplay, self)

    addEventHandler("onClientRender", root, self.fn_Render)
    addEventHandler("pongSetGameState", root, self.fn_SetGameState)
    addEventHandler("pongUpdateGameplay", root, self.fn_UpdateGameplay)
    addEventHandler("pongSetEnemyPosition", root, self.fn_SetEnemyPosition)
    addEventHandler("pongInterpolateEnemyPosition", root, self.fn_InterpolateEnemyPosition)
end

function Pong:destructor()
	if self.m_BackgroundMusic then stopSound(self.m_BackgroundMusic) end
	localPlayer:setFrozen(false)

	toggleControl("left", true)
	toggleControl("right", true)
	toggleControl("forwards", true)
	toggleControl("backwards", true)

    removeEventHandler("onClientRender", root, self.fn_Render)
	removeEventHandler("pongSetGameState", root, self.fn_SetGameState)
	removeEventHandler("pongUpdateGameplay", root, self.fn_UpdateGameplay)
	removeEventHandler("pongSetEnemyPosition", root, self.fn_SetEnemyPosition)
	removeEventHandler("pongInterpolateEnemyPosition", root, self.fn_InterpolateEnemyPosition)

	unbindKey("backspace", "down", self.fn_CloseFunc)
	unbindKey("space", "down", self.fn_OnReady)
	unbindKey("w", "both", self.fn_MovePlayer)
	unbindKey("s", "both", self.fn_MovePlayer)
	unbindKey("arrow_u", "both", self.fn_MovePlayer)
	unbindKey("arrow_d", "both", self.fn_MovePlayer)

	self.anim_PosLocalPlayer:delete()
	self.anim_PosRemotePlayer:delete()
	self.anim_BallPosX:delete()
	self.anim_BallPosY:delete()
end

function Pong:updateGameplay(tPoints, ballDirectionX, ballDirectionY)
    self.m_LocalPoints = tPoints[localPlayer]
    self.m_RemotePoints = tPoints[self.m_TargetPlayer]
    self.m_Counter = 0

    self.m_DefaultPlayerMoveSpeed = 1000 --speed value in ms for animation duration
    self.m_PlayerMoveSpeed = self.m_DefaultPlayerMoveSpeed

    self.m_PlayerWidth = 7
    self.m_PlayerHeight = 80

    self.m_LocalPlayerPosX = 20
    self.m_LocalPlayerPosY = self.HEIGHT/2-self.m_PlayerHeight/2

    self.m_RemotePlayerPosX = self.WIDTH - 20 - self.m_PlayerWidth
    self.m_RemotePlayerPosY = self.HEIGHT/2-self.m_PlayerHeight/2

    self.m_DefaultBallSpeed = 3000
    self.m_BallSpeedX = self.m_DefaultBallSpeed
    self.m_BallSpeedY = self.m_DefaultBallSpeed*(self.HEIGHT/self.WIDTH)
    self.m_BallWidth = 15
    self.m_BallHeight = 15
    self.m_BallPosX = self.WIDTH/2-self.m_BallWidth/2
    self.m_BallPosY = self.HEIGHT/2-self.m_BallHeight/2
    self.m_BallDirectionX = self.m_LocalPlayerType == ballDirectionX and "left" or "right"
    self.m_BallDirectionY = ballDirectionY
end

function Pong:setEnemyPosition(nPosition)
    self.anim_PosRemotePlayer:stopAnimation()
    self.anim_PosRemotePlayer:startAnimation(200, "Linear", nPosition)
end

function Pong:interpolateEnemyPosition(sDirection)
    if sDirection == "up" then
        local duration = self.m_PlayerMoveSpeed*self.m_RemotePlayerPosY/(self.HEIGHT - self.m_PlayerHeight)
        if not duration or duration == 0 then return end
        self.anim_PosRemotePlayer:startAnimation(duration, "Linear", 0)
    else
        local duration = self.m_PlayerMoveSpeed*(1-(self.m_RemotePlayerPosY/(self.HEIGHT - self.m_PlayerHeight)))
        if not duration or duration == 0 then return end
        self.anim_PosRemotePlayer:startAnimation(duration, "Linear", self.HEIGHT - self.m_PlayerHeight)
    end
end

function Pong:initAnimations()
    self.fn_HorizontalBallAnimationDone =
    function()
        -- Player collision detection
        if self.m_BallDirectionX == "left" then
            if not (self.m_BallPosY + self.m_BallHeight >= self.m_LocalPlayerPosY and self.m_BallPosY < self.m_LocalPlayerPosY + self.m_PlayerHeight) then
                self:GameFailed()
                return
            end

            self.m_BallDirectionX = "right"
        else
            --if not (self.m_BallPosY + self.m_BallHeight >= self.m_RemotePlayerPosY and self.m_BallPosY < self.m_RemotePlayerPosY + self.m_PlayerHeight) then
                --self:GameFailed("remote")
               -- return
            --end

            self.m_BallDirectionX = "left"
        end

        self:playSound("shot")
        self.m_Counter = self.m_Counter + 1
        self.m_BallSpeedX = self.m_BallSpeedX - (self.m_Counter*2)
        self.m_BallSpeedY = self.m_BallSpeedX*(self.HEIGHT/self.WIDTH)

        if self.m_BallDirectionX == "left" then
            local duration = self.m_BallSpeedX*(self.m_BallPosX/(self.WIDTH - self.m_BallWidth))
            self.anim_BallPosX:startAnimation(duration, "Linear", self.m_LocalPlayerPosX + self.m_PlayerWidth)
        else
            local duration = self.m_BallSpeedX*(1-(self.m_BallPosX/(self.WIDTH - self.m_BallWidth)))
            self.anim_BallPosX:startAnimation(duration, "Linear", self.m_RemotePlayerPosX - self.m_BallWidth)
        end
    end

    self.fn_VerticalBallAnimationDone =
    function()
        self.m_BallDirectionY = not self.m_BallDirectionY
        self:playSound("wall")

        if self.m_BallDirectionY then
            local duration = self.m_BallSpeedY*(self.m_BallPosY/(self.HEIGHT - self.m_BallWidth))
            self.anim_BallPosY:startAnimation(duration, "Linear", 0)
        else
            local duration = self.m_BallSpeedY*(1-(self.m_BallPosY/(self.HEIGHT - self.m_BallWidth)))
            self.anim_BallPosY:startAnimation(duration, "Linear", self.HEIGHT - self.m_BallHeight)
        end
    end

    self.anim_PosLocalPlayer = CAnimation:new(self, "m_LocalPlayerPosY")
    self.anim_PosRemotePlayer = CAnimation:new(self, "m_RemotePlayerPosY")

    self.anim_BallPosX = CAnimation:new(self, self.fn_HorizontalBallAnimationDone, "m_BallPosX")
    self.anim_BallPosY = CAnimation:new(self, self.fn_VerticalBallAnimationDone, "m_BallPosY")
end

---
-- Managing Game States (controlled by server)
---

function Pong:setGameState(sState, data)
    if sState == "play" then
        self:GameStart()
        self:updateRenderTarget()
    elseif sState == "failed" then
        self.m_State = "failed"
        self.anim_BallPosX:stopAnimation()
        self.anim_BallPosY:stopAnimation()
        self.anim_PosLocalPlayer:stopAnimation()
        self.anim_PosRemotePlayer:stopAnimation()

        stopSound(self.m_BackgroundMusic)
		self.m_BackgroundMusic = false
        self:playSound("fail")
    elseif sState == "ready" then
        self.m_State = "ready"
        self:updateRenderTarget()
	elseif sState == "playerWon" then
		self.m_State = "playerWon"
		self.m_PlayerWon = data
		self:updateRenderTarget()
	elseif sState == "close" then
		delete(self)
    end
end

function Pong:GameFailed()
    if self.m_State ~= "play" then return end

    triggerServerEvent("pongPlayerFailed", resourceRoot)

    self.m_State = "failed"
    self.anim_BallPosX:stopAnimation()
    self.anim_BallPosY:stopAnimation()
    self.anim_PosLocalPlayer:stopAnimation()
    self.anim_PosRemotePlayer:stopAnimation()

    stopSound(self.m_BackgroundMusic)
	self.m_BackgroundMusic = false
    self:playSound("fail")
end

function Pong:GameStart()
    if self.m_State == "lobby" or self.m_State == "ready" then
        self.m_State = "play"
        self.m_BackgroundMusic = playSound("files/audio/Pong/background.mp3", true)

        if self.m_BallDirectionX == "left" then
            local duration = self.m_BallSpeedX*(self.m_BallPosX/(self.WIDTH - self.m_BallWidth))
            self.anim_BallPosX:startAnimation(duration, "Linear", self.m_LocalPlayerPosX + self.m_PlayerWidth)
        else
            local duration = self.m_BallSpeedX*(1-(self.m_BallPosX/(self.WIDTH - self.m_BallWidth)))
            self.anim_BallPosX:startAnimation(duration, "Linear", self.m_RemotePlayerPosX - self.m_BallWidth)
        end

        if self.m_BallDirectionY then
            local duration = self.m_BallSpeedY*(self.m_BallPosY/(self.HEIGHT - self.m_BallWidth))
            self.anim_BallPosY:startAnimation(duration, "Linear", 0)
        else
            local duration = self.m_BallSpeedY*(1-(self.m_BallPosY/(self.HEIGHT - self.m_BallWidth)))
            self.anim_BallPosY:startAnimation(duration, "Linear", self.HEIGHT - self.m_BallHeight)
        end
    end
end

---
-- Sounds
---

function Pong:playSound(sSound)
    if self.m_SoundsEnabled then
        playSound(("files/audio/Pong/%s.mp3"):format(sSound))
    end
end

---
-- KeyBinds
---

function Pong:keyBinds()
    self.fn_OnReady =
        function()
            if not self.m_IsReady then
                self.m_IsReady = true
                self:updateRenderTarget()
                triggerServerEvent("pongPlayerReady", resourceRoot)
            end
        end

    self.fn_MovePlayer =
    function(_, sKeyState, sDirection)
        if self.m_State ~= "play" then return end
        if sKeyState == "up" then self.anim_PosLocalPlayer:stopAnimation() triggerServerEvent("pongPlayerMove", resourceRoot, false, self.m_LocalPlayerPosY) return end

        triggerServerEvent("pongPlayerMove", resourceRoot, true, sDirection)
        if sDirection == "up" then
            local duration = self.m_PlayerMoveSpeed*(self.m_LocalPlayerPosY/(self.HEIGHT - self.m_PlayerHeight))
            self.anim_PosLocalPlayer:startAnimation(duration, "Linear", 0)
        else
            local duration = self.m_PlayerMoveSpeed*(1-(self.m_LocalPlayerPosY/(self.HEIGHT - self.m_PlayerHeight)))
            self.anim_PosLocalPlayer:startAnimation(duration, "Linear", self.HEIGHT - self.m_PlayerHeight)
        end
	end

	self.fn_CloseFunc =
		function()
			triggerServerEvent("pongPlayerLeave", localPlayer)
		end

	bindKey("backspace", "down", self.fn_CloseFunc)
    bindKey("space", "down", self.fn_OnReady)
    bindKey("w", "both", self.fn_MovePlayer, "up")
    bindKey("s", "both", self.fn_MovePlayer, "down")
    bindKey("arrow_u", "both", self.fn_MovePlayer, "up")
    bindKey("arrow_d", "both", self.fn_MovePlayer, "down")

	localPlayer:setFrozen(true)
	toggleControl("left", false)
	toggleControl("right", false)
	toggleControl("forwards", false)
	toggleControl("backwards", false)
end

---
-- Rendering
---

local dxDrawRectangle = dxDrawRectangle
function Pong:updateRenderTarget()
    self.m_RT_Background:setAsTarget(true)

    if self.m_State == "lobby" then
        dxDrawText("°MTAPong°", 0, 100, self.WIDTH, self.HEIGHT, tocolor(255, 255, 255), 3, "default", "center")
        dxDrawText("°Erreiche 10 Punkte um zu gewinnen°\n'Backspace' = Beenden", 0, 480, self.WIDTH, self.HEIGHT, tocolor(255, 255, 255), 1.5, "default", "center")
        if not self.m_IsReady then
            dxDrawText("°Press 'space' when you're ready!°", 0, 150, self.WIDTH, self.HEIGHT, tocolor(255, 255, 255), 3, "default", "center")
        end
        dxSetRenderTarget()
        return
    end

	if self.m_State == "playerWon" then
		dxDrawText("°Ping Pong°", 0, 100, self.WIDTH, self.HEIGHT, tocolor(255, 255, 255), 3, "default", "center")
		dxDrawText(("°%s hat das Spiel gewonnen!°"):format(self.m_PlayerWon:getName()), 0, 150, self.WIDTH, self.HEIGHT, tocolor(255, 255, 255), 3, "default", "center")
		dxSetRenderTarget()
		return
	end

    -- Line
    for i = 0, self.HEIGHT/50 do
       dxDrawRectangle(self.WIDTH/2-3/2, i*50, 3, 40, tocolor(255, 255, 255, 100))
    end

    -- Name and points
    dxDrawText(localPlayer.name, 0, 5, self.WIDTH/2 - 15, 50, tocolor(255, 255, 255), 1, "default", "right", "top", false, false, false, true)
    dxDrawText(self.m_LocalPoints, 0, 15, self.WIDTH/2 - 15, 50, tocolor(255, 255, 255), 2.5, "default", "right")
    dxDrawText(self.m_TargetPlayer.name, self.WIDTH/2 + 15, 5, self.WIDTH, 50, tocolor(255, 255, 255), 1, "default", "left", "top", false, false, false, true)
    dxDrawText(self.m_RemotePoints, self.WIDTH/2 + 15, 15, self.WIDTH, 50, tocolor(255, 255, 255), 2.5, "default", "left")

    -- Players
    dxDrawRectangle(self.m_LocalPlayerPosX, self.m_LocalPlayerPosY, self.m_PlayerWidth, self.m_PlayerHeight, tocolor(255, 255, 255))
    dxDrawRectangle(self.m_RemotePlayerPosX, self.m_RemotePlayerPosY, self.m_PlayerWidth, self.m_PlayerHeight, tocolor(255, 255, 255))

    -- Ball
    dxDrawRectangle(self.m_BallPosX, self.m_BallPosY, self.m_BallWidth, self.m_BallHeight, tocolor(255, 255, 255))

    --FPS/Ping/Counter/Ballspeed
    dxDrawText(("F:%s|P:%s(%s)|C:%s|S:%s"):format(self.FPS.frames, localPlayer.ping, self.m_TargetPlayer.ping + localPlayer.ping, self.m_Counter, self.m_BallSpeedX), 0, 0, self.WIDTH, self.HEIGHT, tocolor(255, 255, 255, 100), 1, "default", "right", "bottom")
    dxSetRenderTarget()
end

function Pong:render()
    --Update FPS
    self.FPS.counter = self.FPS.counter + 1
    if getTickCount() - self.FPS.startTick >= 1000 then
        if self.FPS.frames ~= self.FPS.counter then
            self.FPS.frames = self.FPS.counter
            if self.m_State == "play" then
                self:updateRenderTarget()
            end
        end

        self.FPS.counter = 0
        self.FPS.startTick = getTickCount()
    end

    --Draw the game
    dxDrawImage(screenWidth/2-self.WIDTH/2, screenHeight/2-self.HEIGHT/2, self.WIDTH, self.HEIGHT, self.m_RT_Background)
end

addEventHandler("pongGameSession", root,
    function(eTarget, sLocalType, tOptions)
        local instance = Pong:new(eTarget, sLocalType)
        instance:updateGameplay(unpack(tOptions))
    end
)

--[[
--TODO: States (Client/Server)
lobby			-- Auswahl Liste offene Spiele
wait			-- Im Spiel, warte bis beide Spieler bereit sind (leertaste drücken)
startCountdown	-- Countdown wird bei beiden Spielern gestartet
play			-- Während des Spielens
failed			-- Spieler gestorben, aktualisiere Punkte und setze nach 3 Sekunden automatisch auf wait
win				-- Ein Spieler hat die definierte Punktzahl erreicht
enemyLeaved		-- Gegner nicht mehr vorhanden, return to lobby
 ]]
