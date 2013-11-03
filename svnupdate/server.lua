local revision = 0
local svn_path = "D:\\Dev\\MTA\\GTASAOnline\\SVN\\trunk\\"
local svn_log_path = "D:\\Dev\\MTA\\GTASAOnline\\SVN\\trunk\\svnupdate\\svnLog.xml"

addEvent("onSVNUpdate")
addEventHandler("onSVNUpdate", root,
	function()
		outputChatBox("Successfully updated the svn", root, 0, 255, 0)
		outputServerLog("Successfully updated the svn")
		
		logSVN(root)
		triggerClientEvent("onClientSVNRevisionSet", root, revision)
		outputServerLog("Current revision: "..revision)
	end
)

addEvent("onClientSVNRevisionRequest", true)
addEventHandler("onClientSVNRevisionRequest", root,
	function()
		triggerClientEvent(source, "onClientSVNRevisionSet", root, revision)
	end
)

addCommandHandler("svnupdate",
	function(player)
		outputChatBox("SVN Update started...", root, 255, 255, 0)
		if not updateFromSVN(svn_path, svn_log_path) then
			outputChatBox("SVN Update failed", root, 255, 0, 0)
			outputServerLog("SVN: Update failed")
			return
		end
	end
)

function logSVN(player)
	assert(player, "Bad argument #1 @ logSVN")
	local logTab = {}
	local xmlRoot = xmlLoadFile("svnLog.xml")
	if not xmlRoot then
		outputDebugString("Can't open xml file", 1)
		return
	end
	local entriesRoot = xmlNodeGetChildren(xmlRoot)
	for i, entryNode in ipairs(entriesRoot) do
		local rev = tonumber(xmlNodeGetAttribute(entryNode, "revision"))
		local entryChildren = xmlNodeGetChildren(entryNode)
		local author = xmlNodeGetValue(xmlFindChild(entryNode, "author", 0))
		local date = xmlNodeGetValue(xmlFindChild(entryNode, "date", 0))
		date = string.gsub(date, "T", " ")
		date = string.sub(date, 1, string.find(date, '.', 1, true) - 1)
		local msg = xmlNodeGetValue(xmlFindChild(entryNode, "msg", 0))
		logTab[rev] = {
			["author"] = author,
			["date"] = date,
			["msg"] = msg
		}
		
		-- Update revision
		if i == 1 then
			revision = rev
		end
	end
	xmlUnloadFile(xmlRoot)
	triggerClientEvent(player, "onClientSVNLog", root, logTab)
end
addCommandHandler("log", logSVN)

function getRevision()
	return revision
end
