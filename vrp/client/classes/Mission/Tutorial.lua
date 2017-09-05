Tutorial = {}

-- stage1: during character creation until stepping out of the binco
Tutorial.stage1 = inherit(Object)
function Tutorial.stage1:constructor()
	self.m_Marker = createMarker(207.64, -110.52, 1005.13, "corona", 2, 255, 255, 255, 200)
	setElementInterior(self.m_Marker, 15)
	CharacterCreationGUI:new()
	
	addEventHandler("onClientMarkerHit", self.m_Marker,
		function(hitElement, matchingDimension)
			if hitElement == localPlayer and matchingDimension then
				setElementInterior(hitElement, 0, 2244.67, -1665.30, 15.47)
				setElementDimension(hitElement, 0)
				setElementRotation(hitElement, 0, 0, 340)
				setCameraTarget(hitElement, hitElement)
				toggleAllControls(false, true, false)
				setElementFrozen(hitElement, true)
				CutscenePlayer:getSingleton():playCutscene("Tutorial.Stage1")
			end
		end
	)
end

function Tutorial.stage1:destructor()
	destroyElement(self.m_Marker)
end