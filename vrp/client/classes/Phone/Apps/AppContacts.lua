-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        TODO
-- *  PURPOSE:     TODO
-- *
-- ****************************************************************************
AppContacts = inherit(PhoneApp)

function AppContacts:constructor()
	PhoneApp.constructor(self, "Kontakte", "IconContacts.png")
end

function AppContacts:onOpen(form)
	self.m_ContactListGrid = GUIGridList:new(10, 10, form.m_Width-20, form.m_Height-60, form)
	self.m_ContactListGrid:addColumn(_"Spieler", 0.7)
	self.m_ContactListGrid:addColumn(_"Num.", 0.3)

	self.m_ButtonRemoveContact = GUIButton:new(10, form.m_Height-40, 30, 30, "-", form):setBackgroundColor(Color.Red)
	self.m_ButtonRemoveContact.onLeftClick = bind(self.ButtonRemoveContact_Click, self)

	self.m_ButtonCallPlayers = GUIButton:new(form.m_Width-110, form.m_Height-40, 100, 30, _"Anrufen", form):setBackgroundColor(Color.Green)
	self.m_ButtonCallPlayers.onLeftClick = bind(self.ButtonCallPlayer_Click, self)

	self:refreshContacts()
end

function AppContacts:ButtonRemoveContact_Click()
	local item = self.m_ContactListGrid:getSelectedItem()

	for i, contact in pairs(self.m_PlayerContacts) do
		if item.Owner ==  contact[1] then
			table.remove(self.m_PlayerContacts, i)
			core:set("ContactList", "Players", toJSON(self.m_PlayerContacts))
			return self:refreshContacts()
		end
	end
end

function AppContacts:ButtonCallPlayer_Click()
	local player = getPlayerFromName(self.m_ContactListGrid:getSelectedItem().Owner)

	if not player then
		ErrorBox:new(_"Dieser Spieler ist nicht online!")
		return
	end

	if player == localPlayer then
		ErrorBox:new(_"Du kannst dich nicht selbst anrufen!")
		return
	end

	CallResultActivity:new(self, "player", player, CALL_RESULT_CALLING, false)
	triggerServerEvent("callStart", root, player, false)
end

function AppContacts:refreshContacts()
	self.m_PlayerContacts = fromJSON(core:get("ContactList", "Players", "[ [ ] ]"))

	self.m_ContactListGrid:clear()
	for _, contact in pairs(self.m_PlayerContacts) do
		local item = self.m_ContactListGrid:addItem(tostring(contact[1]), tostring(contact[2]))
		item.Owner = contact[1]
		item.Number = contact[2]
	end
end
