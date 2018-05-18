EasterEggArcade.Neutral = inherit(EasterEggArcade.Sprite)

function EasterEggArcade.Neutral:constructor() 
	self:addAnimationSprite()
	self:setBound(64, 32)
	self.m_AnimationTick = 0
	self.m_Acceleration = {x=0;y=0}
	self.m_LastJump = 0
	self.m_LastAttack = 0
end

function EasterEggArcade.Neutral:addAnimationSprite() 
	self:addSpriteIndex( EASTEREGG_IMAGE_PATH.."/sprites/larry.png")
end


function EasterEggArcade.Neutral:destructor()

end

function EasterEggArcade.Neutral:update( tick )
	self:animation()
	self:physics()
	if self:checkAttack() then 
		if self.m_LastAttack + 200 <= getTickCount() then
			self.m_LastAttack = getTickCount()
			EasterEggArcade.Game:getSingleton():getGameLogic():onHit(EasterEggArcade.Game:getSingleton():getGameLogic().m_Player) 
		end
	end
end

function EasterEggArcade.Neutral:setState( state )
	self.m_State = state
	if state == "standing" then 
		self.m_JumpCount = 0
	end
end

function EasterEggArcade.Neutral:setHealth( health ) 
	self.m_Health = health
end

function EasterEggArcade.Neutral:setMaxHealth( health ) 
	self.m_MaxHealth = health
end

function EasterEggArcade.Neutral:getMaxHealth( ) 
	return self.m_MaxHealth
end

function EasterEggArcade.Neutral:getHealth() 
	return self.m_Health
end

function EasterEggArcade.Neutral:animation()
	self.m_AnimationTick = EasterEggArcade.Game:getSingleton():getGameLogic():getAnimationTick()
	if self.m_PlayDeath then 
		if not self.m_FreezeDeath then
		end
		return
	end
	local idle = true
	if EasterEggArcade.Game:getSingleton():getGameLogic():getAIState( "right" )  then 
		self.m_Acceleration = {x=6, y=0}
		self:move({x=6;y=0})
		idle = false
		self:setMirrored( false )
	elseif EasterEggArcade.Game:getSingleton():getGameLogic():getAIState( "left" ) then 
		self.m_Acceleration = {x=-6, y=-0}
		self:move({x=-6;y=0})
		idle = false
		self:setMirrored( true )
	end
	if EasterEggArcade.Game:getSingleton():getGameLogic():getAIState( "jump" ) then 
		if self.m_LastJump+300 < getTickCount() then
			if self.m_JumpCount and self.m_JumpCount <= EASTEREGG_JUMP_RATIO then
				self.m_JumpCount = self.m_JumpCount + 1 
				idle = false
				self.m_Acceleration = {x=0, y=-30}
				self:move({x=0;y=-30})
			else 
				self.m_LastJump = getTickCount()
			end
		end
	end
end

function EasterEggArcade.Neutral:physics()
	self:gravity()
end

function EasterEggArcade.Neutral:setCrouched(bool)
	self.m_Crouched = bool
end

function EasterEggArcade.Neutral:getCrouched( )
	return self.m_Crouched
end

function EasterEggArcade.Neutral:gravity()
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

function EasterEggArcade.Neutral:accelerate(vec)
	local x,y = self:getPosition()
	y = y + vec.y
	x = x + vec.x
	self:setPosition(x, y)
end

function EasterEggArcade.Neutral:checkAttack()
	local px, py = EasterEggArcade.Game:getSingleton():getGameLogic().m_Player:getPosition()
	local pWidth, pHeight = EasterEggArcade.Game:getSingleton():getGameLogic().m_Player:getBound()
	local x,y = self:getPosition()
	local crouchOffset = EasterEggArcade.Game:getSingleton():getGameLogic().m_Player:getCrouched() and pHeight*1/2 or 0
	local width, height = self:getBound()
	height = height*0.4
	y = y+height*0.6
	width=width*0.6
	x= x+width*0.2
	px = px+pWidth*0.3
	pWidth = pWidth*0.4
	dxDrawRectangle(x, y, width, height, tocolor(200, 200, 200, 255))
	local checkCollision = false
	if py+crouchOffset<y+height and py+pHeight > y then 
		checkCollision = true
	end
	if checkCollision then
		if x < px+pWidth and x+width > px  then 
			return true
		end
	end
end

function EasterEggArcade.Neutral:move( vec ) 
	if EasterEggArcade.Game:getSingleton():getGameLogic():checkHorizontal(self, vec) then
		self:accelerate({x=vec.x;y=vec.y})
	else 
		self:accelerate({x=vec.x*-1;y=vec.y*-1})
	end
end

function EasterEggArcade.Neutral:setDead( bool ) 
	self.m_PlayDeath = bool
end


function EasterEggArcade.Neutral:setWinPose() 
	self.m_WinPose = true
end

function EasterEggArcade.Neutral:getMoveState() 
	return EasterEggArcade.Game:getSingleton():getGameLogic():getMoveState()
end