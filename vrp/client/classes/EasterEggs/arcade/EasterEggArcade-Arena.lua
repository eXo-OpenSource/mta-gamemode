EasterEggArcade.Arena = inherit(Object) 

function EasterEggArcade.Arena:constructor(gameLogic, render, start, bound)
	self.m_Start = start
	self.m_Size = bound
	self.m_GameLogic = gameLogic 
	self.m_Render = render
	self:setupBackground( start, bound)
	self:setupFloor( start, bound)
end

function EasterEggArcade.Arena:setupBackground(start, bound) 
	self.m_Background = EasterEggArcade.Sprite:new(true)
	self.m_Background:setPosition( start.x, start.y)
	self.m_Background:setBound( bound.x, bound.y)
	self.m_Background:addSpriteIndex( EASTEREGG_IMAGE_PATH.."/arena.jpg")
	self.m_Background:setSprite( 1 )
	self.m_Background:setStatic( true )
	self.m_GameLogic:addToUpdateQueue( self.m_Background )
	self.m_Render:addToQueue( self.m_Background )
	local x, y  = self.m_Background:getPosition()
	local width, height = self.m_Background:getBound()
	self.m_ArenaCollision = {{x,y}, {width, height}}
end

function EasterEggArcade.Arena:setupFloor( start, bound)
	self.m_Floor = EasterEggArcade.Sprite:new(true)
	self.m_Floor:setBound( bound.x, bound.y*0.2)
	local boundX, boundY = self.m_Background:getBound()
	self.m_Floor:setPosition( start.x, start.y+boundY*0.9)
	self.m_Floor:addSpriteIndex( EASTEREGG_IMAGE_PATH.."/ground.jpg")
	self.m_Floor:setSprite( 1 )
	self.m_Floor:setTiled( true )
	self.m_Floor:setStatic( true )
	self.m_GameLogic:addToUpdateQueue( self.m_Floor )
	self.m_Render:addToQueue( self.m_Floor )
	local x, y  = self.m_Floor:getPosition()
	local width, height = self.m_Floor:getBound()
	self.m_FloorCollision = {{x,y}, {width, height}}
end

function EasterEggArcade.Arena:getFloor() 
	return self.m_FloorCollision[1][1], self.m_FloorCollision[1][2], self.m_FloorCollision[2][1], self.m_FloorCollision[2][2]
end

function EasterEggArcade.Arena:getArena() 
	return self.m_ArenaCollision[1][1], self.m_ArenaCollision[1][2], self.m_ArenaCollision[2][1], self.m_ArenaCollision[2][2]
end

function EasterEggArcade.Arena:destructor()
	self.m_Background:delete()
	self.m_Floor:delete()
end
