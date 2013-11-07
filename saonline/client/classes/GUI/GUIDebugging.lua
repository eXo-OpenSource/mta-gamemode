-- ****************************************************************************
-- *
-- *  PROJECT:     Open MTA:DayZ
-- *  FILE:        client/classes/GUI/GUIDebugging.lua
-- *  PURPOSE:     GUI debugging class
-- *
-- ****************************************************************************

if DEBUG then

GUIDebugging = inherit(Object)

function GUIDebugging.constructor()
	addEventHandler("onClientRender", root, GUIDebugging.draw)
end

function GUIDebugging.draw()
	local cursorX, cursorY = getCursorPosition()
	if cursorX then
		cursorX, cursorY = cursorX*screenWidth, cursorY*screenHeight
		dxDrawText("X: "..math.floor(cursorX).." Y: "..math.floor(cursorY), screenWidth-200, 10, nil, nil, Color.White, 2)
	end
end


end
