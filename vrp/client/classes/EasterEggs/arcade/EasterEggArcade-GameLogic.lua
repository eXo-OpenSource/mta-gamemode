EasterEggArcade.GameLogic = inherit(Object)

function EasterEggArcade.GameLogic:constructor()
	self.m_Tick = 0
	self.m_LastUpdated = getTickCount()
	self.m_UpdateTick = 0
	self.m_AnimationTick = 0
	self.m_GameTick = bind(self.update, self)
	self.m_GameKey = bind(self.key, self)
	self.m_Render = EasterEggArcade.Render:new(EASTEREGG_WINDOW[1], EASTEREGG_WINDOW[2])
	self.m_Sound = EasterEggArcade.Audio:new()
	self.m_HUD = EasterEggArcade.HUD:new()
	self.m_UpdateQueue = {}
	self.m_AIState = {}
	self.m_PressedKeys = {}
	addEventHandler("onClientPreRender", root, self.m_GameTick)
	addEventHandler("onClientKey", root, self.m_GameKey)
	self:setup()
	guiSetInputEnabled(true)
	setElementFrozen(localPlayer, true)
end

function EasterEggArcade.GameLogic:destructor()
	self.m_Sound:delete()
	self.m_Player:delete()
	self.m_Enemy:delete()
	self.m_Render:delete()
	self.m_HUD:delete()
	self.m_Arena:delete()
	if isTimer(self.m_SpawnTimer) then killTimer(self.m_SpawnTimer) end
	if isTimer(self.m_AITimer) then killTimer(self.m_AITimer) end
	if isTimer(self.m_AITimer2) then killTimer(self.m_AITimer2) end
	removeEventHandler("onClientPreRender", root, self.m_GameTick)
	removeEventHandler("onClientKey", root, self.m_GameKey)
	guiSetInputEnabled(false)
	setElementFrozen(localPlayer, false)
end

function EasterEggArcade.GameLogic:calculateSpawn()
	local ratio = {x = EASTEREGG_WINDOW[2].x / EASTEREGG_NATIVE_RATIO.x , y = EASTEREGG_WINDOW[2].y / EASTEREGG_NATIVE_RATIO.y } 
	local player = {x=EASTEREGG_WINDOW[1].x+((64)*ratio.x), y=(256)*ratio.y}
	local arena = {x=512*ratio.x, y=256*ratio.y}
	local enemy = {x=EASTEREGG_WINDOW[1].x+(512+256)*ratio.x,y=256*ratio.y}
	return arena, player, enemy
end

function EasterEggArcade.GameLogic:setup()
	local arena, player, enemy = self:calculateSpawn()
	local ratio = {x = EASTEREGG_WINDOW[2].x / EASTEREGG_NATIVE_RATIO.x , y = EASTEREGG_WINDOW[2].y / EASTEREGG_NATIVE_RATIO.y } 
	self.m_Arena = EasterEggArcade.Arena:new( self, self.m_Render, {x=512, y=256}, {x=1024, y=512})
	self.m_HUD:setHealthPosition( {x=512+(64*ratio.x), y=256+16}, {x=256, y=128})
	self.m_HUD:setEnemyPosition( {x=512+((512+128)*ratio.x), y=256+16}, {x=256, y=128})
	
	self.m_Player = EasterEggArcade.Player:new(false)
	self.m_Player:setHealth(100)
	self.m_Player:setMaxHealth(100)
	self.m_Player:setPosition(player.x, player.y)
	self.m_Player:setSprite(1)
	self:addToUpdateQueue( self.m_Player )
	self.m_Render:addToQueue( self.m_Player )
	
	
	self.m_Enemy = EasterEggArcade.Enemy:new(false)
	self.m_Enemy:setHealth(400)
	self.m_Enemy:setMaxHealth(400)
	self.m_Enemy:setColor(tocolor(200, 0, 0, 255))
	self.m_Enemy:setPosition(enemy.x, enemy.y)
	self.m_Enemy:setMirrored(true)
	self.m_Enemy:setSprite(1)
	self:addToUpdateQueue( self.m_Enemy)
	self.m_Render:addToQueue( self.m_Enemy)
	
	
	self:spawnRandomProjectiles()
	self:startAI()
	self.m_Sound:playMusic()
end

function EasterEggArcade.GameLogic:addToUpdateQueue( object ) 
	table.insert(self.m_UpdateQueue, object ) 
end

