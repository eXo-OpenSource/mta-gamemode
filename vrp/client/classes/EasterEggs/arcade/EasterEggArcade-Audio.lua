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

EasterEggArcade = {}
EasterEggArcade.Audio = inherit(Object) 

function EasterEggArcade.Audio:constructor()
	self.m_LastFire = getTickCount()
	self.m_LastDamage = getTickCount()
	self.m_LastHit = getTickCount()
end


function EasterEggArcade.Audio:destructor()
	if self.m_Fire and isElement(self.m_Fire) then destroyElement(self.m_Fire) end
	if self.m_Damage and isElement(self.m_Damage) then destroyElement(self.m_Damage) end
	if self.m_Hit and isElement(self.m_Hit) then destroyElement(self.m_Hit) end
	if self.m_Music and isElement(self.m_Music) then destroyElement(self.m_Music) end
	if self.m_Gameover and isElement(self.m_Gameover) then destroyElement(self.m_Gameover) end
	if self.m_Win and isElement(self.m_Win) then destroyElement(self.m_Win) end
end

function EasterEggArcade.Audio:playFire()
	if self.m_LastFire + 300 < getTickCount() then
		self.m_LastFire = getTickCount()
		if self.m_Fire and isElement(self.m_Fire) then 
			destroyElement(self.m_Fire) 
		end
		self.m_Fire = playSound(SFX_PATH.."/fire.ogg", false)
	end
end

function EasterEggArcade.Audio:playDamage()
	if self.m_LastDamage + 300 < getTickCount() then
		self.m_LastDamage = getTickCount()
		if self.m_Damage and isElement(self.m_Damage) then 
			destroyElement(self.m_Damage) 
		end
		self.m_Damage = playSound(SFX_PATH.."/explode.ogg", false)
	end
end

function EasterEggArcade.Audio:playHit()
	if self.m_LastHit + 300 < getTickCount() then
		self.m_LastHit = getTickCount()
		if self.m_Hit and isElement(self.m_Hit) then 
			destroyElement(self.m_Hit) 
		end
		self.m_Hit = playSound(SFX_PATH.."/hit.ogg", false)
	end
end

function EasterEggArcade.Audio:playGameOver()
	if self.m_Music then 
		stopSound(self.m_Music)
	end
	if not self.m_Gameover then
		self.m_Gameover = playSound(SFX_PATH.."/gameover.ogg", false)
	end
end

function EasterEggArcade.Audio:playWin() 
	if self.m_Music then 
		stopSound(self.m_Music)
	end
	if not self.m_Win then
		self.m_Win = playSound(SFX_PATH.."/win.ogg", false)
	end
end

function EasterEggArcade.Audio:playMusic() 
	self.m_Music = playSound(SFX_PATH.."/lufia.ogg", true)
end