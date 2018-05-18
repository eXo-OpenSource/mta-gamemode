EasterEggArcade.Dancer = inherit(EasterEggArcade.Sprite)

function EasterEggArcade.Dancer:constructor() 
	self:addAnimationSprite()
	self:setBound(64, 32)
	self.m_AnimationTick = 0
	self.m_Acceleration = {x=0;y=0}
	self.m_LastJump = 0
	self.m_LastAttack = 0
end

function EasterEggArcade.Dancer:addAnimationSprite() 
	self:addSpriteIndex( EASTEREGG_IMAGE_PATH.."/sprites/larry.png")
end


function EasterEggArcade.Dancer:destructor()

end

function EasterEggArcade.Dancer:update( tick )
	self:physics()
end

function EasterEggArcade.Dancer:setState( state )
	self.m_State = state
	if state == "standing" then 
		self.m_JumpCount = 0
	end
end

function EasterEggArcade.Dancer:setHealth( health ) 
	self.m_Health = health
end

function EasterEggArcade.Dancer:setMaxHealth( health ) 
	self.m_MaxHealth = health
end

function EasterEggArcade.Dancer:getMaxHealth( ) 
	return self.m_MaxHealth
end

function EasterEggArcade.Dancer:getHealth() 
	return self.m_Health
end

function EasterEggArcade.Dancer:physics()
	self:gravity()
end

function EasterEggArcade.Dancer:setCrouched(bool)
	self.m_Crouched = bool
end

function EasterEggArcade.Dancer:getCrouched( )
	return self.m_Crouched
end

function EasterEggArcade.Dancer:gravity()
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

function EasterEggArcade.Dancer:accelerate(vec)
	local x,y = self:getPosition()
	y = y + vec.y
	x = x + vec.x
	self:setPosition(x, y)
end

function EasterEggArcade.Dancer:checkAttack()
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

function EasterEggArcade.Dancer:move( vec ) 
	if EasterEggArcade.Game:getSingleton():getGameLogic():checkHorizontal(self, vec) then
		self:accelerate({x=vec.x;y=vec.y})
	else 
		self:accelerate({x=vec.x*-1;y=vec.y*-1})
	end
end

function EasterEggArcade.Dancer:setDead( bool ) 
	self.m_PlayDeath = bool
end


function EasterEggArcade.Dancer:setWinPose() 
	self.m_WinPose = true
end

function EasterEggArcade.Dancer:getMoveState() 
	return EasterEggArcade.Game:getSingleton():getGameLogic():getMoveState()
end