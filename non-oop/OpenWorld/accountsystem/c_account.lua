function onClientStart ()
	triggerServerEvent( "onPlayerReadyToPlay", getLocalPlayer() )
end
addEventHandler( "onClientResourceStart", getResourceRootElement(), onClientStart )

selectedchar = 0


gtaonlinefont = {
	[30] = dxCreateFont("gtafont.ttf", 30)
	[23] = dxCreateFont("gtafont.ttf", 23)
	[12] = dxCreateFont("gtafont.ttf", 12)
	[15] = dxCreateFont("gtafont.ttf", 15)
	[120] = dxCreateFont("gtafont.ttf", 120)
	[50] = dxCreateFont("gtafont.ttf", 50)
}


function isCursorOnElement(x,y,w,h)
	local mx,my = getCursorPosition ()
	local fullx,fully = guiGetScreenSize()
	cursorx,cursory = mx*fullx,my*fully
	if cursorx > x and cursorx < x + w and cursory > y and cursory < y + h then
		return true
	else
		return false
	end
end


function asdfler()
	local screenW, screenH = guiGetScreenSize()
	showCursor(true)
	addEventHandler("onClientRender", root, mainmenu_home)
	addEventHandler("onClientClick",getRootElement(), function(button,state)
		if (button == "left" and state == "down") and check_mainmenu_login == true then 
			removeEventHandler("onClientRender", root, mainmenu_home)
			removeEventHandler("onClientRender", root, mainmenu_login)
			removeEventHandler("onClientRender", root, mainmenu_register)
			addEventHandler("onClientRender", root, mainmenu_login)
			if isElement(login_username_edit) and isElement(login_passwort_edit) then
				destroyElement(login_username_edit)
				destroyElement(login_passwort_edit)
			end
			login_username_edit = guiCreateEdit(screenW*(546/1600), screenH*(375/900), screenW*(345/1600), screenH*(28/900), "", false)
			login_passwort_edit = guiCreateEdit(screenW*(546/1600), screenH*(413/900), screenW*(345/1600), screenH*(28/900), "", false)   
		else
			if (button == "left" and state == "down") and check_mainmenu_login_btn == true then
				triggerServerEvent("loginMySQL", getLocalPlayer(), getLocalPlayer(), guiGetText(login_username_edit), guiGetText(login_passwort_edit))
			else
				if (button == "left" and state == "down") and check_mainmenu_register == true then
					removeEventHandler("onClientRender", root, mainmenu_home)
					removeEventHandler("onClientRender", root, mainmenu_login)
					removeEventHandler("onClientRender", root, mainmenu_register)
					addEventHandler("onClientRender", root, mainmenu_register)
					if isElement(login_username_edit) and isElement(login_passwort_edit) then
						destroyElement(login_username_edit)
						destroyElement(login_passwort_edit)
					end
				else
					if (button == "left" and state == "down") and check_mainmenu_main == true then
						removeEventHandler("onClientRender", root, mainmenu_home)
						removeEventHandler("onClientRender", root, mainmenu_login)
						removeEventHandler("onClientRender", root, mainmenu_register)
						addEventHandler("onClientRender", root, mainmenu_home)
						if isElement(login_username_edit) and isElement(login_passwort_edit) then
							destroyElement(login_username_edit)
							destroyElement(login_passwort_edit)
						end
					end
				end
			end
		end
	end)
end
addCommandHandler("rendern", asdfler)



function playerIsLoggedIn()
	local cj = createPed(0, 2060.1001, -1694.5+0.2, 13.6)
	--setPedRotation(cj, 270.001)
	setPedRotation(cj, 250)
	showCursor(true)
	--setCameraMatrix(2064.3740234375,-1695.8896484375,13.546875,2063.3740234375,-1695.8896484375,13.546875,0,70)
	setCameraMatrix(2064.3740234375,-1695.8896484375,13.546875,2063.3740234375,-1695.8896484375,13.546875+0.05,0,70)
	check_mainmenu_login_btn = nil
	check_mainmenu_register = nil
	check_mainmenu_main = nil
	check_mainmenu_login = nil
	removeEventHandler("onClientRender", root, mainmenu_home)
	removeEventHandler("onClientRender", root, mainmenu_login)
	removeEventHandler("onClientRender", root, mainmenu_register)
	if isElement(login_username_edit) and isElement(login_passwort_edit) then
		destroyElement(login_username_edit)
		destroyElement(login_passwort_edit)
	end
	--playerusername = username
	addEventHandler("onClientRender", root, accmenu_heritage)
	addEventHandler("onClientClick",getRootElement(), function(button,state)
		if (button == "left" and state == "down") and check_accmenu_heritage == true then 
			outputChatBox("Hier kommt Heritage hin.", 255, 0, 0)
			removeEventHandler("onClientRender", root, accmenu_heritage)
			removeEventHandler("onClientRender", root, accmenu_appearance)
			removeEventHandler("onClientRender", root, accmenu_lifestyle) 
			addEventHandler("onClientRender", root, accmenu_heritage)
		else
			if (button == "left" and state == "down") and check_accmenu_lifestyle == true then
				outputChatBox("Hier kommt Lifestyle hin.", 255, 0, 0)
				removeEventHandler("onClientRender", root, accmenu_heritage)
				removeEventHandler("onClientRender", root, accmenu_appearance)
				removeEventHandler("onClientRender", root, accmenu_lifestyle)
				addEventHandler("onClientRender", root, accmenu_lifestyle)
			else
				if (button == "left" and state == "down") and check_accmenu_appearance == true then
					outputChatBox("Hier kommt Appearance hin.", 255, 0, 0)
					removeEventHandler("onClientRender", root, accmenu_heritage)
					removeEventHandler("onClientRender", root, accmenu_appearance)
					removeEventHandler("onClientRender", root, accmenu_lifestyle)
					addEventHandler("onClientRender", root, accmenu_appearance)
				else
					if (button == "left" and state == "down") and check_accmenu_letsgo == true then
						outputChatBox("Ab in die Open World.", 255, 0, 0)
						showCursor(false)
						removeEventHandler("onClientRender", root, accmenu_heritage)
						removeEventHandler("onClientRender", root, accmenu_appearance)
						removeEventHandler("onClientRender", root, accmenu_lifestyle)
						check_accmenu_heritage = nil
						check_accmenu_lifestyle = nil
						check_accmenu_appearance = nil
						check_accmenu_letsgo = nil
						setCameraTarget(getLocalPlayer())
					end
				end
			end
		end
	end)
end
-- addEvent("pili", true)
-- addEventHandler("pili", root, playerIsLoggedIn)
addCommandHandler("rendern123", playerIsLoggedIn)

function render_charsel(username, char1_level, char1_fahren, char1_schiessen, char1_fliegen, char1_schleichen, char1_ausdauer, char2_level, char2_fahren, char2_schiessen, char2_fliegen, char2_schleichen, char2_ausdauer)
	check_mainmenu_login_btn = nil
	check_mainmenu_register = nil
	check_mainmenu_main = nil
	check_mainmenu_login = nil
	bindKey( "enter", "down", char_selected)
	removeEventHandler("onClientRender", root, mainmenu_home)
	removeEventHandler("onClientRender", root, mainmenu_login)
	removeEventHandler("onClientRender", root, mainmenu_register)
	if isElement(login_username_edit) and isElement(login_passwort_edit) then
		destroyElement(login_username_edit)
		destroyElement(login_passwort_edit)
	end
	--outputChatBox(username.."|"..char1_level.."|"..char1_fahren.."|"..char1_schiessen.."|"..char1_fliegen.."|"..char1_schleichen.."|"..char1_ausdauer, 255, 0, 0)
	showCursor(true)
	playerusername = username
	-- Charakter1
	char1_level1 = char1_level
	char1_fahren1 = char1_fahren
	char1_schiessen1 = char1_schiessen
	char1_fliegen1 = char1_fliegen
	char1_schleichen1 = char1_schleichen
	char1_ausdauer1 = char1_ausdauer
	
	-- Charakter2
	char2_level1 = char2_level
	char2_fahren1 = char2_fahren
	char2_schiessen1 = char2_schiessen
	char2_fliegen1 = char2_fliegen
	char2_schleichen1 = char2_schleichen
	char2_ausdauer1 = char2_ausdauer
	
	addEventHandler("onClientRender", root, charselmenu_1)
	addEventHandler("onClientClick",getRootElement(), function(button,state)
		if (button == "left" and state == "down") and check_charselmenu1 == true then 
			removeEventHandler("onClientRender", root, charselmenu_1)
			addEventHandler("onClientRender", root, charselmenu_2)
			selectedchar = 2
		else
			if (button == "left" and state == "down") and check_charselmenu2 == true then 
				removeEventHandler("onClientRender", root, charselmenu_2)
				addEventHandler("onClientRender", root, charselmenu_1)
				selectedchar = 1
			end
		end
	end)
end
addEvent("pili", true)
addEventHandler("pili", root, render_charsel)
--addCommandHandler("carsel", render_charsel)

-- function playerPressedKey(button, press)
	-- if button == "enter" and press then
		-- outputChatBox("You pressed the "..button.." key!")
	-- end
-- end
-- addEventHandler("onClientKey", root, playerPressedKey)

