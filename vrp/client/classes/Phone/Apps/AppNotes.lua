-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Phone/AppNotes.lua
-- *  PURPOSE:     A nicer notes app vong nicigkeit her
-- *
-- ****************************************************************************
AppNotes = inherit(PhoneApp)

function AppNotes:constructor()
	PhoneApp.constructor(self, "Notizen", "IconNotes.png")
end

function AppNotes:onOpen(form)
	GUIRectangle:new(0, 0, form.m_Width, form.m_Height, tocolor(0, 0, 0, 150), form)
	self.m_Label = GUILabel:new(10, 10, 200, 50, _"Notizen", form):setColor(Color.Black)
end
