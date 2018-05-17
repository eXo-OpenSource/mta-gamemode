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

EasterEggArcade.HUD = inherit(Object) 
function EasterEggArcade.HUD:constructor( )
	self.m_OriginalWindow = {}
	self.m_OriginalWindow.x = WINDOW[1].x
	self.m_OriginalWindow.y = WINDOW[1].y
	self.m_Font = dxCreateFont(FILE_PATH.."/BitBold.ttf", 14*FONT_SCALE)
	self.m_FontBig = dxCreateFont(FILE_PATH.."/BitBold.ttf", 22*FONT_SCALE)
	self.m_Render = bind(self.render, self)
	self.m_DamageQueue = { }
end

function EasterEggArcade.HUD:destructor()
end

function EasterEggArcade.HUD:setHealthPosition( pos, bound )
	local ratio = {x = WINDOW[2].x / NATIVE_RATIO.x , y = WINDOW[2].y / NATIVE_RATIO.y}
	pos = {x=pos.x - WINDOW[1].x, y=pos.y-WINDOW[1].y}
	bound = {x=bound.x*ratio.x, y= bound.y * ratio.y}
	self.m_Pos = pos 
	self.m_Bound = bound
end

function EasterEggArcade.HUD:setEnemyPosition( pos, bound )
	local ratio = {x = WINDOW[2].x / NATIVE_RATIO.x , y = WINDOW[2].y / NATIVE_RATIO.y}
	pos = {x=pos.x - WINDOW[1].x, y=pos.y-WINDOW[1].y}
	bound = {x=bound.x*ratio.x, y=bound.y * ratio.y}
	self.m_EnemyPos = pos 
	self.m_EnemyBound = bound
end

function EasterEggArcade.HUD:render()
	if self.m_Pos and self.m_Bound then
		self:drawHealthBar() 
	end
	if self.m_EnemyPos and self.m_EnemyBound then
		self:drawEnemyBar() 
	end
	self:drawKeyInfo()
	self:drawDamage()
	self:drawShake()
	if EasterEggArcade.Game:getSingleton():getGameLogic() and EasterEggArcade.Game:getSingleton():getGameLogic():isGameOver() then 
		self:drawGameOver()
	end
	if EasterEggArcade.Game:getSingleton():getGameLogic() and EasterEggArcade.Game:getSingleton():getGameLogic():isGameWon() then 
		self:drawWin()
	end
end

function EasterEggArcade.HUD:drawHealthBar()
	local healthWidth = (EasterEggArcade.Game:getSingleton():getGameLogic().m_Player:getHealth()/EasterEggArcade.Game:getSingleton():getGameLogic().m_Player:getMaxHealth()) * self.m_Bound.x*0.65
	dxDrawRectangle(self.m_Pos.x+self.m_Bound.x*0.2, self.m_Pos.y+self.m_Bound.y*0.44, healthWidth, self.m_Bound.y*0.23, tocolor(200, 0, 0, 255))
	dxDrawImage( self.m_Pos.x, self.m_Pos.y, self.m_Bound.x, self.m_Bound.y, IMAGE_PATH.."/health_empty.png")
	dxDrawText(EasterEggArcade.Game:getSingleton():getGameLogic().m_Player:getHealth(), self.m_Pos.x+self.m_Bound.x*0.2, self.m_Pos.y+self.m_Bound.y*0.45, self.m_Pos.x+self.m_Bound.x*0.2 + self.m_Bound.x*0.65, self.m_Pos.y+self.m_Bound.y*0.44 + self.m_Bound.y*0.23, tocolor(60, 0, 0, 255), 1, self.m_Font, "center", "center")
	dxDrawText(localPlayer:getName(), self.m_Pos.x+self.m_Bound.x*0.14, (self.m_Pos.y+self.m_Bound.y*0.5 + self.m_Bound.y*0.27)+2, self.m_Pos.x+self.m_Bound.x*0.2 + self.m_Bound.x*0.65, self.m_Pos.y+self.m_Bound.y*0.7, tocolor(0, 0, 0, 255), 1, self.m_Font, "left", "top")
	dxDrawText(localPlayer:getName(), self.m_Pos.x+self.m_Bound.x*0.14, self.m_Pos.y+self.m_Bound.y*0.5 + self.m_Bound.y*0.27, self.m_Pos.x+self.m_Bound.x*0.2 + self.m_Bound.x*0.65, self.m_Pos.y+self.m_Bound.y*0.7, tocolor(200, 0, 0, 255), 1, self.m_Font, "left", "top")
end

