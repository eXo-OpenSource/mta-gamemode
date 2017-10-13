--// WORKAROUND HACK /

GUIWindowsFocus = inherit( Singleton )

function GUIWindowsFocus:constructor()
	self.m_CurrentFocus = nil
end

function GUIWindowsFocus:setCurrentFocus( mObj )
	if mObj and mObj:isVisible() then
		if self.m_CurrentFocus then self.m_CurrentFocus.m_Parent:moveToBack() end
		self.m_CurrentFocus = mObj
		mObj.m_Parent:bringToFront()
		outputDebug(mObj.m_TitleLabel:getText(), "is on focus")
		return
	end
	self.m_CurrentFocus = nil
end

function GUIWindowsFocus:getCurrentFocus( )
	return self.m_CurrentFocus
end

function GUIWindowsFocus:On_WindowOff( mObj )
	local obj = self:getCurrentFocus()
	if obj == mObj then
		self:setCurrentFocus( nil )
	end
end
