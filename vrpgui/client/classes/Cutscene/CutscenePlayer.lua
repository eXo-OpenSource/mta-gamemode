CutscenePlayer = inherit(Singleton)

function CutscenePlayer:constructor()
	self.m_Cutscene = false
	self.m_CutsceneList = {}
end

function CutscenePlayer:playCutscene(name, finishcallback)
	assert(self.m_CutsceneList[name])
	setElementDimension(localPlayer, PRIVATE_DIMENSION_CLIENT)
	self.m_Cutscene = Cutscene:new(self.m_CutsceneList[name])
	self.m_Cutscene.onFinish = 
		function(cutscene)
			CutscenePlayer:getSingleton():stopCutscene()
			setElementDimension(localPlayer, 0)
			if finishcallback then 
				finishcallback()
			end
		end;
	
	self.m_Cutscene:play()
end

function CutscenePlayer:stopCutscene()
	self.m_Cutscene:delete()
end

function CutscenePlayer:registerCutscene(name, cutscene)
	self.m_CutsceneList[name] = cutscene
end