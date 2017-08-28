CutscenePlayer = inherit(Singleton)

function CutscenePlayer:constructor()
	self.m_Cutscene = false
	self.m_CutsceneList = {}
end

function CutscenePlayer:playCutscene(name, finishcallback, dim)
	assert(self.m_CutsceneList[name])

	localPlayer:setDimension(dim or PRIVATE_DIMENSION_CLIENT)
	localPlayer:setFrozen(true)

	local savedWeather = getWeather()

	self.m_Cutscene = Cutscene:new(self.m_CutsceneList[name], dim)
	self.m_Cutscene.onFinish =
		function(cutscene)
			CutscenePlayer:getSingleton():stopCutscene()
			localPlayer:setDimension(0)
			localPlayer:setFrozen(false)
			setCameraTarget(localPlayer)

			if finishcallback then
				finishcallback()
			end

			-- Show HUD
			HUDRadar:getSingleton():show()
			HUDUI:getSingleton():show()
			showChat(true)
			local realtime = getRealTime()
			setTime(realtime.hour, realtime.minute)
			setWeather(savedWeather)
		end;

	self.m_Cutscene:play()

	-- Hide HUD
	HUDRadar:getSingleton():hide()
	HUDUI:getSingleton():hide()
	showChat(false)
end

function CutscenePlayer:stopCutscene()
	self.m_Cutscene:delete()
end

function CutscenePlayer:registerCutscene(name, cutscene)
	self.m_CutsceneList[name] = cutscene
end
