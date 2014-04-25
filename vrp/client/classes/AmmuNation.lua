AmmuNationGUI = inherit(Singleton)

function AmmuNationGUI:constructor()

	self.m_Selection = 1
	self.m_CurrentMatrix = AmmuNationGUI.INFO[self.m_Selection].MATRIX
	self.m_Active = false
	self.m_CameraInstance = false
	
	setCameraMatrix(unpack(self.m_CurrentMatrix))
	
	addEventHandler("onClientKey", root, bind(self.onKey,self))
	
end

function AmmuNationGUI:changeMode(boolean)

	if not boolean then
		setCameraTarget(localPlayer,localPlayer)
	end
	
	for key, value in pairs(AmmuNationGUI.INFO) do
		setElementDimension(value.WEAPON,getElementDimension(localPlayer))
	end
	
	self.m_Active = not self.m_Active
	
end

function AmmuNationGUI:onKey(key,state)

	if not self.m_Active then
		return
	end
	
	if state then
		if key == "arrow_l" then
			self.m_Selection = self.m_Selection - 1
		elseif key == "arrow_r" then
			self.m_Selection = self.m_Selection + 1
		end
		self.m_Selection = math.min(self.m_Selection,#AmmuNationGUI.INFO)
		if self.m_Selection < 1 then
			self.m_Selection = 1
		end
		self:updateMatrix()
	end
end

function AmmuNationGUI:updateMatrix()
	self.m_CurrentMatrix = {getCameraMatrix(localPlayer)}
	local fadeMatrix = AmmuNationGUI.INFO[self.m_Selection].MATRIX
	
	if self.m_CameraInstance then
		self.m_CameraInstance:decon ()
	end
	
	self.m_CameraInstance = cameraDrive:new(self.m_CurrentMatrix[1],self.m_CurrentMatrix[2],self.m_CurrentMatrix[3],
	self.m_CurrentMatrix[4],self.m_CurrentMatrix[5],self.m_CurrentMatrix[6],
	fadeMatrix[1],fadeMatrix[2],fadeMatrix[3],
	fadeMatrix[4],fadeMatrix[5],fadeMatrix[6],
	1500
	)	
end

function AmmuNationGUI:destructor()

end

AmmuNationGUI.INFO = {
	[1] = {
		NAME = "AK-47",
		WEAPON = createObject(1337,0,0,0)
		MATRIX = {0,0,0,0,0,0},
	},
}