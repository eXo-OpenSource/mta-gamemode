-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
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
	if GUIInputControl.ms_CurrentInputFocus and edit ~= GUIInputControl.ms_CurrentInputFocus then
		local e = GUIInputControl.ms_CurrentInputFocus
		e:onInternalLooseFocus()
		if e.onLooseFocus then
			e:onLooseFocus()
		end
	end

	GUIInputControl.ms_CurrentInputFocus = edit
	GUIInputControl.ms_PreviousInput = guiGetText(GUIInputControl.ms_Edit)

	if edit then
		guiBringToFront(GUIInputControl.ms_Edit)
		if caret then
			guiEditSetCaretIndex(GUIInputControl.ms_Edit, caret)
		else
			guiEditSetCaretIndex(GUIInputControl.ms_Edit, utfLen(edit:getText()))
		end

		oldCaretIndex = guiEditGetCaretIndex(GUIInputControl.ms_Edit)
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
		local currentEdit = GUIInputControl.ms_CurrentInputFocus
		if currentEdit then
			local text = guiGetText(source)

			if currentEdit:isNumeric() then
				if currentEdit:isIntegerOnly() then
					if text == "" or pregFind(text, '^[0-9]*$') then
						GUIInputControl.ms_PreviousInput = text
						currentEdit:setText(text)
					else
						guiSetText(source, GUIInputControl.ms_PreviousInput or "") -- Triggers onClientGUIChanged again
					end
				else
					if tonumber(text) or text == "" then
						GUIInputControl.ms_PreviousInput = text
						currentEdit:setText(text)
					else
						guiSetText(source, GUIInputControl.ms_PreviousInput or "") -- Triggers onClientGUIChanged again
					end
				end
			else
				currentEdit:setText(text)
			end

			if currentEdit.onInternalEditInput then
				currentEdit:onInternalEditInput(guiEditGetCaretIndex(source))
			end
			if currentEdit.onEditInput then
				currentEdit:onEditInput(guiEditGetCaretIndex(source))
			end
		end
	end
)

local oldCaretIndex = 0
addEventHandler("onClientPreRender", root,
	function()
		-- Check if caret index has changed
		if GUIInputControl.ms_CurrentInputFocus then
			local caretIndex = guiEditGetCaretIndex(GUIInputControl.ms_Edit)

			if oldCaretIndex ~= caretIndex then
				GUIInputControl.ms_CurrentInputFocus:setCaretPosition(caretIndex)
				oldCaretIndex = caretIndex
			end
		end
	end
)

local function getNextEditbox(baseElement, startElement)
	local children = baseElement:getChildren()
	local idx = table.find(children, startElement)

	for i = idx+1, #children do
		if instanceof(children[i], GUIEdit, true) then
			return children[i]
		end
	end
	for i = 0, idx-1 do
		if instanceof(children[i], GUIEdit, true) then
			return children[i]
		end
	end

	return false
end

addEventHandler("onClientKey", root,
	function(button, pressed)
		if button == "tab" and pressed then
			local current = GUIInputControl.ms_CurrentInputFocus
			if current then
				local element = getNextEditbox(current:getParent(), current)
				if element then
					GUIInputControl.setFocus(element, 0)
				end
			end
		end
	end
)