function EasterEggArcade.GameLogic:removeFromQueue(object)
	for i = 1, #self.m_UpdateQueue do 
		if self.m_UpdateQueue[i] == object then 
			table.remove(self.m_UpdateQueue, i)
		end
	end
end

function EasterEggArcade.GameLogic:removeObject( object ) 
	self.m_Render:removeFromQueue( object ) 
	self:removeFromQueue( object )
end

function EasterEggArcade.GameLogic:update()
	local x,y
	local now = getTickCount()
	if (now) > EASTEREGG_SLEEP_UPDATETICK + self.m_LastUpdated then
		self.m_UpdateTick = self.m_UpdateTick + 1
		self.m_Tick = self.m_Tick + 1 
		for i = 1, #self.m_UpdateQueue do 
			if self.m_UpdateQueue[i] then
				if self.m_UpdateQueue[i].update then 
					if self.m_UpdateQueue[i] == self.m_Player then
						x,y = self.m_Player:getPosition()
					end
					self.m_UpdateQueue[i]:update( self.m_Tick )
				end
			end
		end
		self.m_LastUpdated = now
	end
	self.m_AnimationTick = self.m_AnimationTick + 1
	if self.m_Tick >= EASTEREGG_TICK_CAP then self.m_Tick = 0 end
	if self.m_AnimationTick > EASTEREGG_TICK_CAP then self.m_AnimationTick = 0 end
end

function EasterEggArcade.GameLogic:checkVertical( obj, vec ) 
	local x,y = obj:getPosition()
	local width, height = obj:getBound()
	local fX, fY, fWidth, fHeight = self.m_Arena:getFloor()
	if fX and fY and width and height then
		if (y+height+vec.y) > fY then 
			obj:setState("standing")
			return false
		end
		obj:setState("falling")
		return true
	end
end

function EasterEggArcade.GameLogic:checkHorizontal( obj, vec ) 
	local x,y = obj:getPosition()
	local width, height = obj:getBound()
	local fX, fY, fWidth, fHeight = self.m_Arena:getFloor()
	if fX and fY and width and height then
		if (x+vec.x > fX) and ((x+width+vec.x) < fX+fWidth) then 
			return true
		end
		return false
	end
end


function EasterEggArcade.GameLogic:spawnRandomProjectiles()
	self.m_SpawnBind = bind(self.spawnProjectile, self)
	self.m_SpawnTimer = setTimer(self.m_SpawnBind, 1000, 0)
end

function EasterEggArcade.GameLogic:startAI() 
	self.m_AIBind = bind(self.changeAIMove, self)
	self.m_AITimer = setTimer(self.m_AIBind, 500, 0)
	self.m_AIBind2 = bind(self.changeAIDirection, self)
	self.m_AITimer2 = setTimer(self.m_AIBind2, 700, 0)
end

function EasterEggArcade.GameLogic:spawnProjectile() 
	local px, py = self.m_Player:getPosition()
	local width, height = self.m_Player:getBound()
	local fX, fY  = self.m_Enemy:getPosition()
	local randomHeight = math.random(0, height*0.6)
	local fWidth, fHeight = self.m_Enemy:getBound()
	proj = EasterEggArcade.Projectile:new(false)
	if px < fX then
		proj:setDirection({x=-7*EASTEREGG_PROJECTILE_SPEED;y=0})
		proj:setMirrored(true)
		proj:setPosition(fX, fY+randomHeight)
		self.m_Enemy:setMirrored(true)
	else 
		proj:setDirection({x=7*EASTEREGG_PROJECTILE_SPEED;y=0})
		proj:setMirrored(false)
		self.m_Enemy:setMirrored(false)
		proj:setPosition(fX+fWidth*0.4, fY+randomHeight)
	end
	proj:setColor(tocolor(255, 0, 0, 255))
	self:addToUpdateQueue( proj)
	self.m_Render:addToQueue( proj)
	self.m_AIState["punch"] = true
end


function EasterEggArcade.GameLogic:onHit( obj ) 
	if obj.getHealth then
		local health = obj:getHealth()
		health = health - 9 
		if health < 0 then health = 0 end
		obj:setHealth( health ) 
		if health == 0 then 
			if obj == self.m_Player then
				if not self:isGameOver() and not self:isGameWon() then
					EasterEggArcade.Game:getSingleton():getGameLogic():getSound():playGameOver()
					self:gameOver() 
				end
			else 
				if not self:isGameWon() and not self:isGameOver() then
					EasterEggArcade.Game:getSingleton():getGameLogic():getSound():playWin()
					self:gameWon()
				end
			end
		end
		if obj == self.m_Player then 
			EasterEggArcade.Game:getSingleton():getGameLogic():getSound():playDamage()
			self.m_HUD:shake()
		elseif obj == self.m_Enemy then
			EasterEggArcade.Game:getSingleton():getGameLogic():getSound():playHit()
		end
		self.m_HUD:addDamage( obj )
	end
