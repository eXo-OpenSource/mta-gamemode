EasterEggArcade.Collectable = inherit(EasterEggArcade.Sprite)

function EasterEggArcade.Collectable:constructor() 
	self:addAnimationSprite()
	self:setBound(64, 64)
	self.m_AnimationTick = 0
	self.m_Acceleration = {x=0;y=0}
	self.m_LastJump = 0
	self.m_LastAttack = 0
	self.m_Hit = false
end

function EasterEggArcade.Collectable:addAnimationSprite() 
	self:addSpriteIndex( EASTEREGG_IMAGE_PATH.."/sprites/trophy.png")
end


function EasterEggArcade.Collectable:destructor()

end

function EasterEggArcade.Collectable:update( tick )
	self:physics()
	if not self.m_Hit and self:checkCollision() then 
		self.m_Hit = true
		EasterEggArcade.Game:getSingleton():getGameLogic():onCollect(self) 
	end
end

function EasterEggArcade.Collectable:setState( state )
	self.m_State = state
	if state == "standing" then 
		self.m_JumpCount = 0
	end
end

function EasterEggArcade.Collectable:setHealth( health ) 
	self.m_Health = health
end

function EasterEggArcade.Collectable:setMaxHealth( health ) 
	self.m_MaxHealth = health
end

function EasterEggArcade.Collectable:getMaxHealth( ) 
	return self.m_MaxHealth
end

function EasterEggArcade.Collectable:getHealth() 
	return self.m_Health
end

function EasterEggArcade.Collectable:physics()
	self:gravity()
end

function EasterEggArcade.Collectable:setCrouched(bool)
	self.m_Crouched = bool
end

function EasterEggArcade.Collectable:getCrouched( )
	return self.m_Crouched
end

function EasterEggArcade.Collectable:gravity()
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

function EasterEggArcade.Collectable:accelerate(vec)
	local x,y = self:getPosition()
	y = y + vec.y
	x = x + vec.x
	self:setPosition(x, y)
end

function EasterEggArcade.Collectable:checkCollision()
	local x,y = self:getPosition()
	local width, height = self:getBound()
	local px, py = EasterEggArcade.Game:getSingleton():getGameLogic().m_Player:getPosition()
	local pWidth, pHeight = EasterEggArcade.Game:getSingleton():getGameLogic().m_Player:getBound()
	local checkCollision = false
	if py<y+height and py+pHeight > y then 
		checkCollision = true
	end
	if checkCollision then
		if x < px+pWidth and x+width > px  then 
			return true
		end
	end
end

function EasterEggArcade.Collectable:move( vec ) 
	if EasterEggArcade.Game:getSingleton():getGameLogic():checkHorizontal(self, vec) then
		self:accelerate({x=vec.x;y=vec.y})
	else 
		self:accelerate({x=vec.x*-1;y=vec.y*-1})
	end
end

function EasterEggArcade.Collectable:setDead( bool ) 
	self.m_PlayDeath = bool
end


function EasterEggArcade.Collectable:setWinPose() 
	self.m_WinPose = true
end

function EasterEggArcade.Collectable:getMoveState() 
	return EasterEggArcade.Game:getSingleton():getGameLogic():getMoveState()
end