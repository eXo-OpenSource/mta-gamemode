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

EasterEggArcade.Enemy = inherit(EasterEggArcade.Sprite)

function EasterEggArcade.Enemy:constructor() 
	self:addAnimationSprite()
	self:setBound(128, 64)
	self.m_AnimationTick = 0
	self.m_Acceleration = {x=0;y=0}
	self.m_LastJump = 0
end

function EasterEggArcade.Enemy:addAnimationSprite() 
	for i = 1, 15 do 
		self:addSpriteIndex( IMAGE_PATH.."/sprites/sprite"..i..".png")
	end
end


function EasterEggArcade.Enemy:destructor()

end

function EasterEggArcade.Enemy:update( tick )
	self:animation()
	self:physics()
end

function EasterEggArcade.Enemy:setState( state )
	self.m_State = state
	if state == "standing" then 
		self.m_JumpCount = 0
	end
end

function EasterEggArcade.Enemy:setHealth( health ) 
	self.m_Health = health
end

function EasterEggArcade.Enemy:setMaxHealth( health ) 
	self.m_MaxHealth = health
end

function EasterEggArcade.Enemy:getMaxHealth( ) 
	return self.m_MaxHealth
end

function EasterEggArcade.Enemy:getHealth() 
	return self.m_Health
end

function EasterEggArcade.Enemy:animation()
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
	if EasterEggArcade.Game:getSingleton():getGameLogic():getAIState( "right" )  then 
		self.m_Acceleration = {x=3, y=0}
		self:move({x=3;y=0})
		idle = false
		self:setMirrored( false )
		self:playRunAnimation( self.m_AnimationTick )
		return
	elseif EasterEggArcade.Game:getSingleton():getGameLogic():getAIState( "left" ) then 
		self.m_Acceleration = {x=-3, y=-0}
		self:move({x=-3;y=0})
		idle = false
		self:setMirrored( true )
		self:playRunAnimation( self.m_AnimationTick )
		return
	end
	if EasterEggArcade.Game:getSingleton():getGameLogic():getAIState( "jump" ) then 
		if self.m_LastJump+300 < getTickCount() then
			if self.m_JumpCount and self.m_JumpCount <= JUMP_RATIO then
				self.m_JumpCount = self.m_JumpCount + 1 
				idle = false
				self:setJumpAnimation()
				self.m_Acceleration = {x=0, y=-20}
				self:move({x=0;y=-20})
			else 
				self.m_LastJump = getTickCount()
			end
		end
	end
	if EasterEggArcade.Game:getSingleton():getGameLogic():getAIState( "punch" )  then
		self:playPunchAnimation( self.m_AnimationTick ) 
		idle = false
		self:setCrouched(false)
	elseif EasterEggArcade.Game:getSingleton():getGameLogic():getAIState( "crouch" ) then 
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

function EasterEggArcade.Enemy:physics()
	self:gravity()
end

function EasterEggArcade.Enemy:setCrouched(bool)
	self.m_Crouched = bool
end

function EasterEggArcade.Enemy:getCrouched( )
	return self.m_Crouched
end

function EasterEggArcade.Enemy:gravity()
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

function EasterEggArcade.Enemy:accelerate(vec)
	local x,y = self:getPosition()
	y = y + vec.y
	x = x + vec.x
	self:setPosition(x, y)
end

function EasterEggArcade.Enemy:move( vec ) 
	if EasterEggArcade.Game:getSingleton():getGameLogic():checkHorizontal(self, vec) then
		self:accelerate({x=vec.x;y=vec.y})
	else 
		self:accelerate({x=vec.x*-1;y=vec.y*-1})
	end
end

function EasterEggArcade.Enemy:playRunAnimation( tick ) 
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

function EasterEggArcade.Enemy:playDeath(tick) 
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


function EasterEggArcade.Enemy:setJumpAnimation( tick ) 
	self:setSprite(5)
end

function EasterEggArcade.Enemy:setCrouchAnimation( tick ) 
	self:setSprite(2)
end

function EasterEggArcade.Enemy:setIdleAnimation( tick ) 
	self:setSprite(1)
end

function EasterEggArcade.Enemy:setDead( bool ) 
	self.m_PlayDeath = bool
end

function EasterEggArcade.Enemy:setStrafeAnim()
	self:setSprite(6)
end

function EasterEggArcade.Enemy:setWinPose() 
	self.m_WinPose = true
end

function EasterEggArcade.Enemy:playPunchAnimation( tick ) 
	if tick < TICK_CAP*(1/2) then 
		self:setSprite(3)
	else 
		self:setSprite(4)
	end
end

function EasterEggArcade.Enemy:getMoveState() 
	return EasterEggArcade.Game:getSingleton():getGameLogic():getMoveState()
end