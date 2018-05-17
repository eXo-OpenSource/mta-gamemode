EasterEggArcade.Projectile = inherit(EasterEggArcade.Sprite)

function EasterEggArcade.Projectile:constructor() 
	self:addAnimationSprite()
	self:setBound(64, 32)
	self.m_AnimationTick = 0
	self.m_PlayerProjectile = false
	self.m_Acceleration = {x=0;y=0}
	self.m_Hit = false
end

function EasterEggArcade.Projectile:setDirection(dir)
	self.m_Acceleration = {x=dir.x; y=dir.y}
	EasterEggArcade.Game:getSingleton():getGameLogic():getSound():playFire()
end

function EasterEggArcade.Projectile:addAnimationSprite() 
	for i = 1, 3 do 
		self:addSpriteIndex( EASTEREGG_IMAGE_PATH.."/sprites/flame"..i..".png")
	end
end


function EasterEggArcade.Projectile:destructor()
	for i = 1, #self.m_Sprites do 
		if self.m_Sprites[i] and isElement(self.m_Sprites[i]) and getElementType(self.m_Sprites[i]) == "texture" then 
			destroyElement(self.m_Sprites[i])
		end
	end
end

function EasterEggArcade.Projectile:update( tick )
	self.m_AnimationTick = EasterEggArcade.Game:getSingleton():getGameLogic():getAnimationTick()
	self:animation(self.m_AnimationTick)
	self:move()
	local hit = false
	if not self.m_PlayerProjectile then
		hit = self:checkPlayer()
	else 
		hit = self:checkEnemy()
	end
	if hit then 
		if not self.m_Hit then 
			self.m_Hit = true
			if not self.m_PlayerProjectile then			
				EasterEggArcade.Game:getSingleton():getGameLogic():onHit(EasterEggArcade.Game:getSingleton():getGameLogic().m_Player) 
			else 
				EasterEggArcade.Game:getSingleton():getGameLogic():onHit(EasterEggArcade.Game:getSingleton():getGameLogic().m_Enemy) 
			end
			EasterEggArcade.Game:getSingleton():getGameLogic():removeObject( self )
			delete(self)
		end
	end
end


function EasterEggArcade.Projectile:accelerate(vec)
	local x,y = self:getPosition()
	y = y + vec.y
	x = x + vec.x
	self:setPosition(x, y)
end

function EasterEggArcade.Projectile:checkWall()
	local fX, fY, fWidth, fHeight = EasterEggArcade.Game:getSingleton():getGameLogic().m_Arena:getFloor()
	local x, y = self:getPosition() 
	local width, height = self:getBound()
	if fX > x+self.m_Acceleration.x then 
		return false
	end	
	if (fX+fWidth) < x+self.m_Acceleration.x+width then 
		return false
	end
	if fY < y+height+self.m_Acceleration.y then 
		return false
	end
	return true
end

function EasterEggArcade.Projectile:checkPlayer() 
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
	if DEBUG then
		dxDrawRectangle(x, y, width, height, tocolor(200, 200, 0, 100),true)
		dxDrawRectangle(px, py, pWidth, pHeight, tocolor(0, 200, 0, 100),true)
	end
	local checkCollision = false
	if py+crouchOffset<y+height and py+pHeight > y then 
		checkCollision = true
	end
	if checkCollision then
		if x < px+pWidth and x+width > px  then 
			return true
		end
	end
	return false
end

function EasterEggArcade.Projectile:checkEnemy() 
	local px, py = EasterEggArcade.Game:getSingleton():getGameLogic().m_Enemy:getPosition()
	local pWidth, pHeight = EasterEggArcade.Game:getSingleton():getGameLogic().m_Enemy:getBound()
	local x,y = self:getPosition()
	local crouchOffset = EasterEggArcade.Game:getSingleton():getGameLogic().m_Enemy:getCrouched() and pHeight*1/2 or 0
	local width, height = self:getBound()
	height = height*0.4
	y = y+height*0.6
	width=width*0.6
	x= x+width*0.2
	px = px+pWidth*0.3
	pWidth = pWidth*0.4
	if DEBUG then
		dxDrawRectangle(x, y, width, height, tocolor(0, 200, 0, 100),true)
		dxDrawRectangle(px, py, pWidth, pHeight, tocolor(200, 0, 0, 100),true)
	end
	local checkCollision = false
	if py+crouchOffset<y+height and py+pHeight > y then 
		checkCollision = true
	end
	if checkCollision then
		if x < px+pWidth and x+width > px  then 
			return true
		end
	end
	return false
end


function EasterEggArcade.Projectile:move( ) 
	if self:checkWall() then 
		self:accelerate(self.m_Acceleration)
	else 
		EasterEggArcade.Game:getSingleton():getGameLogic():removeObject( self )
		delete(self)
	end
end

function EasterEggArcade.Projectile:animation(tick) 
	if tick  <  EASTEREGG_TICK_CAP*(1/3) then 
		self:setSprite(1)
	elseif tick >= EASTEREGG_TICK_CAP*(1/3) and tick < EASTEREGG_TICK_CAP*(2/3) then 
		self:setSprite(2)
	elseif tick >= EASTEREGG_TICK_CAP*(1/2) and tick < EASTEREGG_TICK_CAP then
		self:setSprite(3)
	end
end

function EasterEggArcade.Projectile:accelerate(vec)
	local x,y = self:getPosition()
	y = y + vec.y
	x = x + vec.x
	self:setPosition(x, y)
end

function EasterEggArcade.Projectile:setPlayerProjectile( bool ) 
	self.m_PlayerProjectile = bool
end
