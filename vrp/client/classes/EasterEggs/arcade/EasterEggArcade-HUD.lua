EasterEggArcade.HUD = inherit(Object)

function EasterEggArcade.HUD:constructor(level, enemyName, isOutro )
	self.m_OriginalEASTEREGG_WINDOW = {}
	self.m_OriginalEASTEREGG_WINDOW.x = EASTEREGG_WINDOW[1].x
	self.m_OriginalEASTEREGG_WINDOW.y = EASTEREGG_WINDOW[1].y
	self.m_Level = level
	self.m_Enemy = enemyName
	self.m_OutroLevel = isOutro
	self.m_LevelDisplay = getTickCount()
	self.m_Font = VRPFont(22*EASTEREGG_FONT_SCALE, Fonts.BitBold) -- dxCreateFont(EASTEREGG_FILE_PATH.."/BitBold.ttf", 14*EASTEREGG_FONT_SCALE)
	self.m_FontBig = VRPFont(35*EASTEREGG_FONT_SCALE, Fonts.BitBold) --dxCreateFont(EASTEREGG_FILE_PATH.."/BitBold.ttf", 22*EASTEREGG_FONT_SCALE)
	self.m_FontHeight = dxGetFontHeight(1, getVRPFont(self.m_Font))
	self.m_FontBigHeight = dxGetFontHeight(1, getVRPFont(self.m_FontBig))
	self.m_Render = bind(self.render, self)
	self.m_DamageQueue = { }
	self.m_ColorTick = getTickCount()
end

function EasterEggArcade.HUD:destructor()
end

function EasterEggArcade.HUD:setHealthPosition( pos, bound )
	local ratio = {x = EASTEREGG_WINDOW[2].x / EASTEREGG_NATIVE_RATIO.x , y = EASTEREGG_WINDOW[2].y / EASTEREGG_NATIVE_RATIO.y}
	pos = {x=pos.x - EASTEREGG_WINDOW[1].x, y=pos.y-EASTEREGG_WINDOW[1].y}
	bound = {x=bound.x*ratio.x, y= bound.y * ratio.y}
	self.m_Pos = pos
	self.m_Bound = bound
end

function EasterEggArcade.HUD:setEnemyPosition( pos, bound )
	local ratio = {x = EASTEREGG_WINDOW[2].x / EASTEREGG_NATIVE_RATIO.x , y = EASTEREGG_WINDOW[2].y / EASTEREGG_NATIVE_RATIO.y}
	pos = {x=pos.x - EASTEREGG_WINDOW[1].x, y=pos.y-EASTEREGG_WINDOW[1].y}
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
	if self.m_Pos then
		self:drawKeyInfo()
	end
	self:drawDamage()
	self:drawShake()
	if EasterEggArcade.Game:getSingleton():getGameLogic() and EasterEggArcade.Game:getSingleton():getGameLogic():isGameOver() then
		self:drawGameOver()
	end
	if EasterEggArcade.Game:getSingleton():getGameLogic() and EasterEggArcade.Game:getSingleton():getGameLogic():isGameWon() then
		self:drawWin()
	end
	self:drawLevelInfo()
	self:drawColorChange()
	if self.m_Outro then
		self:drawOutro()
	end
end

function EasterEggArcade.HUD:drawHealthBar()
	local healthWidth = (EasterEggArcade.Game:getSingleton():getGameLogic().m_Player:getHealth()/EasterEggArcade.Game:getSingleton():getGameLogic().m_Player:getMaxHealth()) * self.m_Bound.x*0.65
	dxDrawRectangle(self.m_Pos.x+self.m_Bound.x*0.2, self.m_Pos.y+self.m_Bound.y*0.44, healthWidth, self.m_Bound.y*0.23, tocolor(200, 0, 0, 255))
	dxDrawImage( self.m_Pos.x, self.m_Pos.y, self.m_Bound.x, self.m_Bound.y, EASTEREGG_IMAGE_PATH.."/health_empty.png")
	dxDrawText(EasterEggArcade.Game:getSingleton():getGameLogic().m_Player:getHealth(), self.m_Pos.x+self.m_Bound.x*0.2, self.m_Pos.y+self.m_Bound.y*0.45, self.m_Pos.x+self.m_Bound.x*0.2 + self.m_Bound.x*0.65, self.m_Pos.y+self.m_Bound.y*0.44 + self.m_Bound.y*0.23, tocolor(60, 0, 0, 255), 1, getVRPFont(self.m_Font), "center", "center")
	dxDrawText(localPlayer:getName(), self.m_Pos.x+self.m_Bound.x*0.14, (self.m_Pos.y+self.m_Bound.y*0.5 + self.m_Bound.y*0.27)+2, self.m_Pos.x+self.m_Bound.x*0.2 + self.m_Bound.x*0.65, self.m_Pos.y+self.m_Bound.y*0.7, tocolor(0, 0, 0, 255), 1, getVRPFont(self.m_Font), "left", "top")
	dxDrawText(localPlayer:getName(), self.m_Pos.x+self.m_Bound.x*0.14, self.m_Pos.y+self.m_Bound.y*0.5 + self.m_Bound.y*0.27, self.m_Pos.x+self.m_Bound.x*0.2 + self.m_Bound.x*0.65, self.m_Pos.y+self.m_Bound.y*0.7, tocolor(200, 0, 0, 255), 1, getVRPFont(self.m_Font), "left", "top")
