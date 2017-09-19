-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Development/CodeEditor.lua
-- *  PURPOSE:     Faction State Class
-- *
-- ****************************************************************************


CodeEditorGUI = inherit(GUIForm)
inherit(Singleton, CodeEditorGUI)

CodeSession = inherit(Singleton)

addEvent("onCodeEditorSend", true)
CodeEditorGUI.ms_Themes = {"material", "base16-light"}

function CodeEditorGUI:constructor()

	GUIWindow.updateGrid()
	self.m_Width = grid("x", 20)
	self.m_Height = grid("y", 16)

	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Code Editor", true, true, self)

	GUIGridLabel:new(1, 1, 6, 1, _"Editor", self.m_Window):setHeader("sub")
	self.m_ThemeChanger = GUIGridChanger:new(7, 1, 5, 1, self.m_Window)
	self.m_NameEdit = GUIGridEdit:new(13, 1, 5, 1, self.m_Window):setCaption("Klassenname")
	self.m_RefreshBtn = GUIGridIconButton:new(18, 1, FontAwesomeSymbols.Refresh, self.m_Window)
	self.m_CopyBtn = GUIGridIconButton:new(19, 1, FontAwesomeSymbols.Copy, self.m_Window)
    self.m_EditorBrowser = GUIGridWebView:new(1, 2, 19, 10, "http://mta/local/files/html/editor.htm", true, self.m_Window)

	GUIGridLabel:new(1, 12, 5, 1, _"Optionen", self.m_Window):setHeader("sub")
    GUIGridButton:new(1, 13, 5, 1, "Option 1", self.m_Window)
    GUIGridButton:new(1, 14, 5, 1, "Option 2", self.m_Window)
    GUIGridButton:new(1, 15, 5, 1, "Option 3", self.m_Window)

	self.m_NameEdit:setText("Klasse")

	for i,v in pairs(CodeEditorGUI.ms_Themes) do
		self.m_ThemeChanger:addItem(v)
	end
	self.m_ThemeChanger.onChange = function(theme)
		self.m_EditorBrowser:callEvent("onCodeEditorThemeChange", theme)
	end

	self.m_RefreshBtn.onLeftClick = function()
		self.m_EditorBrowser:callEvent("onCodeEditorRequest", "")
		self.m_ReceiveMode = "load"
	end
	self.m_CopyBtn.onLeftClick = function()
		self.m_EditorBrowser:callEvent("onCodeEditorRequest", "")
		self.m_ReceiveMode = "copy"
	end

	addEventHandler("onCodeEditorSend", resourceRoot, bind(CodeEditorGUI.onCodeReceive, self))
end

function CodeEditorGUI:onCodeReceive(code)
	if self.m_ReceiveMode == "copy" then
		setClipboard(code)
		InfoBox:new(_"Code in der Zwischenablage gespeichert.")
	elseif self.m_ReceiveMode == "load" then
		local name = self.m_NameEdit:getText()
		if CodeSession:getSingleton():getClassFromName(name) then
			CodeSession:getSingleton():unloadClass(name)
		end
		CodeSession:getSingleton():loadClass(CodeSession:getSingleton():parseFromString(code, name), name)
	end
end

function CodeEditorGUI:insertTemplate(template)
	self.m_EditorBrowser:callEvent("onCodeEditorTemplateInsert", template)
end


--//
--||	CodeSession
--\\

function CodeSession:constructor()
	self.m_Sessions = {}
end


function CodeSession:parseFromString(str, className)
	str = "local "..className.." = {}\n"..str.."\nCodeSession:getSingleton().m_Sessions['"..className.."'] = "..className
	return str
end

function CodeSession:loadClass(parsedString, name)
	if not self.m_Sessions[name] then
		--outputConsole(parsedString)
		loadstring(parsedString)()
		InfoBox:new(_("Klasse %s geladen.", name))
		local instance = self.m_Sessions[name].getSingleton and self.m_Sessions[name]:getSingleton() or self.m_Sessions[name]
		if self.m_Sessions[name].getSingleton then
			self.m_Sessions[name]:getSingleton()
		end
	else
		ErrorBox:new(_("Klasse %s ist bereits geladen", name))
	end
end

function CodeSession:unloadClass(name)
	if self.m_Sessions[name] then
		local instance = self.m_Sessions[name].getSingleton and self.m_Sessions[name]:getSingleton() or self.m_Sessions[name]
		if instance.destructor then
			instance:destructor()
		else
			outputDebugString("code session '"..name.."' has no destructor (possibly not deleted!")
		end
		self.m_Sessions[name] = nil
	end
end
function CodeSession:getClassFromName(name)
	return self.m_Sessions[name]
end




