local screenWidth, screenHeight = guiGetScreenSize()
local revision = 0

function gui()
	window = guiCreateWindow(screenWidth/2-537/2,screenHeight/2-385/2,537,385,"Subversion log",false)
	gridRev = guiCreateGridList(9,24,122,351,false,window)
	guiGridListAddColumn(gridRev, "Revision", 0.9)
	memoDescription = guiCreateMemo(136,53,391,321,"",false,window)
	guiMemoSetReadOnly(memoDescription, true)
	btnClose = guiCreateButton(499,23,26,24,"X",false,window)
	guiCreateLabel(138,27,32,16,"Time:",false,window)
	lblTime = guiCreateLabel(173,27,180,16,"05.02.2012  -  10:29",false,window)
	guiCreateLabel(364,27,80,16,"Commiter:",false,window)
	lblAuthor = guiCreateLabel(422,27,80,16, "",false,window)
	
	guiSetVisible(window, false)
	addEventHandler("onClientGUIClick", btnClose, close, false)
	addEventHandler("onClientGUIClick", gridRev, showDescription, false)
end

function handle(logTable)
	if window == nil then gui() end
	if window ~= nil then
		guiSetVisible(window, true)
		showCursor(true)
		
		guiGridListClear(gridRev)
		logTab = logTable --> global
		for rev=#logTab, 1, -1 do
			local row = guiGridListAddRow(gridRev)
			guiGridListSetItemText(gridRev, row, 1, tostring(rev), false, true)
			if rev == #logTab then
				guiGridListSetItemColor(gridRev, row, 1, 255, 0, 0)
			end
		end
		guiSetText(memoDescription, logTab[#logTab].msg)
		guiSetText(lblTime, logTab[#logTab].date)
		guiSetText(lblAuthor, logTab[#logTab].author)
	end
end
addEvent("onClientSVNLog", true)
addEventHandler("onClientSVNLog", root, handle)

addEvent("onClientSVNRevisionSet", true)
addEventHandler("onClientSVNRevisionSet", root,
	function(rev)
		revision = rev
		outputChatBox("Current revision: "..rev, 255, 255, 0)
	end
)
triggerServerEvent("onClientSVNRevisionRequest", root)

function getRevision()
	return revision
end

function close(button, state)
	if button == "left" and state == "up" then
		guiSetVisible(window, false)
		showCursor(false)
	end
end

function showDescription(button, state)
	if button == "left" and state == "up" then
		local selectedRow = guiGridListGetSelectedItem(gridRev)
		if selectedRow ~= -1 then
			local rev = tonumber(guiGridListGetItemText(gridRev, selectedRow, 1))
			assert(rev) --prevent error msg
			guiSetText(memoDescription, logTab[rev].msg)
			guiSetText(lblTime, logTab[rev].date)
			guiSetText(lblAuthor, logTab[rev].author)
		end
	end
end