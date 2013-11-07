-- ****************************************************************************
-- *
-- *  PROJECT:     Open MTA:DayZ
-- *  FILE:        client/classes/GUI/GUIInputControl.lua
-- *  PURPOSE:     Static Class for handling text input for CGUIEdit ( + maybe later more )
-- *
-- ****************************************************************************

GUIInputControl = {}
GUIInputControl.ms_CurrentInputFocus = nil
GUIInputControl.ms_Edit = guiCreateEdit(0, 0, 1, 1, "", false)
guiSetAlpha(GUIInputControl.ms_Edit, 0)

function GUIInputControl.constructor()
	error("Cannot create a new GUIInputControl")
end

function GUIInputControl.setFocus(edit)
	GUIInputControl.ms_CurrentInputFocus = edit

	if edit then
		guiBringToFront(GUIInputControl.ms_Edit)
		guiEditSetCaretIndex(GUIInputControl.ms_Edit, #edit:getText())
		guiSetInputEnabled(true)
		guiSetText(GUIInputControl.ms_Edit, edit:getText())
	else
		guiSetInputEnabled(false)
	end
end

function GUIInputControl.checkFocus(element)
	if GUIInputControl.ms_CurrentInputFocus ~= element then
		GUIInputControl.setFocus()
	end
end

addEventHandler("onClientGUIChanged", GUIInputControl.ms_Edit, 
	function()
		if GUIInputControl.ms_CurrentInputFocus then
			GUIInputControl.ms_CurrentInputFocus:setText(guiGetText(source))
			
			if GUIInputControl.ms_CurrentInputFocus.onInternalEditInput then
				GUIInputControl.ms_CurrentInputFocus:onInternalEditInput()
			end
			if GUIInputControl.ms_CurrentInputFocus.onEditInput then
				GUIInputControl.ms_CurrentInputFocus:onEditInput()
			end
		end
	end
)