end

function EasterEggArcade.HUD:drawEnemyBar()
	local healthWidth = (EasterEggArcade.Game:getSingleton():getGameLogic().m_Enemy:getHealth()/EasterEggArcade.Game:getSingleton():getGameLogic().m_Enemy:getMaxHealth()) * self.m_Bound.x*0.65
	dxDrawRectangle(self.m_EnemyPos.x+self.m_EnemyBound.x*0.2, self.m_EnemyPos.y+self.m_EnemyBound.y*0.44, healthWidth, self.m_EnemyBound.y*0.25, tocolor(0, 0, 200, 255))
	dxDrawImage( self.m_EnemyPos.x, self.m_EnemyPos.y, self.m_EnemyBound.x, self.m_EnemyBound.y, EASTEREGG_IMAGE_PATH.."/health_empty_enemy.png")
	dxDrawText(EasterEggArcade.Game:getSingleton():getGameLogic().m_Enemy:getHealth(), self.m_EnemyPos.x+self.m_EnemyBound.x*0.2, self.m_EnemyPos.y+self.m_EnemyBound.y*0.45, self.m_EnemyPos.x+self.m_EnemyBound.x*0.2 + self.m_EnemyBound.x*0.65, self.m_Pos.y+self.m_EnemyBound.y*0.44 + self.m_EnemyBound.y*0.23, tocolor(11, 103, 215, 255), 1, getVRPFont(self.m_Font), "center", "center")
	dxDrawText(self.m_Enemy, self.m_EnemyPos.x+self.m_EnemyBound.x*0.1, (self.m_EnemyPos.y+self.m_EnemyBound.y*0.5 + self.m_EnemyBound.y*0.27)+2, self.m_EnemyPos.x+self.m_EnemyBound.x*0.2 + self.m_EnemyBound.x*0.65, self.m_EnemyPos.y+self.m_EnemyBound.y*0.7, tocolor(0, 0, 0, 255), 1, getVRPFont(self.m_Font), "right", "top")
	dxDrawText(self.m_Enemy, self.m_EnemyPos.x+self.m_EnemyBound.x*0.1, self.m_EnemyPos.y+self.m_EnemyBound.y*0.5 + self.m_EnemyBound.y*0.27, self.m_EnemyPos.x+self.m_EnemyBound.x*0.2 + self.m_EnemyBound.x*0.65, self.m_EnemyPos.y+self.m_EnemyBound.y*0.7, tocolor(51, 153, 255, 255), 1, getVRPFont(self.m_Font), "right", "top")
end

function EasterEggArcade.HUD:drawKeyInfo()
	dxDrawImage(self.m_Pos.x+self.m_Bound.x*0.2+self.m_Bound.x*1.05, self.m_Pos.y+self.m_Bound.y*0.14, self.m_Bound.x*0.4, self.m_Bound.x*0.2, EASTEREGG_IMAGE_PATH.."/key.png" )
	dxDrawImage(self.m_Pos.x+self.m_Bound.x*0.2+self.m_Bound.x*1.05, self.m_Pos.y+self.m_Bound.y*0.14+self.m_Bound.x*0.2, self.m_Bound.x*0.4, self.m_Bound.x*0.1, EASTEREGG_IMAGE_PATH.."/space.png" )
end

