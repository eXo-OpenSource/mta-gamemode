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
	if self.m_Collect and isElement(self.m_Collect) then destroyElement(self.m_Collect) end
end

function EasterEggArcade.Audio:playFire()
	if self.m_LastFire + 300 < getTickCount() then
		self.m_LastFire = getTickCount()
		if self.m_Fire and isElement(self.m_Fire) then 
			destroyElement(self.m_Fire) 
		end
		self.m_Fire = playSound(EASTEREGG_SFX_PATH.."/fire.ogg", false)
	end
end

function EasterEggArcade.Audio:playDamage()
	if self.m_LastDamage + 300 < getTickCount() then
		self.m_LastDamage = getTickCount()
		if self.m_Damage and isElement(self.m_Damage) then 
			destroyElement(self.m_Damage) 
		end
		self.m_Damage = playSound(EASTEREGG_SFX_PATH.."/explode.ogg", false)
	end
end

function EasterEggArcade.Audio:playHit()
	if self.m_LastHit + 300 < getTickCount() then
		self.m_LastHit = getTickCount()
		if self.m_Hit and isElement(self.m_Hit) then 
			destroyElement(self.m_Hit) 
		end
		self.m_Hit = playSound(EASTEREGG_SFX_PATH.."/hit.ogg", false)
	end
end

function EasterEggArcade.Audio:playGameOver()
	if self.m_Music then 
		stopSound(self.m_Music)
	end
	if not self.m_Gameover then
		self.m_Gameover = playSound(EASTEREGG_SFX_PATH.."/gameover.ogg", false)
	end
end

function EasterEggArcade.Audio:playCollect()
	if self.m_Music then 
		stopSound(self.m_Music)
	end
	if not self.m_Collect then
		self.m_Collect = playSound(EASTEREGG_SFX_PATH.."/collect.ogg", false)
	end
end

function EasterEggArcade.Audio:playWin() 
	if self.m_Music then 
		stopSound(self.m_Music)
	end
	if not self.m_Win then
		self.m_Win = playSound(EASTEREGG_SFX_PATH.."/win.ogg", false)
	end
end

function EasterEggArcade.Audio:playMusic(alternate)
	if not alternate then
		self.m_Music = playSound(EASTEREGG_SFX_PATH.."/lufia.ogg", true)
	else 
		self.m_Music = playSound(EASTEREGG_SFX_PATH.."/troll.ogg", true)
	end
end