end

function EasterEggArcade.GameLogic:gameOver() 
	self.m_GameOver = true
	self.m_Player:setDead( true )
	if isTimer(self.m_SpawnTimer) then killTimer(self.m_SpawnTimer) end
	if isTimer(self.m_AITimer) then killTimer(self.m_AITimer) end
	if isTimer(self.m_AITimer2) then killTimer(self.m_AITimer2) end
	self.m_AIState["jump"] = false
	self.m_AIState["crouch"] = false
	self.m_AIState["punch"] = false
	self.m_AIState["left"] = false
	self.m_AIState["right"] = false
	self.m_Enemy:setWinPose()
end

function EasterEggArcade.GameLogic:gameWon()
	self.m_GameWon = true
	self.m_Enemy:setDead( true )
	if isTimer(self.m_SpawnTimer) then killTimer(self.m_SpawnTimer) end
	if isTimer(self.m_AITimer) then killTimer(self.m_AITimer) end
	if isTimer(self.m_AITimer2) then killTimer(self.m_AITimer2) end
	self.m_AIState["jump"] = false
	self.m_AIState["crouch"] = false
	self.m_AIState["punch"] = false
	self.m_AIState["left"] = false
	self.m_AIState["right"] = false	
	self.m_Player:setWinPose()
end

--[[
function GameLogic:key( key, press)
	if EASTEREGG_KEY_MOVES[key] then
		if self.m_MoveState == EASTEREGG_KEY_MOVES[key] and not press then 
			self.m_MoveState = false
			self.m_AnimationTick = 0
		else 
			if press then
				self.m_MoveState = EASTEREGG_KEY_MOVES[key]
				self.m_AnimationTick = 0
			end
		end
	end
end
--]]

function EasterEggArcade.GameLogic:changeAIMove()
	local state = math.random(1,2)
	if state == 1 then 
		self.m_AIState["jump"] = true
		self.m_AIState["crouch"] = false
		self.m_AIState["punch"] = false
	else 
		self.m_AIState["jump"] = false
		self.m_AIState["crouch"] = true
		self.m_AIState["punch"] = false
	end
	self.m_AIState["left"] = false
	self.m_AIState["right"] = false
end

function EasterEggArcade.GameLogic:changeAIDirection() 
	local state = math.random(1,2)
	if state == 1 then 
		self.m_AIState["right"] = true
		self.m_AIState["left"] = false
		self.m_AIState["punch"] = false
	else 
		self.m_AIState["right"] = false
		self.m_AIState["left"] = true
		self.m_AIState["punch"] = false
	end
end

function EasterEggArcade.GameLogic:key( key, press)
	if EASTEREGG_KEY_MOVES[key] then
		if not self.m_PressedKeys[EASTEREGG_KEY_MOVES[key]] and press then 
			self.m_AnimationTick = 0
		end
		if self.m_PressedKeys[EASTEREGG_KEY_MOVES[key]] and not press then 
			self.m_AnimationTick = 0
		end
		self.m_PressedKeys[EASTEREGG_KEY_MOVES[key]] = press
	end
	if key == "enter" and not press then 
		EasterEggArcade.Game:getSingleton():stop()
	elseif key == "r" and not press then 
		if self:isGameOver() then 
			EasterEggArcade.Game:getSingleton():restart()
		end
	end
end

function EasterEggArcade.GameLogic:isKeyPressed( state ) 
	return self.m_PressedKeys[state]
end

function EasterEggArcade.GameLogic:getAIState( state ) 
	return self.m_AIState[state]
end


function EasterEggArcade.GameLogic:getMoveState()
	return self.m_MoveState
end

function EasterEggArcade.GameLogic:getAnimationTick()
	return self.m_AnimationTick
end

function EasterEggArcade.GameLogic:getHUD()
	return self.m_HUD
end

function EasterEggArcade.GameLogic:getSound()
	return self.m_Sound
end

function EasterEggArcade.GameLogic:isGameOver()
	return self.m_GameOver
end

function EasterEggArcade.GameLogic:isGameWon() 
	return self.m_GameWon
end