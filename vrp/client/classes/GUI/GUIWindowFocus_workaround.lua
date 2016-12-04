--// WORKAROUND HACK /

GUIWindowsFocus = inherit( Singleton )

function GUIWindowsFocus:constructor()
	self.m_CurrentFocus = nil
end

function GUIWindowsFocus:setCurrentFocus( mObj )
	if mObj and mObj:isVisible() then
		self.m_CurrentFocus = mObj
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
