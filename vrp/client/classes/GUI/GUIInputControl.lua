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
		GUIInputControl.skipChangedEvent = true

		guiBringToFront(GUIInputControl.ms_Edit)
		oldCaretIndex = guiEditGetCaretIndex(GUIInputControl.ms_Edit)
		guiSetInputEnabled(true)
		guiSetText(GUIInputControl.ms_Edit, edit:getText())

		GUIInputControl.skipChangedEvent = false

		if caret then
			guiEditSetCaretIndex(GUIInputControl.ms_Edit, caret)
		else
			guiEditSetCaretIndex(GUIInputControl.ms_Edit, utfLen(edit:getText()))
		end

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
		if GUIInputControl.skipChangedEvent then return end

		local currentEdit = GUIInputControl.ms_CurrentInputFocus
		if currentEdit then
			local text = guiGetText(source)

			if currentEdit.m_Selection and not currentEdit.m_SelectionRenderOnly then
				GUIInputControl.skipChangedEvent = true
				text = ("%s%s"):format(utfSub(text, 0, currentEdit.m_SelectionStart), utfSub(text, currentEdit.m_SelectionEnd + 1, #text))
				guiSetText(source, text)
				guiEditSetCaretIndex(GUIInputControl.ms_Edit, currentEdit.m_SelectionStart + 1)
				GUIInputControl.skipChangedEvent = false
			end

			if currentEdit:isNumeric() then
				if currentEdit:isIntegerOnly() then
					if (text == "" or pregFind(text, '^[0-9]*$')) and utfLen(text) <= currentEdit.m_MaxLength and tonumber(text == "" and 0 or text) <= currentEdit.m_MaxValue then
						GUIInputControl.ms_PreviousInput = text
						currentEdit:setText(text)
					else
						guiSetText(source, GUIInputControl.ms_PreviousInput or "") -- Triggers onClientGUIChanged again
					end
				else
					if (tonumber(text) or text == "") and utfLen(text) <= currentEdit.m_MaxLength and tonumber(text == "" and 0 or text) <= currentEdit.m_MaxValue then
						GUIInputControl.ms_PreviousInput = text
						currentEdit:setText(text)
					else
						guiSetText(source, GUIInputControl.ms_PreviousInput or "") -- Triggers onClientGUIChanged again
					end
				end
			else
				if utfLen(text) <= currentEdit.m_MaxLength then
					GUIInputControl.ms_PreviousInput = text
					currentEdit:setText(text)
				else
					guiSetText(source, GUIInputControl.ms_PreviousInput or "")
				end
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
				GUIInputControl.ms_CurrentInputFocus.m_MarkedAll = false
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
		local current = GUIInputControl.ms_CurrentInputFocus

		if button == "tab" and pressed and current then
			local element = getNextEditbox(current:getParent(), current)
			if element then
				GUIInputControl.setFocus(element, 0)
			end
		elseif button == "a" and pressed and current then
			if getKeyState("lctrl") or getKeyState("rctrl") then
				current.m_MarkedAll = true
				current:anyChange()
			end
		elseif (button == "arrow_l" or button == "arrow_r" or button == "home" or button == "end") and pressed and current then
			if not getKeyState("lshift") or not getKeyState("rshift") then
				current.m_MarkedAll = false
				current.m_Selection = false
				current:anyChange()
			end
		elseif button == "c" and pressed and GUIInputControl.ms_RecentlyInFocus then
			if getKeyState("lctrl") or getKeyState("rctrl") then
				if GUIInputControl.ms_RecentlyInFocus.m_SelectedText then
					setClipboard(GUIInputControl.ms_RecentlyInFocus.m_SelectedText)
				end
			end
		end
	end
)