function char_selected()
	unbindKey( "enter", "down", char_selected)
	check_charselmenu1 = nil
	check_charselmenu2 = nil
	if selectedchar == 1 then
		removeEventHandler("onClientRender", root, charselmenu_1)
		removeEventHandler("onClientRender", root, charselmenu_2)
		playerIsLoggedIn()
	else
		removeEventHandler("onClientRender", root, charselmenu_1)
		removeEventHandler("onClientRender", root, charselmenu_2)
		playerIsLoggedIn()
	end
end




function dsasds()
	

end

function charselmenu_1()
	local screenW, screenH = guiGetScreenSize()
	dxDrawImage((screenW - screenW) / 2, (screenH - screenH) / 2, screenW, screenH, "colors/db.png", 0, 0, 0, tocolor(255, 255, 255, 255), false)
	dxDrawRectangle(screenW*(125/1600), screenH*(37/900), screenW*(1350/1600), screenH*(187/900), tocolor(0, 0, 0, 170), false)
	dxDrawText("GTA:SA ONLINE", screenW*(148/1600), screenH*(74/900), screenW*(387/1600), screenH*(106/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont, "left", "top", false, false, true, false, false)
	dxDrawImage(screenW*(1380/1600), screenH*(47/900), screenW*(85/1600), screenH*(85/900), "avatar-default.png", 0, 0, 0, tocolor(255, 255, 255, 255), true)
	dxDrawText(playerusername, screenW*(1131/1600), screenH*(47/900), screenW*(1370/1600), screenH*(75/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont2, "right", "center", false, false, true, false, false)
	dxDrawText("Serverleitung", screenW*(1131/1600), screenH*(75/900), screenW*(1370/1600), screenH*(103/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont2, "right", "center", false, false, true, false, false)
	dxDrawText("BANK $10000    CASH $500", screenW*(1131/1600), screenH*(103/900), screenW*(1370/1600), screenH*(131/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont2, "right", "center", false, false, true, false, false)
	
	
	dxDrawRectangle(screenW*(125/1600), screenH*(174/900), screenW*(450/1600), screenH*(5/900), tocolor(19, 64, 121, 255), false)
	dxDrawRectangle(screenW*(125/1600), screenH*(234/900), screenW*(217/1600), screenH*(616/900), tocolor(0, 0, 0, 255), false)
	dxDrawRectangle(screenW*(125/1600), screenH*(179/900), screenW*(450/1600), screenH*(45/900), tocolor(255, 255, 255, 255), false)
	dxDrawText("Verfügbar", screenW*(125/1600), screenH*(179/900), screenW*(575/1600), screenH*(224/900), tocolor(0, 0, 0, 255), 1.00, gtaonlinefont1, "center", "center", false, false, true, false, false)
	dxDrawText("Verfügbar", screenW*(575/1600), screenH*(179/900), screenW*(800/1600), screenH*(224/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont1, "center", "center", false, false, true, false, false)
	dxDrawText("Gesperrt", screenW*(800/1600), screenH*(179/900), screenW*(1025/1600), screenH*(224/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont1, "center", "center", false, false, true, false, false)
	dxDrawText("Gesperrt", screenW*(1025/1600), screenH*(179/900), screenW*(1250/1600), screenH*(224/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont1, "center", "center", false, false, true, false, false)
	dxDrawText("Gesperrt", screenW*(1250/1600), screenH*(179/900), screenW*(1475/1600), screenH*(224/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont1, "center", "center", false, false, true, false, false)
	dxDrawRectangle(screenW*(575/1600), screenH*(234/900), screenW*(225/1600), screenH*(616/900), tocolor(0, 0, 0, 255), false)
	dxDrawRectangle(screenW*(800/1600), screenH*(234/900), screenW*(225/1600), screenH*(616/900), tocolor(0, 0, 0, 170), false)
	dxDrawRectangle(screenW*(1025/1600), screenH*(234/900), screenW*(225/1600), screenH*(616/900), tocolor(0, 0, 0, 170), false)
	dxDrawRectangle(screenW*(1250/1600), screenH*(234/900), screenW*(225/1600), screenH*(616/900), tocolor(0, 0, 0, 170), false)
	dxDrawRectangle(screenW*(346/1600), screenH*(234/900), screenW*(225/1600), screenH*(567/900), tocolor(0, 0, 0, 255), false)
	dxDrawText("1", screenW*(135/1600), screenH*(244/900), screenW*(298/1600), screenH*(634/900), tocolor(32, 35, 40, 255), 1.00, gtaonlinefont4, "left", "top", false, false, true, false, false)
	dxDrawRectangle(screenW*(346/1600), screenH*(234/900), screenW*(225/1600), screenH*(34/900), tocolor(4, 78, 153, 255), false)
	dxDrawText(playerusername, screenW*(346/1600), screenH*(234/900), screenW*(571/1600), screenH*(268/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont2, "center", "center", false, false, true, false, false)
	
	-- LEVEL
	dxDrawImage(screenW*(415/1600), screenH*(278/900), screenW*(95/1600), screenH*(95/900), "world.png", 0, 0, 0, tocolor(255, 255, 255, 255), false)
	dxDrawText(char1_level1, screenW*(415/1600), screenH*(278/900), screenW*(505/1600), screenH*(373/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont5, "center", "center", false, false, true, false, false)
	
	
	dxDrawText("Fahren", screenW*(356/1600), screenH*(396/900), screenW*(561/1600), screenH*(424/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont2, "left", "center", false, false, true, false, false)
	dxDrawText("Schießen", screenW*(356/1600), screenH*(459/900), screenW*(561/1600), screenH*(487/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont2, "left", "center", false, false, true, false, false)
	dxDrawText("Fliegen", screenW*(356/1600), screenH*(522/900), screenW*(561/1600), screenH*(550/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont2, "left", "center", false, false, true, false, false)
	dxDrawText("Schleichen", screenW*(356/1600), screenH*(585/900), screenW*(561/1600), screenH*(613/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont2, "left", "center", false, false, true, false, false)
	dxDrawText("Ausdauer", screenW*(356/1600), screenH*(651/900), screenW*(561/1600), screenH*(679/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont2, "left", "center", false, false, true, false, false)
	dxDrawText("Gerätezugang", screenW*(356/1600), screenH*(725/900), screenW*(561/1600), screenH*(753/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont2, "left", "center", false, false, true, false, false)
	dxDrawRectangle(screenW*(356/1600), screenH*(434/900), screenW*(205/1600), screenH*(15/900), tocolor(12, 25, 42, 255), true)
	dxDrawRectangle(screenW*(356/1600), screenH*(497/900), screenW*(205/1600), screenH*(15/900), tocolor(12, 25, 42, 255), true)
	dxDrawRectangle(screenW*(356/1600), screenH*(560/900), screenW*(205/1600), screenH*(15/900), tocolor(12, 25, 42, 255), true)
	dxDrawRectangle(screenW*(356/1600), screenH*(624/900), screenW*(205/1600), screenH*(15/900), tocolor(12, 25, 42, 255), true)
	dxDrawRectangle(screenW*(356/1600), screenH*(689/900), screenW*(205/1600), screenH*(15/900), tocolor(12, 25, 42, 255), true)
	
	local prozent = (205/100)
	local fahrenwert = prozent*char1_fahren1  -- Höchste = 252
	local schiessenwert = prozent*char1_schiessen1
	local fliegenwert = prozent*char1_fliegen1
	local schleichenwert = prozent*char1_schleichen1
	local ausdauerwert = prozent*char1_ausdauer1
	dxDrawRectangle(screenW*(356/1600), screenH*(434/900), screenW*(fahrenwert/1600), screenH*(15/900), tocolor(23, 76, 133, 255), true)
	dxDrawRectangle(screenW*(356/1600), screenH*(497/900), screenW*(schiessenwert/1600), screenH*(15/900), tocolor(23, 76, 133, 255), true)
	dxDrawRectangle(screenW*(356/1600), screenH*(560/900), screenW*(fliegenwert/1600), screenH*(15/900), tocolor(23, 76, 133, 255), true)
	dxDrawRectangle(screenW*(356/1600), screenH*(624/900), screenW*(schleichenwert/1600), screenH*(15/900), tocolor(23, 76, 133, 255), true)
	dxDrawRectangle(screenW*(356/1600), screenH*(689/900), screenW*(ausdauerwert/1600), screenH*(15/900), tocolor(23, 76, 133, 255), true)
	
	
	dxDrawImage(screenW*(356/1600), screenH*(763/900), screenW*(24/1600), screenH*(24/900), "cross.png", 0, 0, 0, tocolor(255, 255, 255, 255), true)
	dxDrawImage(screenW*(390/1600), screenH*(763/900), screenW*(24/1600), screenH*(24/900), "cross.png", 0, 0, 0, tocolor(255, 255, 255, 255), true)
	dxDrawImage(screenW*(424/1600), screenH*(763/900), screenW*(24/1600), screenH*(24/900), "cross.png", 0, 0, 0, tocolor(255, 255, 255, 255), true)
	dxDrawImage(screenW*(458/1600), screenH*(763/900), screenW*(24/1600), screenH*(24/900), "cross.png", 0, 0, 0, tocolor(255, 255, 255, 255), true)
	dxDrawText("2", screenW*(585/1600), screenH*(244/900), screenW*(748/1600), screenH*(634/900), tocolor(7, 7, 7, 255), 1.00, gtaonlinefont4, "left", "top", false, false, true, false, false)
	dxDrawText("3", screenW*(810/1600), screenH*(244/900), screenW*(973/1600), screenH*(634/900), tocolor(0, 0, 0, 100), 1.00, gtaonlinefont4, "left", "top", false, false, true, false, false)
	dxDrawText("4", screenW*(1035/1600), screenH*(244/900), screenW*(1198/1600), screenH*(634/900), tocolor(0, 0, 0, 100), 1.00, gtaonlinefont4, "left", "top", false, false, true, false, false)
	dxDrawText("5", screenW*(1260/1600), screenH*(244/900), screenW*(1423/1600), screenH*(634/900), tocolor(0, 0, 0, 100), 1.00, gtaonlinefont4, "left", "top", false, false, true, false, false)
	
	dxDrawRectangle(screenW*(1084/1600), screenH*(860/900), screenW*(391/1600), screenH*(31/900), tocolor(0, 0, 0, 170), true)
    dxDrawText("Drücke 'ENTER' um fortzufahren", screenW*(1084/1600), screenH*(860/900), screenW*(1475/1600), screenH*(890/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont2, "center", "center", false, false, true, false, false)
	
	
	check_charselmenu1 = isCursorOnElement(screenW*(575/1600), screenH*(179/900), screenW*(800/1600), screenH*(224/900))
	check_charselmenu2 = isCursorOnElement(screenW*(125/1600), screenH*(179/900), screenW*(350/1600), screenH*(224/900))
end


function charselmenu_2()
	local screenW, screenH = guiGetScreenSize()
	dxDrawImage((screenW - screenW) / 2, (screenH - screenH) / 2, screenW, screenH, "colors/db.png", 0, 0, 0, tocolor(255, 255, 255, 255), false)
	dxDrawRectangle(screenW*(125/1600), screenH*(37/900), screenW*(1350/1600), screenH*(187/900), tocolor(0, 0, 0, 170), false)
	dxDrawText("GTA:SA ONLINE", screenW*(148/1600), screenH*(74/900), screenW*(387/1600), screenH*(106/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont, "left", "top", false, false, true, false, false)
	dxDrawImage(screenW*(1380/1600), screenH*(47/900), screenW*(85/1600), screenH*(85/900), "avatar-default.png", 0, 0, 0, tocolor(255, 255, 255, 255), true)
	
	dxDrawText(playerusername, screenW*(1131/1600), screenH*(47/900), screenW*(1370/1600), screenH*(75/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont2, "right", "center", false, false, true, false, false)
	dxDrawText("Serverleitung", screenW*(1131/1600), screenH*(75/900), screenW*(1370/1600), screenH*(103/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont2, "right", "center", false, false, true, false, false)
	dxDrawText("BANK $10000    CASH $500", screenW*(1131/1600), screenH*(103/900), screenW*(1370/1600), screenH*(131/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont2, "right", "center", false, false, true, false, false)
	dxDrawRectangle(screenW*(350/1600), screenH*(174/900), screenW*(450/1600), screenH*(5/900), tocolor(19, 64, 121, 255), false)
	dxDrawRectangle(screenW*(125/1600), screenH*(234/900), screenW*(225/1600), screenH*(616/900), tocolor(0, 0, 0, 255), false)
	dxDrawRectangle(screenW*(350/1600), screenH*(179/900), screenW*(450/1600), screenH*(45/900), tocolor(255, 255, 255, 255), false)
	
	
	
	
	dxDrawText("Verfügbar", screenW*(125/1600), screenH*(179/900), screenW*(350/1600), screenH*(224/900), tocolor(253, 253, 253, 255), 1.00, gtaonlinefont1, "center", "center", false, false, true, false, false)
	dxDrawText("Verfügbar", screenW*(350/1600), screenH*(179/900), screenW*(800/1600), screenH*(224/900), tocolor(0, 0, 0, 255), 1.00, gtaonlinefont1, "center", "center", false, false, true, false, false)
	dxDrawText("Gesperrt", screenW*(800/1600), screenH*(179/900), screenW*(1025/1600), screenH*(224/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont1, "center", "center", false, false, true, false, false)
	dxDrawText("Gesperrt", screenW*(1025/1600), screenH*(179/900), screenW*(1250/1600), screenH*(224/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont1, "center", "center", false, false, true, false, false)
	dxDrawText("Gesperrt", screenW*(1250/1600), screenH*(179/900), screenW*(1475/1600), screenH*(224/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont1, "center", "center", false, false, true, false, false)
	dxDrawRectangle(screenW*(800/1600), screenH*(234/900), screenW*(225/1600), screenH*(616/900), tocolor(0, 0, 0, 170), false)
	dxDrawRectangle(screenW*(1025/1600), screenH*(234/900), screenW*(225/1600), screenH*(616/900), tocolor(0, 0, 0, 170), false)
	dxDrawRectangle(screenW*(1250/1600), screenH*(234/900), screenW*(225/1600), screenH*(616/900), tocolor(0, 0, 0, 170), false)
	dxDrawRectangle(screenW*(571/1600), screenH*(234/900), screenW*(225/1600), screenH*(567/900), tocolor(0, 0, 0, 255), false)
	dxDrawText("1", screenW*(135/1600), screenH*(244/900), screenW*(298/1600), screenH*(634/900), tocolor(7, 7, 7, 255), 1.00, gtaonlinefont4, "left", "top", false, false, true, false, false)
	dxDrawRectangle(screenW*(571/1600), screenH*(234/900), screenW*(225/1600), screenH*(34/900), tocolor(4, 78, 153, 255), false)
	dxDrawText(playerusername, screenW*(571/1600), screenH*(234/900), screenW*(796/1600), screenH*(268/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont2, "center", "center", false, false, true, false, false)
	
	-- LEVEL
	dxDrawImage(screenW*(636/1600), screenH*(278/900), screenW*(95/1600), screenH*(95/900), "world.png", 0, 0, 0, tocolor(255, 255, 255, 255), false)
	dxDrawText(char2_level1, screenW*(636/1600), screenH*(278/900), screenW*(726/1600), screenH*(373/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont5, "center", "center", false, false, true, false, false)
	
	-- Skills
	dxDrawText("Fahren", screenW*(581/1600), screenH*(396/900), screenW*(786/1600), screenH*(424/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont2, "left", "center", false, false, true, false, false)
	dxDrawText("Schießen", screenW*(581/1600), screenH*(459/900), screenW*(786/1600), screenH*(487/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont2, "left", "center", false, false, true, false, false)
	dxDrawText("Fliegen", screenW*(581/1600), screenH*(522/900), screenW*(786/1600), screenH*(550/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont2, "left", "center", false, false, true, false, false)
	dxDrawText("Schleichen", screenW*(581/1600), screenH*(585/900), screenW*(786/1600), screenH*(613/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont2, "left", "center", false, false, true, false, false)
	dxDrawText("Ausdauer", screenW*(581/1600), screenH*(651/900), screenW*(786/1600), screenH*(679/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont2, "left", "center", false, false, true, false, false)
	dxDrawText("Gerätezugang", screenW*(581/1600), screenH*(725/900), screenW*(786/1600), screenH*(753/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont2, "left", "center", false, false, true, false, false)
	dxDrawRectangle(screenW*(581/1600), screenH*(434/900), screenW*(205/1600), screenH*(15/900), tocolor(12, 25, 42, 255), true)
	dxDrawRectangle(screenW*(581/1600), screenH*(497/900), screenW*(205/1600), screenH*(15/900), tocolor(12, 25, 42, 255), true)
	dxDrawRectangle(screenW*(581/1600), screenH*(560/900), screenW*(205/1600), screenH*(15/900), tocolor(12, 25, 42, 255), true)
	dxDrawRectangle(screenW*(581/1600), screenH*(623/900), screenW*(205/1600), screenH*(15/900), tocolor(12, 25, 42, 255), true)
	dxDrawRectangle(screenW*(581/1600), screenH*(689/900), screenW*(205/1600), screenH*(15/900), tocolor(12, 25, 42, 255), true)
	
	local prozent = (205/100)
	local fahrenwert = prozent*char2_fahren1  -- Höchste = 252
	local schiessenwert = prozent*char2_schiessen1
	local fliegenwert = prozent*char2_fliegen1
	local schleichenwert = prozent*char2_schleichen1
	local ausdauerwert = prozent*char2_ausdauer1
	dxDrawRectangle(screenW*(581/1600), screenH*(434/900), screenW*(fahrenwert/1600), screenH*(15/900), tocolor(23, 76, 133, 255), true)
	dxDrawRectangle(screenW*(581/1600), screenH*(497/900), screenW*(schiessenwert/1600), screenH*(15/900), tocolor(23, 76, 133, 255), true)
	dxDrawRectangle(screenW*(581/1600), screenH*(560/900), screenW*(fliegenwert/1600), screenH*(15/900), tocolor(23, 76, 133, 255), true)
	dxDrawRectangle(screenW*(581/1600), screenH*(623/900), screenW*(schleichenwert/1600), screenH*(15/900), tocolor(23, 76, 133, 255), true)
	dxDrawRectangle(screenW*(581/1600), screenH*(689/900), screenW*(ausdauerwert/1600), screenH*(15/900), tocolor(23, 76, 133, 255), true)
	
	
	
	
	
	dxDrawImage(screenW*(581/1600), screenH*(763/900), screenW*(24/1600), screenH*(24/900), "cross.png", 0, 0, 0, tocolor(255, 255, 255, 255), true)
	dxDrawImage(screenW*(615/1600), screenH*(763/900), screenW*(24/1600), screenH*(24/900), "cross.png", 0, 0, 0, tocolor(255, 255, 255, 255), true)
	dxDrawImage(screenW*(649/1600), screenH*(763/900), screenW*(24/1600), screenH*(24/900), "cross.png", 0, 0, 0, tocolor(255, 255, 255, 255), true)
	dxDrawImage(screenW*(683/1600), screenH*(763/900), screenW*(24/1600), screenH*(24/900), "cross.png", 0, 0, 0, tocolor(255, 255, 255, 255), true)
	dxDrawText("3", screenW*(810/1600), screenH*(244/900), screenW*(973/1600), screenH*(634/900), tocolor(0, 0, 0, 100), 1.00, gtaonlinefont4, "left", "top", false, false, true, false, false)
	dxDrawText("4", screenW*(1035/1600), screenH*(244/900), screenW*(1198/1600), screenH*(634/900), tocolor(0, 0, 0, 100), 1.00, gtaonlinefont4, "left", "top", false, false, true, false, false)
	dxDrawText("5", screenW*(1260/1600), screenH*(244/900), screenW*(1423/1600), screenH*(634/900), tocolor(0, 0, 0, 100), 1.00, gtaonlinefont4, "left", "top", false, false, true, false, false)
	dxDrawRectangle(screenW*(354/1600), screenH*(234/900), screenW*(213/1600), screenH*(616/900), tocolor(0, 0, 0, 255), false)
	dxDrawText("2", screenW*(364/1600), screenH*(244/900), screenW*(527/1600), screenH*(634/900), tocolor(32, 35, 40, 255), 1.00, gtaonlinefont4, "left", "top", false, false, true, false, false)
	
	dxDrawRectangle(screenW*(1084/1600), screenH*(860/900), screenW*(391/1600), screenH*(31/900), tocolor(0, 0, 0, 170), true)
    dxDrawText("Drücke 'ENTER' um fortzufahren", screenW*(1084/1600), screenH*(860/900), screenW*(1475/1600), screenH*(890/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont2, "center", "center", false, false, true, false, false)
	
	
	check_charselmenu1 = isCursorOnElement(screenW*(575/1600), screenH*(179/900), screenW*(800/1600), screenH*(224/900))
	check_charselmenu2 = isCursorOnElement(screenW*(125/1600), screenH*(179/900), screenW*(350/1600), screenH*(224/900))
end


function accmenu_heritage()
	local screenW, screenH = guiGetScreenSize()
	dxDrawImage(screenW*(0/1600), screenH*(0/900), screenW*(1025/1600), screenH*(900/900), "colors/db.png", 0, 0, 0, tocolor(255, 255, 255, 255), false)
	dxDrawImage(screenW*(1475/1600), screenH*(0/900), screenW*(125/1600), screenH*(900/900), "colors/db.png", 0, 0, 0, tocolor(255, 255, 255, 255), false)
    dxDrawImage(screenW*(1025/1600), screenH*(0/900), screenW*(450/1600), screenH*(234/900), "colors/db.png", 0, 0, 0, tocolor(255, 255, 255, 255), false)
    dxDrawImage(screenW*(1025/1600), screenH*(850/900), screenW*(450/1600), screenH*(50/900), "colors/db.png", 0, 0, 0, tocolor(255, 255, 255, 255), false)

	dxDrawRectangle(screenW*(125/1600), screenH*(37/900), screenW*(1350/1600), screenH*(187/900), tocolor(0, 0, 0, 190), false)
	dxDrawText("GTA:SA ONLINE", screenW*(148/1600), screenH*(74/900), screenW*(387/1600), screenH*(106/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont, "left", "top", false, false, true, false, false)
	dxDrawImage(screenW*(1380/1600), screenH*(47/900), screenW*(85/1600), screenH*(85/900), "avatar-default.png", 0, 0, 0, tocolor(255, 255, 255, 255), true)
	dxDrawText(playerusername, screenW*(1131/1600), screenH*(47/900), screenW*(1370/1600), screenH*(75/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont2, "right", "center", false, false, true, false, false)
	dxDrawText("Serverleitung", screenW*(1131/1600), screenH*(75/900), screenW*(1370/1600), screenH*(103/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont2, "right", "center", false, false, true, false, false)
	dxDrawText("BANK $10000    CASH $500", screenW*(1131/1600), screenH*(103/900), screenW*(1370/1600), screenH*(131/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont2, "right", "center", false, false, true, false, false)
	dxDrawText("Options", screenW*(125/1600), screenH*(179/900), screenW*(575/1600), screenH*(224/900), tocolor(0, 0, 0, 255), 1.00, gtaonlinefont1, "center", "center", false, false, true, false, false)
	dxDrawText("Details", screenW*(575/1600), screenH*(179/900), screenW*(1025/1600), screenH*(224/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont1, "center", "center", false, false, true, false, false)
	dxDrawText("You", screenW*(1025/1600), screenH*(179/900), screenW*(1475/1600), screenH*(224/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont1, "center", "center", false, false, true, false, false)
	
	-- Jetzige Auswahl --
	dxDrawRectangle(screenW*(125/1600), screenH*(174/900), screenW*(450/1600), screenH*(5/900), tocolor(19, 64, 121, 255), false)
	-- Jetzige Auswahl --
	
	dxDrawRectangle(screenW*(125/1600), screenH*(234/900), screenW*(900/1600), screenH*(616/900), tocolor(0, 0, 0, 170), false)
	dxDrawRectangle(screenW*(1025/1600), screenH*(234/900), screenW*(450/1600), screenH*(616/900), tocolor(0, 0, 0, 102), false)

	-- Jetzige Auswahl --
	dxDrawRectangle(screenW*(125/1600), screenH*(179/900), screenW*(450/1600), screenH*(45/900), tocolor(255, 255, 255, 255), false)
	-- Jetzige Auswahl --
	
	
	-- Jetzige Auswahl --
	dxDrawRectangle(screenW*(125/1600), screenH*(234/900), screenW*(450/1600), screenH*(37/900), tocolor(255, 255, 255, 255), false)
	

	dxDrawText("Heritage", screenW*(135/1600), screenH*(234/900), screenW*(575/1600), screenH*(271/900), tocolor(0, 0, 0, 255), 1.00, gtaonlinefont2, "left", "center", false, false, true, false, false)
	dxDrawText("Lifestyle", screenW*(135/1600), screenH*(271/900), screenW*(575/1600), screenH*(308/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont2, "left", "center", false, false, true, false, false)
	dxDrawText("Appearance", screenW*(135/1600), screenH*(308/900), screenW*(575/1600), screenH*(345/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont2, "left", "center", false, false, true, false, false)
	dxDrawRectangle(screenW*(125/1600), screenH*(345/900), screenW*(450/1600), screenH*(37/900), tocolor(0, 24, 51, 255), false)
	dxDrawText("Speichern & Fortfahren", screenW*(135/1600), screenH*(345/900), screenW*(575/1600), screenH*(382/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont2, "left", "center", false, false, true, false, false)
	dxDrawRectangle(screenW*(125/1600), screenH*(382/900), screenW*(450/1600), screenH*(5/900), tocolor(255, 255, 255, 255), true)
	dxDrawText("Wie viel Zeit verbringst du mit den Lebensstyle Optionen auf der rechten Seite?", screenW*(135/1600), screenH*(397/900), screenW*(533/1600), screenH*(493/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont2, "left", "top", false, true, true, false, false)
	dxDrawImage(screenW*(543/1600), screenH*(397/900), screenW*(32/1600), screenH*(32/900), "cross.png", 0, 0, 0, tocolor(255, 255, 255, 255), true)
	
	dxDrawText("Verbringe 24 Stunden mit deinem Charakter und du deine Werte werden sich verändern und du kannst deinen Charakter nach deinen Wünschen designen.", screenW*(135/1600), screenH*(493/900), screenW*(533/1600), screenH*(571/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont2, "left", "top", false, true, true, false, false)
	dxDrawText("Stamina", screenW*(135/1600), screenH*(581/900), screenW*(316/1600), screenH*(618/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont2, "left", "center", false, false, true, false, false)
	dxDrawText("Shooting", screenW*(135/1600), screenH*(618/900), screenW*(316/1600), screenH*(655/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont2, "left", "center", false, false, true, false, false)
	dxDrawText("Stealth", screenW*(135/1600), screenH*(692/900), screenW*(316/1600), screenH*(729/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont2, "left", "center", false, false, true, false, false)
	dxDrawText("Strength", screenW*(135/1600), screenH*(655/900), screenW*(316/1600), screenH*(692/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont2, "left", "center", false, false, true, false, false)
	dxDrawText("Flying", screenW*(135/1600), screenH*(729/900), screenW*(316/1600), screenH*(766/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont2, "left", "center", false, false, true, false, false)
	dxDrawText("Driving", screenW*(135/1600), screenH*(766/900), screenW*(316/1600), screenH*(803/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont2, "left", "center", false, false, true, false, false)
	dxDrawText("Lung Capacity", screenW*(135/1600), screenH*(803/900), screenW*(316/1600), screenH*(840/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont2, "left", "center", false, false, true, false, false)
	
	-- Hintergrund Werte --
	dxDrawRectangle(screenW*(323/1600), screenH*(593/900), screenW*(252/1600), screenH*(15/900), tocolor(12, 25, 42, 255), true)
	dxDrawRectangle(screenW*(323/1600), screenH*(630/900), screenW*(252/1600), screenH*(15/900), tocolor(12, 25, 42, 255), true)
	dxDrawRectangle(screenW*(323/1600), screenH*(667/900), screenW*(252/1600), screenH*(15/900), tocolor(12, 25, 42, 255), true)
	dxDrawRectangle(screenW*(323/1600), screenH*(704/900), screenW*(252/1600), screenH*(15/900), tocolor(12, 25, 42, 255), true)
	dxDrawRectangle(screenW*(323/1600), screenH*(741/900), screenW*(252/1600), screenH*(15/900), tocolor(12, 25, 42, 255), true)
	dxDrawRectangle(screenW*(323/1600), screenH*(778/900), screenW*(252/1600), screenH*(15/900), tocolor(12, 25, 42, 255), true)
	dxDrawRectangle(screenW*(323/1600), screenH*(815/900), screenW*(252/1600), screenH*(15/900), tocolor(12, 25, 42, 255), true)
	-- Hintergrund Werte --
	
	-- Vordergrund Werte --
	prozent = (252/100)
	if selectedchar == 1 then
		staminawert = prozent*0    -- Höchste = 252
		shootingwert = prozent*char1_schiessen1
		stealthwert = prozent*char1_schleichen1
		strengthwert = prozent*0
		flyingwert = prozent*char1_fliegen1
		drivingwert = prozent*char1_fahren1
		lungwert = prozent*char1_ausdauer1
	else
		staminawert = prozent*0
		shootingwert = prozent*char1_schiessen2
		stealthwert = prozent*char1_schleichen2
		strengthwert = prozent*0
		flyingwert = prozent*char1_fliegen2
		drivingwert = prozent*char1_fahren2
		lungwert = prozent*char1_ausdauer2
	end
	dxDrawRectangle(screenW*(323/1600), screenH*(593/900), screenW*(staminawert/1600), screenH*(15/900), tocolor(23, 76, 133, 255), true)
	dxDrawRectangle(screenW*(323/1600), screenH*(630/900), screenW*(shootingwert/1600), screenH*(15/900), tocolor(23, 76, 133, 255), true)
	dxDrawRectangle(screenW*(323/1600), screenH*(667/900), screenW*(stealthwert/1600), screenH*(15/900), tocolor(23, 76, 133, 255), true)
	dxDrawRectangle(screenW*(323/1600), screenH*(704/900), screenW*(strengthwert/1600), screenH*(15/900), tocolor(23, 76, 133, 255), true)
	dxDrawRectangle(screenW*(323/1600), screenH*(741/900), screenW*(flyingwert/1600), screenH*(15/900), tocolor(23, 76, 133, 255), true)
	dxDrawRectangle(screenW*(323/1600), screenH*(778/900), screenW*(drivingwert/1600), screenH*(15/900), tocolor(23, 76, 133, 255), true)
	dxDrawRectangle(screenW*(323/1600), screenH*(815/900), screenW*(lungwert/1600), screenH*(15/900), tocolor(23, 76, 133, 255), true)
	
	check_accmenu_heritage = isCursorOnElement(screenW*(125/1600), screenH*(234/900), screenW*(450/1600), screenH*(37/900))
	check_accmenu_lifestyle = isCursorOnElement(screenW*(125/1600), screenH*(271/900), screenW*(450/1600), screenH*(37/900))
	check_accmenu_appearance = isCursorOnElement(screenW*(125/1600), screenH*(308/900), screenW*(450/1600), screenH*(37/900))
	check_accmenu_letsgo = isCursorOnElement(screenW*(125/1600), screenH*(345/900), screenW*(450/1600), screenH*(37/900))
end

function accmenu_lifestyle()
	local screenW, screenH = guiGetScreenSize()
	dxDrawImage(screenW*(0/1600), screenH*(0/900), screenW*(1025/1600), screenH*(900/900), "colors/db.png", 0, 0, 0, tocolor(255, 255, 255, 255), false)
	dxDrawImage(screenW*(1475/1600), screenH*(0/900), screenW*(125/1600), screenH*(900/900), "colors/db.png", 0, 0, 0, tocolor(255, 255, 255, 255), false)
    dxDrawImage(screenW*(1025/1600), screenH*(0/900), screenW*(450/1600), screenH*(234/900), "colors/db.png", 0, 0, 0, tocolor(255, 255, 255, 255), false)
    dxDrawImage(screenW*(1025/1600), screenH*(850/900), screenW*(450/1600), screenH*(50/900), "colors/db.png", 0, 0, 0, tocolor(255, 255, 255, 255), false)
	
	dxDrawRectangle(screenW*(125/1600), screenH*(37/900), screenW*(1350/1600), screenH*(187/900), tocolor(0, 0, 0, 170), false)
	dxDrawText("GTA:SA ONLINE", screenW*(148/1600), screenH*(74/900), screenW*(387/1600), screenH*(106/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont, "left", "top", false, false, true, false, false)
	dxDrawImage(screenW*(1380/1600), screenH*(47/900), screenW*(85/1600), screenH*(85/900), "avatar-default.png", 0, 0, 0, tocolor(255, 255, 255, 255), true)
	dxDrawText(playerusername, screenW*(1131/1600), screenH*(47/900), screenW*(1370/1600), screenH*(75/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont2, "right", "center", false, false, true, false, false)
	dxDrawText("Serverleitung", screenW*(1131/1600), screenH*(75/900), screenW*(1370/1600), screenH*(103/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont2, "right", "center", false, false, true, false, false)
	dxDrawText("BANK $10000    CASH $500", screenW*(1131/1600), screenH*(103/900), screenW*(1370/1600), screenH*(131/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont2, "right", "center", false, false, true, false, false)
	dxDrawText("Options", screenW*(125/1600), screenH*(179/900), screenW*(575/1600), screenH*(224/900), tocolor(0, 0, 0, 255), 1.00, gtaonlinefont1, "center", "center", false, false, true, false, false)
	dxDrawText("Details", screenW*(575/1600), screenH*(179/900), screenW*(1025/1600), screenH*(224/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont1, "center", "center", false, false, true, false, false)
	dxDrawText("You", screenW*(1025/1600), screenH*(179/900), screenW*(1475/1600), screenH*(224/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont1, "center", "center", false, false, true, false, false)
	
	-- Jetzige Auswahl --
	dxDrawRectangle(screenW*(125/1600), screenH*(174/900), screenW*(450/1600), screenH*(5/900), tocolor(19, 64, 121, 255), false)
	-- Jetzige Auswahl --
	
	dxDrawRectangle(screenW*(125/1600), screenH*(234/900), screenW*(900/1600), screenH*(616/900), tocolor(0, 0, 0, 170), false)
	dxDrawRectangle(screenW*(1025/1600), screenH*(234/900), screenW*(450/1600), screenH*(616/900), tocolor(0, 0, 0, 102), false)

	-- Jetzige Auswahl --
	dxDrawRectangle(screenW*(125/1600), screenH*(179/900), screenW*(450/1600), screenH*(45/900), tocolor(255, 255, 255, 255), false)
	-- Jetzige Auswahl --
	
	
	-- Jetzige Auswahl --
	dxDrawRectangle(screenW*(125/1600), screenH*(271/900), screenW*(450/1600), screenH*(37/900), tocolor(255, 255, 255, 255), false)

	
	dxDrawText("Heritage", screenW*(135/1600), screenH*(234/900), screenW*(575/1600), screenH*(271/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont2, "left", "center", false, false, true, false, false)
	dxDrawText("Lifestyle", screenW*(135/1600), screenH*(271/900), screenW*(575/1600), screenH*(308/900), tocolor(0, 0, 0, 255), 1.00, gtaonlinefont2, "left", "center", false, false, true, false, false)
	dxDrawText("Appearance", screenW*(135/1600), screenH*(308/900), screenW*(575/1600), screenH*(345/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont2, "left", "center", false, false, true, false, false)
	dxDrawRectangle(screenW*(125/1600), screenH*(345/900), screenW*(450/1600), screenH*(37/900), tocolor(0, 24, 51, 255), false)
	dxDrawText("Speichern & Fortfahren", screenW*(135/1600), screenH*(345/900), screenW*(575/1600), screenH*(382/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont2, "left", "center", false, false, true, false, false)
	dxDrawRectangle(screenW*(125/1600), screenH*(382/900), screenW*(450/1600), screenH*(5/900), tocolor(255, 255, 255, 255), true)
	dxDrawText("Wie viel Zeit verbringst du mit den Lebensstyle Optionen auf der rechten Seite?", screenW*(135/1600), screenH*(397/900), screenW*(533/1600), screenH*(493/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont2, "left", "top", false, true, true, false, false)
	dxDrawImage(screenW*(543/1600), screenH*(397/900), screenW*(32/1600), screenH*(32/900), "cross.png", 0, 0, 0, tocolor(255, 255, 255, 255), true)
	
	dxDrawText("Verbringe 24 Stunden mit deinem Charakter und du deine Werte werden sich verändern und du kannst deinen Charakter nach deinen Wünschen designen.", screenW*(135/1600), screenH*(493/900), screenW*(533/1600), screenH*(571/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont2, "left", "top", false, true, true, false, false)
	dxDrawText("Stamina", screenW*(135/1600), screenH*(581/900), screenW*(316/1600), screenH*(618/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont2, "left", "center", false, false, true, false, false)
	dxDrawText("Shooting", screenW*(135/1600), screenH*(618/900), screenW*(316/1600), screenH*(655/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont2, "left", "center", false, false, true, false, false)
	dxDrawText("Stealth", screenW*(135/1600), screenH*(692/900), screenW*(316/1600), screenH*(729/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont2, "left", "center", false, false, true, false, false)
	dxDrawText("Strength", screenW*(135/1600), screenH*(655/900), screenW*(316/1600), screenH*(692/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont2, "left", "center", false, false, true, false, false)
	dxDrawText("Flying", screenW*(135/1600), screenH*(729/900), screenW*(316/1600), screenH*(766/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont2, "left", "center", false, false, true, false, false)
	dxDrawText("Driving", screenW*(135/1600), screenH*(766/900), screenW*(316/1600), screenH*(803/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont2, "left", "center", false, false, true, false, false)
	dxDrawText("Lung Capacity", screenW*(135/1600), screenH*(803/900), screenW*(316/1600), screenH*(840/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont2, "left", "center", false, false, true, false, false)

	-- Hintergrund Werte --
	dxDrawRectangle(screenW*(323/1600), screenH*(593/900), screenW*(252/1600), screenH*(15/900), tocolor(12, 25, 42, 255), true)
	dxDrawRectangle(screenW*(323/1600), screenH*(630/900), screenW*(252/1600), screenH*(15/900), tocolor(12, 25, 42, 255), true)
	dxDrawRectangle(screenW*(323/1600), screenH*(667/900), screenW*(252/1600), screenH*(15/900), tocolor(12, 25, 42, 255), true)
	dxDrawRectangle(screenW*(323/1600), screenH*(704/900), screenW*(252/1600), screenH*(15/900), tocolor(12, 25, 42, 255), true)
	dxDrawRectangle(screenW*(323/1600), screenH*(741/900), screenW*(252/1600), screenH*(15/900), tocolor(12, 25, 42, 255), true)
	dxDrawRectangle(screenW*(323/1600), screenH*(778/900), screenW*(252/1600), screenH*(15/900), tocolor(12, 25, 42, 255), true)
	dxDrawRectangle(screenW*(323/1600), screenH*(815/900), screenW*(252/1600), screenH*(15/900), tocolor(12, 25, 42, 255), true)
	-- Hintergrund Werte --
	
	-- Vordergrund Werte --
	local prozent = (252/100)
	local staminawert = prozent*10    -- Höchste = 252
	local shootingwert = prozent*20
	local stealthwert = prozent*30
	local strengthwert = prozent*40
	local flyingwert = prozent*50
	local drivingwert = prozent*60
	local lungwert = prozent*70
	dxDrawRectangle(screenW*(323/1600), screenH*(593/900), screenW*(staminawert/1600), screenH*(15/900), tocolor(23, 76, 133, 255), true)
	dxDrawRectangle(screenW*(323/1600), screenH*(630/900), screenW*(shootingwert/1600), screenH*(15/900), tocolor(23, 76, 133, 255), true)
	dxDrawRectangle(screenW*(323/1600), screenH*(667/900), screenW*(stealthwert/1600), screenH*(15/900), tocolor(23, 76, 133, 255), true)
	dxDrawRectangle(screenW*(323/1600), screenH*(704/900), screenW*(strengthwert/1600), screenH*(15/900), tocolor(23, 76, 133, 255), true)
	dxDrawRectangle(screenW*(323/1600), screenH*(741/900), screenW*(flyingwert/1600), screenH*(15/900), tocolor(23, 76, 133, 255), true)
	dxDrawRectangle(screenW*(323/1600), screenH*(778/900), screenW*(drivingwert/1600), screenH*(15/900), tocolor(23, 76, 133, 255), true)
	dxDrawRectangle(screenW*(323/1600), screenH*(815/900), screenW*(lungwert/1600), screenH*(15/900), tocolor(23, 76, 133, 255), true)
	
	check_accmenu_heritage = isCursorOnElement(screenW*(125/1600), screenH*(234/900), screenW*(450/1600), screenH*(37/900))
	check_accmenu_lifestyle = isCursorOnElement(screenW*(125/1600), screenH*(271/900), screenW*(450/1600), screenH*(37/900))
	check_accmenu_appearance = isCursorOnElement(screenW*(125/1600), screenH*(308/900), screenW*(450/1600), screenH*(37/900))
	check_accmenu_letsgo = isCursorOnElement(screenW*(125/1600), screenH*(345/900), screenW*(450/1600), screenH*(37/900))
end


function accmenu_appearance()
	local screenW, screenH = guiGetScreenSize()
	dxDrawImage(screenW*(0/1600), screenH*(0/900), screenW*(1025/1600), screenH*(900/900), "colors/db.png", 0, 0, 0, tocolor(255, 255, 255, 255), false)
	dxDrawImage(screenW*(1475/1600), screenH*(0/900), screenW*(125/1600), screenH*(900/900), "colors/db.png", 0, 0, 0, tocolor(255, 255, 255, 255), false)
    dxDrawImage(screenW*(1025/1600), screenH*(0/900), screenW*(450/1600), screenH*(234/900), "colors/db.png", 0, 0, 0, tocolor(255, 255, 255, 255), false)
    dxDrawImage(screenW*(1025/1600), screenH*(850/900), screenW*(450/1600), screenH*(50/900), "colors/db.png", 0, 0, 0, tocolor(255, 255, 255, 255), false)
	
	dxDrawRectangle(screenW*(125/1600), screenH*(37/900), screenW*(1350/1600), screenH*(187/900), tocolor(0, 0, 0, 170), false)
	dxDrawText("GTA:SA ONLINE", screenW*(148/1600), screenH*(74/900), screenW*(387/1600), screenH*(106/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont, "left", "top", false, false, true, false, false)
	dxDrawImage(screenW*(1380/1600), screenH*(47/900), screenW*(85/1600), screenH*(85/900), "avatar-default.png", 0, 0, 0, tocolor(255, 255, 255, 255), true)
	dxDrawText(playerusername, screenW*(1131/1600), screenH*(47/900), screenW*(1370/1600), screenH*(75/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont2, "right", "center", false, false, true, false, false)
	dxDrawText("Serverleitung", screenW*(1131/1600), screenH*(75/900), screenW*(1370/1600), screenH*(103/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont2, "right", "center", false, false, true, false, false)
	dxDrawText("BANK $10000    CASH $500", screenW*(1131/1600), screenH*(103/900), screenW*(1370/1600), screenH*(131/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont2, "right", "center", false, false, true, false, false)
	dxDrawText("Options", screenW*(125/1600), screenH*(179/900), screenW*(575/1600), screenH*(224/900), tocolor(0, 0, 0, 255), 1.00, gtaonlinefont1, "center", "center", false, false, true, false, false)
	dxDrawText("Details", screenW*(575/1600), screenH*(179/900), screenW*(1025/1600), screenH*(224/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont1, "center", "center", false, false, true, false, false)
	dxDrawText("You", screenW*(1025/1600), screenH*(179/900), screenW*(1475/1600), screenH*(224/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont1, "center", "center", false, false, true, false, false)
	
	-- Jetzige Auswahl --
	dxDrawRectangle(screenW*(125/1600), screenH*(174/900), screenW*(450/1600), screenH*(5/900), tocolor(19, 64, 121, 255), false)
	-- Jetzige Auswahl --
	
	dxDrawRectangle(screenW*(125/1600), screenH*(234/900), screenW*(900/1600), screenH*(616/900), tocolor(0, 0, 0, 170), false)
	dxDrawRectangle(screenW*(1025/1600), screenH*(234/900), screenW*(450/1600), screenH*(616/900), tocolor(0, 0, 0, 102), false)

	-- Jetzige Auswahl --
	dxDrawRectangle(screenW*(125/1600), screenH*(179/900), screenW*(450/1600), screenH*(45/900), tocolor(255, 255, 255, 255), false)
	-- Jetzige Auswahl --
	
	
	-- Jetzige Auswahl --
	dxDrawRectangle(screenW*(125/1600), screenH*(308/900), screenW*(450/1600), screenH*(37/900), tocolor(255, 255, 255, 255), false)
	
	
	dxDrawText("Heritage", screenW*(135/1600), screenH*(234/900), screenW*(575/1600), screenH*(271/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont2, "left", "center", false, false, true, false, false)
	dxDrawText("Lifestyle", screenW*(135/1600), screenH*(271/900), screenW*(575/1600), screenH*(308/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont2, "left", "center", false, false, true, false, false)
	dxDrawText("Appearance", screenW*(135/1600), screenH*(308/900), screenW*(575/1600), screenH*(345/900), tocolor(0, 0, 0, 255), 1.00, gtaonlinefont2, "left", "center", false, false, true, false, false)
	dxDrawRectangle(screenW*(125/1600), screenH*(345/900), screenW*(450/1600), screenH*(37/900), tocolor(0, 24, 51, 255), false)
	dxDrawText("Speichern & Fortfahren", screenW*(135/1600), screenH*(345/900), screenW*(575/1600), screenH*(382/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont2, "left", "center", false, false, true, false, false)
	dxDrawRectangle(screenW*(125/1600), screenH*(382/900), screenW*(450/1600), screenH*(5/900), tocolor(255, 255, 255, 255), true)
	dxDrawText("Wie viel Zeit verbringst du mit den Lebensstyle Optionen auf der rechten Seite?", screenW*(135/1600), screenH*(397/900), screenW*(533/1600), screenH*(493/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont2, "left", "top", false, true, true, false, false)
	dxDrawImage(screenW*(543/1600), screenH*(397/900), screenW*(32/1600), screenH*(32/900), "cross.png", 0, 0, 0, tocolor(255, 255, 255, 255), true)
	
	dxDrawText("Verbringe 24 Stunden mit deinem Charakter und du deine Werte werden sich verändern und du kannst deinen Charakter nach deinen Wünschen designen.", screenW*(135/1600), screenH*(493/900), screenW*(533/1600), screenH*(571/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont2, "left", "top", false, true, true, false, false)
	dxDrawText("Stamina", screenW*(135/1600), screenH*(581/900), screenW*(316/1600), screenH*(618/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont2, "left", "center", false, false, true, false, false)
	dxDrawText("Shooting", screenW*(135/1600), screenH*(618/900), screenW*(316/1600), screenH*(655/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont2, "left", "center", false, false, true, false, false)
	dxDrawText("Stealth", screenW*(135/1600), screenH*(692/900), screenW*(316/1600), screenH*(729/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont2, "left", "center", false, false, true, false, false)
	dxDrawText("Strength", screenW*(135/1600), screenH*(655/900), screenW*(316/1600), screenH*(692/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont2, "left", "center", false, false, true, false, false)
	dxDrawText("Flying", screenW*(135/1600), screenH*(729/900), screenW*(316/1600), screenH*(766/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont2, "left", "center", false, false, true, false, false)
	dxDrawText("Driving", screenW*(135/1600), screenH*(766/900), screenW*(316/1600), screenH*(803/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont2, "left", "center", false, false, true, false, false)
	dxDrawText("Lung Capacity", screenW*(135/1600), screenH*(803/900), screenW*(316/1600), screenH*(840/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont2, "left", "center", false, false, true, false, false)
	
	-- Hintergrund Werte --
	dxDrawRectangle(screenW*(323/1600), screenH*(593/900), screenW*(252/1600), screenH*(15/900), tocolor(12, 25, 42, 255), true)
	dxDrawRectangle(screenW*(323/1600), screenH*(630/900), screenW*(252/1600), screenH*(15/900), tocolor(12, 25, 42, 255), true)
	dxDrawRectangle(screenW*(323/1600), screenH*(667/900), screenW*(252/1600), screenH*(15/900), tocolor(12, 25, 42, 255), true)
	dxDrawRectangle(screenW*(323/1600), screenH*(704/900), screenW*(252/1600), screenH*(15/900), tocolor(12, 25, 42, 255), true)
	dxDrawRectangle(screenW*(323/1600), screenH*(741/900), screenW*(252/1600), screenH*(15/900), tocolor(12, 25, 42, 255), true)
	dxDrawRectangle(screenW*(323/1600), screenH*(778/900), screenW*(252/1600), screenH*(15/900), tocolor(12, 25, 42, 255), true)
	dxDrawRectangle(screenW*(323/1600), screenH*(815/900), screenW*(252/1600), screenH*(15/900), tocolor(12, 25, 42, 255), true)
	-- Hintergrund Werte --
	
	-- Vordergrund Werte --
	local prozent = (252/100)
	local staminawert = prozent*10    -- Höchste = 252
	local shootingwert = prozent*20
	local stealthwert = prozent*30
	local strengthwert = prozent*40
	local flyingwert = prozent*50
	local drivingwert = prozent*60
	local lungwert = prozent*70
	dxDrawRectangle(screenW*(323/1600), screenH*(593/900), screenW*(staminawert/1600), screenH*(15/900), tocolor(23, 76, 133, 255), true)
	dxDrawRectangle(screenW*(323/1600), screenH*(630/900), screenW*(shootingwert/1600), screenH*(15/900), tocolor(23, 76, 133, 255), true)
	dxDrawRectangle(screenW*(323/1600), screenH*(667/900), screenW*(stealthwert/1600), screenH*(15/900), tocolor(23, 76, 133, 255), true)
	dxDrawRectangle(screenW*(323/1600), screenH*(704/900), screenW*(strengthwert/1600), screenH*(15/900), tocolor(23, 76, 133, 255), true)
	dxDrawRectangle(screenW*(323/1600), screenH*(741/900), screenW*(flyingwert/1600), screenH*(15/900), tocolor(23, 76, 133, 255), true)
	dxDrawRectangle(screenW*(323/1600), screenH*(778/900), screenW*(drivingwert/1600), screenH*(15/900), tocolor(23, 76, 133, 255), true)
	dxDrawRectangle(screenW*(323/1600), screenH*(815/900), screenW*(lungwert/1600), screenH*(15/900), tocolor(23, 76, 133, 255), true)
	
	check_accmenu_heritage = isCursorOnElement(screenW*(125/1600), screenH*(234/900), screenW*(450/1600), screenH*(37/900))
	check_accmenu_lifestyle = isCursorOnElement(screenW*(125/1600), screenH*(271/900), screenW*(450/1600), screenH*(37/900))
	check_accmenu_appearance = isCursorOnElement(screenW*(125/1600), screenH*(308/900), screenW*(450/1600), screenH*(37/900))
	check_accmenu_letsgo = isCursorOnElement(screenW*(125/1600), screenH*(345/900), screenW*(450/1600), screenH*(37/900))
end


function mainmenu_home()
	local screenW, screenH = guiGetScreenSize()
	dxDrawImage((screenW - screenW) / 2, (screenH - screenH) / 2, screenW, screenH, "colors/db.png", 0, 0, 0, tocolor(255, 255, 255, 255), false)
	--dxDrawRectangle(screenW*(125/1600), screenH*(37/900), screenW*(1350/1600), screenH*(187/900), tocolor(0, 0, 0, 170), false)
	dxDrawRectangle(screenW*(125/1600), screenH*(37/900), screenW*(1350/1600), screenH*(187/900), tocolor(0, 0, 0, 170), false)
	dxDrawText("GTA:SA ONLINE", screenW*(148/1600), screenH*(74/900), screenW*(387/1600), screenH*(106/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont, "left", "top", false, false, true, false, false)
	dxDrawImage(screenW*(1380/1600), screenH*(47/900), screenW*(85/1600), screenH*(85/900), "avatar-default.png", 0, 0, 0, tocolor(255, 255, 255, 255), true)
	dxDrawText("Heaven", screenW*(1131/1600), screenH*(47/900), screenW*(1370/1600), screenH*(75/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont2, "right", "center", false, false, true, false, false)
	dxDrawText("Serverleitung", screenW*(1131/1600), screenH*(75/900), screenW*(1370/1600), screenH*(103/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont2, "right", "center", false, false, true, false, false)
	dxDrawText("BANK $10000    CASH $500", screenW*(1131/1600), screenH*(103/900), screenW*(1370/1600), screenH*(131/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont2, "right", "center", false, false, true, false, false)
	dxDrawText("Home", screenW*(125/1600), screenH*(179/900), screenW*(575/1600), screenH*(224/900), tocolor(0, 0, 0, 255), 1.00, gtaonlinefont1, "center", "center", false, false, true, false, false)
	dxDrawText("Login", screenW*(575/1600), screenH*(179/900), screenW*(1025/1600), screenH*(224/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont1, "center", "center", false, false, true, false, false)
	dxDrawText("Register", screenW*(1025/1600), screenH*(179/900), screenW*(1475/1600), screenH*(224/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont1, "center", "center", false, false, true, false, false)
	
	-- Jetzige Auswahl --
	dxDrawRectangle(screenW*(125/1600), screenH*(174/900), screenW*(450/1600), screenH*(5/900), tocolor(19, 64, 121, 255), false)
	-- Jetzige Auswahl --
	
	dxDrawRectangle(screenW*(125/1600), screenH*(234/900), screenW*(900/1600), screenH*(616/900), tocolor(0, 0, 0, 170), false)
	dxDrawRectangle(screenW*(1025/1600), screenH*(234/900), screenW*(450/1600), screenH*(616/900), tocolor(0, 0, 0, 102), false)
	dxDrawText("News", screenW*(135/1600), screenH*(244/900), screenW*(512/1600), screenH*(270/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont2, "center", "top", false, false, true, false, false)
	dxDrawRectangle(screenW*(522/1600), screenH*(234/900), screenW*(5/1600), screenH*(616/900), tocolor(255, 255, 255, 255), true)
	dxDrawText("> GTA V Style", screenW*(135/1600), screenH*(270/900), screenW*(512/1600), screenH*(840/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont2, "left", "top", false, false, true, false, false)
	dxDrawText("Herzlich Willkommen auf GTA:SA Online.\nFalls du noch keinen Account besitzt, kannst du dir einen unter 'Registrieren' erstellen.\n\nMit freundlichen Gruessen\ndie Serverleitung", screenW*(537/1600), screenH*(244/900), screenW*(1015/1600), screenH*(840/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont2, "center", "top", false, true, true, false, false)
	
	-- Jetzige Auswahl --
	dxDrawRectangle(screenW*(125/1600), screenH*(179/900), screenW*(450/1600), screenH*(45/900), tocolor(255, 255, 255, 255), false)
	-- Jetzige Auswahl --
	
	check_mainmenu_main = isCursorOnElement(screenW*(125/1600), screenH*(179/900), screenW*(450/1600), screenH*(45/900))
	check_mainmenu_login = isCursorOnElement(screenW*(575/1600), screenH*(179/900), screenW*(450/1600), screenH*(45/900))
	check_mainmenu_register = isCursorOnElement(screenW*(1025/1600), screenH*(179/900), screenW*(450/1600), screenH*(45/900))
end

function mainmenu_login()
	local screenW, screenH = guiGetScreenSize()
	dxDrawImage((screenW - screenW) / 2, (screenH - screenH) / 2, screenW, screenH, "colors/db.png", 0, 0, 0, tocolor(255, 255, 255, 255), false)
	dxDrawRectangle(screenW*(125/1600), screenH*(37/900), screenW*(1350/1600), screenH*(187/900), tocolor(0, 0, 0, 170), false)
	dxDrawText("GTA:SA ONLINE", screenW*(148/1600), screenH*(74/900), screenW*(387/1600), screenH*(106/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont, "left", "top", false, false, true, false, false)
	dxDrawImage(screenW*(1380/1600), screenH*(47/900), screenW*(85/1600), screenH*(85/900), "avatar-default.png", 0, 0, 0, tocolor(255, 255, 255, 255), true)
	dxDrawText("Heaven", screenW*(1131/1600), screenH*(47/900), screenW*(1370/1600), screenH*(75/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont2, "right", "center", false, false, true, false, false)
	dxDrawText("Serverleitung", screenW*(1131/1600), screenH*(75/900), screenW*(1370/1600), screenH*(103/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont2, "right", "center", false, false, true, false, false)
	dxDrawText("BANK $10000    CASH $500", screenW*(1131/1600), screenH*(103/900), screenW*(1370/1600), screenH*(131/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont2, "right", "center", false, false, true, false, false)
	dxDrawText("Home", screenW*(125/1600), screenH*(179/900), screenW*(575/1600), screenH*(224/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont1, "center", "center", false, false, true, false, false)
	dxDrawText("Login", screenW*(575/1600), screenH*(179/900), screenW*(1025/1600), screenH*(224/900), tocolor(0, 0, 0, 255), 1.00, gtaonlinefont1, "center", "center", false, false, true, false, false)
	dxDrawText("Register", screenW*(1025/1600), screenH*(179/900), screenW*(1475/1600), screenH*(224/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont1, "center", "center", false, false, true, false, false)
	
	-- Jetzige Auswahl --
	dxDrawRectangle(screenW*(575/1600), screenH*(174/900), screenW*(450/1600), screenH*(5/900), tocolor(19, 64, 121, 255), false)
	-- Jetzige Auswahl --
	
	dxDrawRectangle(screenW*(125/1600), screenH*(234/900), screenW*(900/1600), screenH*(345/900), tocolor(0, 0, 0, 170), false)

	dxDrawRectangle(screenW*(1025/1600), screenH*(234/900), screenW*(450/1600), screenH*(616/900), tocolor(0, 0, 0, 102), false)

	-- Jetzige Auswahl --
	dxDrawRectangle(screenW*(575/1600), screenH*(179/900), screenW*(450/1600), screenH*(45/900), tocolor(255, 255, 255, 255), false)
	-- Jetzige Auswahl --
	
	
	dxDrawText("Username:", screenW*(252/1600), screenH*(375/900), screenW*(492/1600), screenH*(403/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont2, "center", "center", false, false, true, false, false)
	
	dxDrawText("Falls du schon einen Account besitzt, kannst du dich hier mit deinen Accountdaten einloggen.", screenW*(135/1600), screenH*(244/900), screenW*(1015/1600), screenH*(275/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont2, "center", "top", false, false, true, false, false)
    dxDrawRectangle(screenW*(125/1600), screenH*(275/900), screenW*(900/1600), screenH*(5/900), tocolor(255, 255, 255, 255), true)
	
	dxDrawText("Passwort:", screenW*(252/1600), screenH*(413/900), screenW*(492/1600), screenH*(441/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont2, "center", "center", false, false, true, false, false)
    
	dxDrawRectangle(screenW*(417/1600), screenH*(518/900), screenW*(317/1600), screenH*(51/900), tocolor(0, 32, 63, 255), false)
    dxDrawText("Einloggen", screenW*(417/1600), screenH*(518/900), screenW*(734/1600), screenH*(569/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont2, "center", "center", false, false, true, false, false)
	
	
	
	check_mainmenu_main = isCursorOnElement(screenW*(125/1600), screenH*(179/900), screenW*(450/1600), screenH*(45/900))
	check_mainmenu_login = isCursorOnElement(screenW*(575/1600), screenH*(179/900), screenW*(450/1600), screenH*(45/900))
	check_mainmenu_login_btn = isCursorOnElement(screenW*(417/1600), screenH*(518/900), screenW*(317/1600), screenH*(51/900))
	check_mainmenu_register = isCursorOnElement(screenW*(1025/1600), screenH*(179/900), screenW*(450/1600), screenH*(45/900))
end

function mainmenu_register()
	local screenW, screenH = guiGetScreenSize()
	dxDrawImage((screenW - screenW) / 2, (screenH - screenH) / 2, screenW, screenH, "colors/db.png", 0, 0, 0, tocolor(255, 255, 255, 255), false)
	dxDrawRectangle(screenW*(125/1600), screenH*(37/900), screenW*(1350/1600), screenH*(187/900), tocolor(0, 0, 0, 170), false)
	dxDrawText("GTA:SA ONLINE", screenW*(148/1600), screenH*(74/900), screenW*(387/1600), screenH*(106/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont, "left", "top", false, false, true, false, false)
	dxDrawImage(screenW*(1380/1600), screenH*(47/900), screenW*(85/1600), screenH*(85/900), "avatar-default.png", 0, 0, 0, tocolor(255, 255, 255, 255), true)
	dxDrawText("Heaven", screenW*(1131/1600), screenH*(47/900), screenW*(1370/1600), screenH*(75/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont2, "right", "center", false, false, true, false, false)
	dxDrawText("Serverleitung", screenW*(1131/1600), screenH*(75/900), screenW*(1370/1600), screenH*(103/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont2, "right", "center", false, false, true, false, false)
	dxDrawText("BANK $10000    CASH $500", screenW*(1131/1600), screenH*(103/900), screenW*(1370/1600), screenH*(131/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont2, "right", "center", false, false, true, false, false)
	dxDrawText("Home", screenW*(125/1600), screenH*(179/900), screenW*(575/1600), screenH*(224/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont1, "center", "center", false, false, true, false, false)
	dxDrawText("Login", screenW*(575/1600), screenH*(179/900), screenW*(1025/1600), screenH*(224/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont1, "center", "center", false, false, true, false, false)
	dxDrawText("Register", screenW*(1025/1600), screenH*(179/900), screenW*(1475/1600), screenH*(224/900), tocolor(0, 0, 0, 255), 1.00, gtaonlinefont1, "center", "center", false, false, true, false, false)
	
	-- Jetzige Auswahl --
	dxDrawRectangle(screenW*(1025/1600), screenH*(174/900), screenW*(450/1600), screenH*(5/900), tocolor(19, 64, 121, 255), false)
	-- Jetzige Auswahl --
	
	dxDrawRectangle(screenW*(125/1600), screenH*(234/900), screenW*(900/1600), screenH*(616/900), tocolor(0, 0, 0, 170), false)
	dxDrawRectangle(screenW*(1025/1600), screenH*(234/900), screenW*(450/1600), screenH*(616/900), tocolor(0, 0, 0, 102), false)
	dxDrawText("News", screenW*(135/1600), screenH*(244/900), screenW*(512/1600), screenH*(270/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont2, "center", "top", false, false, true, false, false)
	dxDrawRectangle(screenW*(522/1600), screenH*(234/900), screenW*(5/1600), screenH*(616/900), tocolor(255, 255, 255, 255), true)
	dxDrawText("> GTA V Style", screenW*(135/1600), screenH*(270/900), screenW*(512/1600), screenH*(840/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont2, "left", "top", false, false, true, false, false)
	dxDrawText("Herzlich Willkommen auf GTA:SA Online.\nFalls du noch keinen Account besitzt, kannst du dir einen unter 'Registrieren' erstellen.\n\nMit freundlichen Gruessen\ndie Serverleitung", screenW*(537/1600), screenH*(244/900), screenW*(1015/1600), screenH*(840/900), tocolor(255, 255, 255, 255), 1.00, gtaonlinefont2, "center", "top", false, true, true, false, false)
	
	-- Jetzige Auswahl --
	dxDrawRectangle(screenW*(1025/1600), screenH*(179/900), screenW*(450/1600), screenH*(45/900), tocolor(255, 255, 255, 255), false)
	-- Jetzige Auswahl --
	
	check_mainmenu_main = isCursorOnElement(screenW*(125/1600), screenH*(179/900), screenW*(450/1600), screenH*(45/900))
	check_mainmenu_login = isCursorOnElement(screenW*(575/1600), screenH*(179/900), screenW*(450/1600), screenH*(45/900))
	check_mainmenu_register = isCursorOnElement(screenW*(1025/1600), screenH*(179/900), screenW*(450/1600), screenH*(45/900))
end