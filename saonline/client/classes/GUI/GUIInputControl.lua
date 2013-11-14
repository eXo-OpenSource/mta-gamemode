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

addEventHandler("onClientResourceStop", resourceRoot, function() guiSetInputEnabled(false) end)

function GUIInputControl.setFocus(edit, caret)
	if GUIInputControl.ms_CurrentInputFocus and not edit then
		local e = GUIInputControl.ms_CurrentInputFocus
		e:onInternalLooseFocus()
		if e.onLooseFocus then
			e:onLooseFocus()
		end
	end

	GUIInputControl.ms_CurrentInputFocus = edit

	if edit then
		guiBringToFront(GUIInputControl.ms_Edit)
		if caret then
			guiEditSetCaretIndex(GUIInputControl.ms_Edit, caret)
		else
			guiEditSetCaretIndex(GUIInputControl.ms_Edit, #edit:getText())
		end
		guiSetInputEnabled(true)
		guiSetText(GUIInputControl.ms_Edit, edit:getText())
		
		edit:onInternalFocus()
		if edit.onFocus then
			edit:onFocus()
		end
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
				GUIInputControl.ms_CurrentInputFocus:onInternalEditInput(guiEditGetCaretIndex and guiEditGetCaretIndex(GUIInputControl.ms_Edit))
			end
			if GUIInputControl.ms_CurrentInputFocus.onEditInput then
				GUIInputControl.ms_CurrentInputFocus:onEditInput(guiEditGetCaretIndex and guiEditGetCaretIndex(GUIInputControl.ms_Edit))
			end
		end
	end
)

