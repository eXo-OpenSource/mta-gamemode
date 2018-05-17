local IMAGE_PATH = EASTEREGG_IMAGE_PATH
local FILE_PATH = EASTEREGG_FILE_PATH
local SFX_PATH = EASTEREGG_SFX_PATH
local TICK_CAP = EASTEREGG_TICK_CAP
local NATIVE_RATIO = EASTEREGG_NATIVE_RATIO
local WINDOW_WIDTH, EASTEREGG_WINDOW_HEIGHT = EASTEREGG_WINDOW_WIDTH, EASTEREGG_WINDOW_HEIGHT
local FONT_SCALE = EASTEREGG_FONT_SCALE
local JUMP_RATIO = EASTEREGG_JUMP_RATIO
local PROJECTILE_SPEED = EASTEREGG_PROJECTILE_SPEED
local FONT_SCALE = EASTEREGG_FONT_SCALE
local WINDOW = EASTEREGG_WINDOW
local JUMP_RATIO = EASTEREGG_JUMP_RATIO
local PROJECTILE_SPEED = EASTEREGG_PROJECTILE_SPEED
local RESOLUTION_RATIO = EASTEREGG_RESOLUTION_RATIO
local KEY_MOVES = EASTEREGG_KEY_MOVES

EasterEggArcade.Player = inherit(EasterEggArcade.Sprite)

function EasterEggArcade.Player:constructor() 
	self:addAnimationSprite()
	self:setBound(128, 64)
	self.m_AnimationTick = 0
	self.m_Acceleration = {x=0;y=0}
	self.m_LastJump = 0
	self.m_LastPunch = 0
end

function EasterEggArcade.Player:addAnimationSprite() 
	for i = 1, 15 do 
		self:addSpriteIndex( IMAGE_PATH.."/sprites/sprite"..i..".png")
	end
end


function EasterEggArcade.Player:destructor()

end

function EasterEggArcade.Player:update( tick )
	self:animation()
	self:physics()
end

function EasterEggArcade.Player:setState( state )
	self.m_State = state
	if state == "standing" then 
		self.m_JumpCount = 0
	end
end


function EasterEggArcade.Player:setHealth( health ) 
	self.m_Health = health
end

function EasterEggArcade.Player:setMaxHealth( health ) 
	self.m_MaxHealth = health
end

function EasterEggArcade.Player:getMaxHealth( ) 
	return self.m_MaxHealth
end

function EasterEggArcade.Player:getHealth() 
	return self.m_Health
end

function EasterEggArcade.Player:fire()
	local fX, fY  = self:getPosition()
	local width, height = self:getBound()
	local proj = EasterEggArcade.Projectile:new(false)
	proj:setPosition(fX, fY+height*0.2)
	proj:setPlayerProjectile(true)
	proj:setColor(tocolor(0, 150, 150, 255))
	self.m_LastPunch = getTickCount()
	EasterEggArcade.Game:getSingleton():getGameLogic():addToUpdateQueue( proj)
	EasterEggArcade.Game:getSingleton():getGameLogic().m_Render:addToQueue( proj)
	if self:getMirrored() then 
		proj:setDirection({x=-7*PROJECTILE_SPEED;y=0})
		proj:setMirrored(true)
	else 
		proj:setDirection({x=7*PROJECTILE_SPEED;y=0})
		proj:setMirrored(false)
	end
end

function EasterEggArcade.Player:animation()
	if self.m_WinPose then 
		return self:setSprite(15) 
	end
	self.m_AnimationTick = EasterEggArcade.Game:getSingleton():getGameLogic():getAnimationTick()
	if self.m_PlayDeath then 
		if not self.m_FreezeDeath then
			self:playDeath(self.m_AnimationTick)
		end
		return
	end
	local idle = true
	if EasterEggArcade.Game:getSingleton():getGameLogic():isKeyPressed( "right") and not EasterEggArcade.Game:getSingleton():getGameLogic():isKeyPressed( "jump" )  then 
		self.m_Acceleration = {x=3, y=0}
		self:move({x=3;y=0})
		idle = false
		self:setMirrored( false )
		self:playRunAnimation( self.m_AnimationTick )
		return
	elseif EasterEggArcade.Game:getSingleton():getGameLogic():isKeyPressed( "left")  and not EasterEggArcade.Game:getSingleton():getGameLogic():isKeyPressed( "jump" )  then 
		self.m_Acceleration = {x=-3, y=-0}
		self:move({x=-3;y=0})
		idle = false
		self:setMirrored( true )
		self:playRunAnimation( self.m_AnimationTick )
		return
	elseif EasterEggArcade.Game:getSingleton():getGameLogic():isKeyPressed( "jump" ) then 
		if self.m_LastJump+300 < getTickCount() then
			if self.m_JumpCount and self.m_JumpCount <= JUMP_RATIO then
				self.m_JumpCount = self.m_JumpCount + 1 
				idle = false
				if EasterEggArcade.Game:getSingleton():getGameLogic():isKeyPressed( "left") then
					self.m_Acceleration = {x=-3, y=-20}
					self:move({x=-3;y=-20})
					idle = false
					self:setMirrored( true )
					if EasterEggArcade.Game:getSingleton():getGameLogic():checkVertical(self, {x=self.m_Acceleration.x;y=10}) then
						self:setStrafeAnim()
					end
				elseif EasterEggArcade.Game:getSingleton():getGameLogic():isKeyPressed("right") then
					self.m_Acceleration = {x=3, y=-20}
					self:move({x=3;y=-20})
					idle = false
					self:setMirrored( false )
					if EasterEggArcade.Game:getSingleton():getGameLogic():checkVertical(self, {x=self.m_Acceleration.x;y=10}) then
						self:setStrafeAnim()
					end
				elseif not EasterEggArcade.Game:getSingleton():getGameLogic():isKeyPressed("right")  and not EasterEggArcade.Game:getSingleton():getGameLogic():isKeyPressed("left") then
					self:setJumpAnimation()
					self.m_Acceleration = {x=0, y=-20}
					self:move({x=0;y=-20})
				end
			else 
				self.m_LastJump = getTickCount()
			end
		end
		return
	end
	if EasterEggArcade.Game:getSingleton():getGameLogic():isKeyPressed( "punch")  then
		self:playPunchAnimation( self.m_AnimationTick ) 
		idle = false
		self:setCrouched(false)
		if self.m_LastPunch + 1000 < getTickCount() then
			self.m_LastPunch = getTickCount()
			self:fire()
		end
	elseif EasterEggArcade.Game:getSingleton():getGameLogic():isKeyPressed( "crouch") then 
		self:setCrouchAnimation( )
		self:setCrouched(true)
		idle = false
	else 
		if idle then
			self:setIdleAnimation()
			self:setCrouched(false)
		end
	end
