AppNametag = inherit(PhoneApp)

AppNametag.COLOURS = {
}

function AppNametag:constructor()
	PhoneApp.constructor(self,"Nametag", "files/images/Phone/Apps/IconHelloWorld.png")
end

function AppNametag:onOpen(form)
end

function AppNametag:onClose()
end