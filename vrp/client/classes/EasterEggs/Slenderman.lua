-- Slenderman
EasterEgg.Slenderman = inherit(Object)

function EasterEgg.Slenderman:constructor(position, rotation)
	-- load models
	__, self.m_TXD = CustomModelManager:getSingleton():loadImportTXD("files/models/scary.txd", 230)
    CustomModelManager:getSingleton():loadImportDFF("files/models/scary.dff", 230)

	-- create ped + sound
	self.m_StartPosition = position
	self.m_Ped = createPed(230, position, rotation.z)
	self.m_Sound = Sound3D("files/audio/scary.mp3", position)
	self.m_Sound:setMaxDistance(300)
	self.m_Sound:setMinDistance(1)
	self.m_Sound:attach(self.m_Ped)
	self.m_CameraFaded = false

	-- add movement handler
	self.m_Render = bind(self.move, self)
	addEventHandler("onClientRender", root, self.m_Render)

	-- add destruction handler
	setTimer(bind(delete, self), self.m_Sound.length*1000, 1)
end

function EasterEgg.Slenderman:destructor()
	outputDebug("Slenderman.destructor")
	-- Remove movement handler
	removeEventHandler("onClientRender", root, self.m_Render)

	-- Destroy texture and slender
	self.m_TXD:destroy()
	self.m_Ped:destroy()
	CustomModelManager:getSingleton():restoreModel(230)
end

function EasterEgg.Slenderman:move()
	local progress = 1-((self.m_Sound.length - self.m_Sound.playbackPosition)/self.m_Sound.length)
	self.m_Ped:setPosition(interpolateBetween(self.m_StartPosition, localPlayer.position, progress, "InQuad"))
	self.m_Ped:setRotation(Vector3(0, 0, findRotation(self.m_Ped.position.x, self.m_Ped.position.y, localPlayer.position.x, localPlayer.position.y)))

	if progress >= 0.95 and not self.m_CameraFaded then
		fadeCamera(false, 0.3)
		self.m_CameraFaded = true
	end
end