end

function EasterEggArcade.Player:physics()
	self:gravity()
end

function EasterEggArcade.Player:setCrouched(bool)
	self.m_Crouched = bool
end

function EasterEggArcade.Player:getCrouched( )
	return self.m_Crouched
end

function EasterEggArcade.Player:gravity()
	if EasterEggArcade.Game:getSingleton():getGameLogic():checkVertical(self, {x=self.m_Acceleration.x;y=10}) then
		if EasterEggArcade.Game:getSingleton():getGameLogic():checkHorizontal(self, {x=self.m_Acceleration.x;y=10}) then
			self:accelerate({x=self.m_Acceleration.x;y=10})
		else 
			self:accelerate({x=self.m_Acceleration.x*-1;y=10})
		end
	else 
		local fX,fY =  EasterEggArcade.Game:getSingleton():getGameLogic().m_Arena:getFloor()
		local x,y = self:getPosition()
		local width, height = self:getBound()
		self:setPosition(x, fY-height)
	end
end

function EasterEggArcade.Player:accelerate(vec)
	local x,y = self:getPosition()
	y = y + vec.y
	x = x + vec.x
	self:setPosition(x, y)
end

function EasterEggArcade.Player:setWinAnim() 
	self.m_WinPose = true
end
function EasterEggArcade.Player:move( vec ) 
	if EasterEggArcade.Game:getSingleton():getGameLogic():checkHorizontal(self, vec) then
		self:accelerate({x=vec.x;y=vec.y})
	else 
		self:accelerate({x=vec.x*-1;y=vec.y*-1})
	end
end

function EasterEggArcade.Player:playRunAnimation( tick ) 
	if tick  <  TICK_CAP*(1/4) then 
		self:setSprite(6)
	elseif tick >= TICK_CAP*(1/4) and tick < TICK_CAP*(2/4) then 
		self:setSprite(7)
	elseif tick >= TICK_CAP*(2/4) and tick < TICK_CAP*(3/4) then
		self:setSprite(8)
	else 
		self:setSprite(9)
	end
end

function EasterEggArcade.Player:playDeath(tick) 
	if tick  <  TICK_CAP*(1/4) then 
		self:setSprite(13)
		self.m_Acceleration = {x=0, y=-20}
		self:move({x=0;y=-20})
	elseif tick >= TICK_CAP*(1/4) and tick < TICK_CAP*(2/4) then 
		self:setSprite(13)
		self.m_Acceleration = {x=0, y=-20}
		self:move({x=0;y=-20})
	elseif tick >= TICK_CAP*(2/4) and tick < TICK_CAP*(3/4) then
		self:setSprite(13)
	else 
		self:setSprite(14)
		self.m_FreezeDeath = true
	end
end

function EasterEggArcade.Player:setJumpAnimation( tick ) 
	self:setSprite(5)
end

function EasterEggArcade.Player:setCrouchAnimation( tick ) 
	self:setSprite(2)
end

function EasterEggArcade.Player:setIdleAnimation( tick ) 
	self:setSprite(1)
end

function EasterEggArcade.Player:setStrafeAnim()
	self:setSprite(6)
end

function EasterEggArcade.Player:setWinPose() 
	self.m_WinPose = true
end

function EasterEggArcade.Player:setDead( bool ) 
	self.m_PlayDeath = bool
end

function EasterEggArcade.Player:playPunchAnimation( tick ) 
	if tick < TICK_CAP*(1/2) then 
		self:setSprite(3)
	else 
		self:setSprite(4)
	end
end

function EasterEggArcade.Player:getMoveState() 
	return EasterEggArcade.Game:getSingleton():getGameLogic():getMoveState()
end