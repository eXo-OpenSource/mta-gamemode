AppNametag = inherit(PhoneApp)

AppNametag.COLOURS = {
}

function AppNametag:constructor()
	PhoneApp.constructor(self,"Nametag", "files/images/Phone/Apps/IconHelloWorld.png")
	self.m_Nametag = Nametag:getSingleton()
end

function AppNametag:onOpen(form)
	self.m_Nametag.m_IsModifying = true
end

function AppNametag:onClose()
	self.m_Nametag.m_IsModifying = false
end