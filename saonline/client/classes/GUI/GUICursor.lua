-- ****************************************************************************
-- *
-- *  PROJECT:     Open MTA:DayZ
-- *  FILE:        client/classes/GUI/GUICursor.lua
-- *  PURPOSE:     GUI custom cursor class
-- *
-- ****************************************************************************
GUICursor = inherit(Singleton)

function GUICursor:constructor()
	TransferManager:getSingleton():requestFilesAsOnce(
	{	"files/images/HUD/Cursor.png";
	}
	, bind(GUICursor.load, self))

	bindKey("b", "down", function() showCursor(not isCursorShowing()) end)
end

function GUICursor:destructor()
	setCursorAlpha(255)
end

function GUICursor:load()
	-- Hide the old cursor
	setCursorAlpha(0)

	-- Draw a new
	addEventHandler("onClientRender", root, GUICursor.draw)
end

function GUICursor.draw()
	local cursorX, cursorY = getCursorPosition()
	if cursorX then
		cursorX, cursorY = cursorX*screenWidth, cursorY*screenHeight
		dxDrawImage(cursorX, cursorY, 12, 20, "files/images/GUI/Cursor.png", 0, 0, 0, Color.White, true)
	end
end