function EasterEggArcade.HUD:drawColorChange()
	local now = getTickCount()
	prog = (now - self.m_ColorTick) / 1000
	r,g,b = interpolateBetween(255, 255, 255, 50, 255, 255, prog, "SineCurve")
	if EasterEggArcade.Game:getSingleton() then
		EasterEggArcade.Game:getSingleton():getGameLogic().m_Arena.m_Floor:setColor(tocolor(255,r,r,255))
	end
end

function EasterEggArcade.HUD:addDamage( obj )
	local x,y = obj:getPosition()
	x = x - EASTEREGG_WINDOW[1].x
	y = y - EASTEREGG_WINDOW[1].y
	self.m_DamageQueue[#self.m_DamageQueue+1] = {x,y,getTickCount()}
end

function EasterEggArcade.HUD:drawOverlay()
	dxDrawImage(EASTEREGG_WINDOW[1].x-EASTEREGG_WINDOW[2].x*0.46, EASTEREGG_WINDOW[1].y-EASTEREGG_WINDOW[2].y*0.1, EASTEREGG_WINDOW[2].x*1.9, EASTEREGG_WINDOW[2].y*1.2, EASTEREGG_IMAGE_PATH.."/overlay.png" )
end

function EasterEggArcade.HUD:drawGameOver()
	dxDrawText("GAME OVER!", 3, 3, EASTEREGG_WINDOW[2].x, EASTEREGG_WINDOW[2].y, tocolor(0, 0, 0, 255), 1, getVRPFont(self.m_FontBig), "center", "center")
	dxDrawText("GAME OVER!", 0, 0, EASTEREGG_WINDOW[2].x, EASTEREGG_WINDOW[2].y, tocolor(200, 200, 0, 255), 1, getVRPFont(self.m_FontBig), "center", "center")
	dxDrawText("Press R to Restart!", 0, self.m_FontBigHeight*3 , EASTEREGG_WINDOW[2].x, EASTEREGG_WINDOW[2].y, tocolor(200, 200, 0, 255), 1, getVRPFont(self.m_Font), "center", "center")
end

function EasterEggArcade.HUD:drawWin()
	dxDrawText("WON!", 3, 3, EASTEREGG_WINDOW[2].x, EASTEREGG_WINDOW[2].y, tocolor(0, 0, 0, 255), 1, getVRPFont(self.m_FontBig), "center", "center")
	dxDrawText("WON!", 0, 0, EASTEREGG_WINDOW[2].x, EASTEREGG_WINDOW[2].y, tocolor(0, 200, 0, 255), 1, getVRPFont(self.m_FontBig), "center", "center")
	dxDrawText("Press Enter to proceed!", 0, self.m_FontBigHeight*3 , EASTEREGG_WINDOW[2].x, EASTEREGG_WINDOW[2].y, tocolor(0, 200, 0, 255), 1, getVRPFont(self.m_Font), "center", "center")
end

function EasterEggArcade.HUD:drawLevelInfo()
	if self.m_LevelDisplay + 5000 >= getTickCount() then
		if not self.m_OutroLevel then
			dxDrawText("Level "..self.m_Level, 3, (EASTEREGG_WINDOW[2].y*0.1)+3, EASTEREGG_WINDOW[2].x, EASTEREGG_WINDOW[2].y, tocolor(0, 0, 0, 255), 1, getVRPFont(self.m_FontBig), "center", "center")
			dxDrawText("Level "..self.m_Level, 0, EASTEREGG_WINDOW[2].y*0.1, EASTEREGG_WINDOW[2].x, EASTEREGG_WINDOW[2].y, tocolor(244, 66, 194, 255), 1, getVRPFont(self.m_FontBig), "center", "center")
			dxDrawText("Enemy: "..self.m_Enemy.."!", 0, self.m_FontBigHeight*3+3, EASTEREGG_WINDOW[2].x, EASTEREGG_WINDOW[2].y, tocolor(0, 0, 0, 255), 1, getVRPFont(self.m_Font), "center", "center")
			dxDrawText("Enemy: "..self.m_Enemy.."!", 3, self.m_FontBigHeight*3, EASTEREGG_WINDOW[2].x, EASTEREGG_WINDOW[2].y, tocolor(244, 66, 194, 255), 1, getVRPFont(self.m_Font), "center", "center")
		else
			dxDrawText("Collect your prize!", 3, (EASTEREGG_WINDOW[2].y*0.1)+3, EASTEREGG_WINDOW[2].x, EASTEREGG_WINDOW[2].y, tocolor(0, 0, 0, 255), 1, getVRPFont(self.m_FontBig), "center", "center")
			dxDrawText("Collect your prize!", 0, EASTEREGG_WINDOW[2].y*0.1, EASTEREGG_WINDOW[2].x, EASTEREGG_WINDOW[2].y, tocolor(244, 66, 194, 255), 1, getVRPFont(self.m_FontBig), "center", "center")
		end
	end
end

function EasterEggArcade.HUD:drawDamage()
	local x,y, start, elap, dur, prog, alpha
	local now = getTickCount()
	for i = 1, #self.m_DamageQueue do
		if self.m_DamageQueue[i] then
			x,y, start = self.m_DamageQueue[i][1], self.m_DamageQueue[i][2], self.m_DamageQueue[i][3]
			prog = (now - start) / 1000
			y, alpha = interpolateBetween(y, 255, 0, y-64, 0, 0, prog, "Linear")
			dxDrawText("-9", x, y+1, x, y, tocolor(0, 0, 0, alpha), 1, getVRPFont(self.m_Font))
			dxDrawText("-9", x, y, x, y, tocolor(255, 200, 0, alpha), 1, getVRPFont(self.m_Font))
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
		EASTEREGG_WINDOW[1].y = EASTEREGG_WINDOW[1].y - shake
		if prog >= 1 then
			self.m_Shake = false
			EASTEREGG_WINDOW[1].x = self.m_OriginalEASTEREGG_WINDOW.x
			EASTEREGG_WINDOW[1].y = self.m_OriginalEASTEREGG_WINDOW.y
		end
	end
end

function EasterEggArcade.HUD:startOutro()
	self.m_OutroTick = getTickCount()
	self.m_Outro = true
end

function EasterEggArcade.HUD:drawOutro()
	local now = getTickCount()
	prog = (now - self.m_OutroTick) / 30000
	self.m_Scroll = interpolateBetween(EASTEREGG_WINDOW[2].y+((self.m_FontHeight*2.5)*6)+self.m_FontBigHeight, 0, 0, -2*EASTEREGG_WINDOW[2].y, 0, 0, prog, "Linear")
	dxDrawText("Lufia 2 - The very end (8Bit)", 0, self.m_Scroll, EASTEREGG_WINDOW[2].x, EASTEREGG_WINDOW[2].y, tocolor(212, 93, 0, 255), 1, getVRPFont(self.m_Font), "center", "center")
	dxDrawText("GTA: Vice City Theme (8Bit)", 0, self.m_Scroll-(self.m_FontHeight*2.5), EASTEREGG_WINDOW[2].x, EASTEREGG_WINDOW[2].y, tocolor(212, 93, 0, 255), 1, getVRPFont(self.m_Font), "center", "center")
	dxDrawText("Running in the 90s (8Bit)", 0, self.m_Scroll-((self.m_FontHeight*2.5)*2), EASTEREGG_WINDOW[2].x, EASTEREGG_WINDOW[2].y, tocolor(212, 93, 0, 255), 1, getVRPFont(self.m_Font), "center", "center")
	dxDrawText("Lux Aeterna (8Bit)", 0, self.m_Scroll-((self.m_FontHeight*2.5)*3), EASTEREGG_WINDOW[2].x, EASTEREGG_WINDOW[2].y, tocolor(212, 93, 0, 255), 1, getVRPFont(self.m_Font), "center", "center")
	dxDrawText("MUSIC:", 0, self.m_Scroll-((self.m_FontHeight*2.5)*4), EASTEREGG_WINDOW[2].x, EASTEREGG_WINDOW[2].y, tocolor(212, 93, 0, 255), 1, getVRPFont(self.m_Font), "center", "center")
	dxDrawText("Strobe - 2018", 0, self.m_Scroll-((self.m_FontHeight*2.5)*5), EASTEREGG_WINDOW[2].x, EASTEREGG_WINDOW[2].y, tocolor(212, 93, 0, 255), 1, getVRPFont(self.m_Font), "center", "center")
	dxDrawText("Braboy", 0, self.m_Scroll-((self.m_FontHeight*2.5)*6), EASTEREGG_WINDOW[2].x, EASTEREGG_WINDOW[2].y, tocolor(212, 93, 0, 255), 1, getVRPFont(self.m_FontBig), "center", "center")
end