function EasterEggArcade.HUD:drawEnemyBar()
	local healthWidth = (EasterEggArcade.Game:getSingleton():getGameLogic().m_Enemy:getHealth()/EasterEggArcade.Game:getSingleton():getGameLogic().m_Enemy:getMaxHealth()) * self.m_Bound.x*0.65
	dxDrawRectangle(self.m_EnemyPos.x+self.m_EnemyBound.x*0.2, self.m_EnemyPos.y+self.m_EnemyBound.y*0.44, healthWidth, self.m_EnemyBound.y*0.25, tocolor(0, 0, 200, 255))
	dxDrawImage( self.m_EnemyPos.x, self.m_EnemyPos.y, self.m_EnemyBound.x, self.m_EnemyBound.y, IMAGE_PATH.."/health_empty_enemy.png")
	dxDrawText(EasterEggArcade.Game:getSingleton():getGameLogic().m_Enemy:getHealth(), self.m_EnemyPos.x+self.m_EnemyBound.x*0.2, self.m_EnemyPos.y+self.m_EnemyBound.y*0.45, self.m_EnemyPos.x+self.m_EnemyBound.x*0.2 + self.m_EnemyBound.x*0.65, self.m_Pos.y+self.m_EnemyBound.y*0.44 + self.m_EnemyBound.y*0.23, tocolor(11, 103, 215, 255), 1, self.m_Font, "center", "center")
	dxDrawText("Strobe", self.m_EnemyPos.x+self.m_EnemyBound.x*0.1, (self.m_EnemyPos.y+self.m_EnemyBound.y*0.5 + self.m_EnemyBound.y*0.27)+2, self.m_EnemyPos.x+self.m_EnemyBound.x*0.2 + self.m_EnemyBound.x*0.65, self.m_EnemyPos.y+self.m_EnemyBound.y*0.7, tocolor(0, 0, 0, 255), 1, self.m_Font, "right", "top")
	dxDrawText("Strobe", self.m_EnemyPos.x+self.m_EnemyBound.x*0.1, self.m_EnemyPos.y+self.m_EnemyBound.y*0.5 + self.m_EnemyBound.y*0.27, self.m_EnemyPos.x+self.m_EnemyBound.x*0.2 + self.m_EnemyBound.x*0.65, self.m_EnemyPos.y+self.m_EnemyBound.y*0.7, tocolor(51, 153, 255, 255), 1, self.m_Font, "right", "top")
end

function EasterEggArcade.HUD:drawKeyInfo()
	dxDrawImage(self.m_Pos.x+self.m_Bound.x*0.2+self.m_Bound.x*1.05, self.m_Pos.y+self.m_Bound.y*0.34, self.m_Bound.x*0.4, self.m_Bound.x*0.2, IMAGE_PATH.."/key.png" )
	dxDrawImage(self.m_Pos.x+self.m_Bound.x*0.2+self.m_Bound.x*1.05, self.m_Pos.y+self.m_Bound.y*0.34+self.m_Bound.x*0.2, self.m_Bound.x*0.4, self.m_Bound.x*0.1, IMAGE_PATH.."/space.png" )
end

function EasterEggArcade.HUD:addDamage( obj ) 
	local x,y = obj:getPosition()
	x = x - WINDOW[1].x
	y = y - WINDOW[1].y
	self.m_DamageQueue[#self.m_DamageQueue+1] = {x,y,getTickCount()}
end

function EasterEggArcade.HUD:drawOverlay()
	local w,h = guiGetScreenSize()
	dxDrawImage(WINDOW[1].x-WINDOW[2].x*0.46, WINDOW[1].y-WINDOW[2].y*0.1, WINDOW[2].x*1.9, WINDOW[2].y*1.2, IMAGE_PATH.."/overlay.png" )
end

function EasterEggArcade.HUD:drawGameOver()
	dxDrawText("GAME OVER!", 3, 3, WINDOW[2].x, WINDOW[2].y, tocolor(0, 0, 0, 255), 1, self.m_FontBig, "center", "center")
	dxDrawText("GAME OVER!", 0, 0, WINDOW[2].x, WINDOW[2].y, tocolor(200, 200, 0, 255), 1, self.m_FontBig, "center", "center")
	dxDrawText("Press R to Restart!", 0, WINDOW[2].y*0.15, WINDOW[2].x, WINDOW[2].y, tocolor(200, 200, 0, 255), 1, self.m_Font, "center", "center")
end

function EasterEggArcade.HUD:drawWin()
	dxDrawText("WON!", 3, 3, WINDOW[2].x, WINDOW[2].y, tocolor(0, 0, 0, 255), 1, self.m_FontBig, "center", "center")
	dxDrawText("WON!", 0, 0, WINDOW[2].x, WINDOW[2].y, tocolor(0, 200, 0, 255), 1, self.m_FontBig, "center", "center")
	dxDrawText("Press Enter to get your prize!", 0, WINDOW[2].y*0.15, WINDOW[2].x, WINDOW[2].y, tocolor(0, 200, 0, 255), 1, self.m_Font, "center", "center")
end


function EasterEggArcade.HUD:drawDamage() 
	local x,y, start, elap, dur, prog, alpha
	local now = getTickCount()
	for i = 1, #self.m_DamageQueue do 
		if self.m_DamageQueue[i] then
			x,y, start = self.m_DamageQueue[i][1], self.m_DamageQueue[i][2], self.m_DamageQueue[i][3]
			prog = (now - start) / 1000
			y, alpha = interpolateBetween(y, 255, 0, y-64, 0, 0, prog, "Linear")
			dxDrawText("-9", x, y+1, x, y, tocolor(0, 0, 0, alpha), 1, self.m_Font)
			dxDrawText("-9", x, y, x, y, tocolor(255, 200, 0, alpha), 1, self.m_Font)
			if prog >= 1 then 
				table.remove(self.m_DamageQueue, i)
			end
		end
	end
end

function EasterEggArcade.HUD:shake( ) 
	self.m_Shake = true 
	self.m_ShakeTick = getTickCount()
	self.m_ShakeAmount = 1.5
end

function EasterEggArcade.HUD:drawShake() 
	local x,y, start, elap, dur, prog, alpha
	local now = getTickCount()
	if self.m_Shake then
		prog = (now - self.m_ShakeTick) / 100
		shake = interpolateBetween(-self.m_ShakeAmount, 0, 0, self.m_ShakeAmount, 0, 0, prog, "InQuad")
		WINDOW[1].y = WINDOW[1].y - shake 
		if prog >= 1 then 
			self.m_Shake = false
			WINDOW[1].x = self.m_OriginalWindow.x
			WINDOW[1].y = self.m_OriginalWindow.y
		end
	end
end