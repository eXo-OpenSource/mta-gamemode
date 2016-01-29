local HandelGui = {
    edit = {},
    button = {},
    window = {},
    label = {},
    gridlist = {},
	image = {}
}

local targetC = ""

function openHandelGui_func(target)
	local tname = ""
	if isElement(target) then 
		tname = getPlayerName(target) 
		targetC = target
	end
	if isElement(HandelGui.window[1]) then destroyElement(HandelGui.window[1]) end
	showCursor(true)
	guiSetInputEnabled ( true )
	
	HandelGui.window[1] = guiCreateWindow(444, 138, 395, 302, "eXo-Handel", false)
	guiWindowSetSizable(HandelGui.window[1], false)

	HandelGui.label[1] = guiCreateLabel(15, 30, 369, 35, "Hier kannst du Sachen mit anderen Spielern handeln. Wähle das Item aus und setze einen Preis dafür.", false, HandelGui.window[1])
	guiLabelSetHorizontalAlign(HandelGui.label[1], "left", true)
	HandelGui.label[2] = guiCreateLabel(15, 65, 127, 18, "Handelspartner:", false, HandelGui.window[1])
	guiSetFont(HandelGui.label[2], "default-bold-small")
	guiLabelSetColor(HandelGui.label[2], 50, 200, 255)
	HandelGui.label[3] = guiCreateLabel(142, 65, 126, 18, tname, false, HandelGui.window[1])
	HandelGui.gridlist[1] = guiCreateGridList(15, 110, 173, 184, false, HandelGui.window[1])
	guiGridListAddColumn(HandelGui.gridlist[1], "Item", 0.6)
	guiGridListAddColumn(HandelGui.gridlist[1], "Anzahl", 0.3)
	HandelGui.label[4] = guiCreateLabel(15, 92, 163, 18, "Deine handelbaren Items:", false, HandelGui.window[1])
	guiSetFont(HandelGui.label[4], "default-bold-small")
	guiLabelSetColor(HandelGui.label[4], 50, 200, 255)
	HandelGui.label[5] = guiCreateLabel(198, 166, 163, 18, "Gewünschter Geld-Betrag:", false, HandelGui.window[1])
	guiSetFont(HandelGui.label[5], "default-bold-small")
	guiLabelSetColor(HandelGui.label[5], 50, 200, 255)
	HandelGui.label[6] = guiCreateLabel(198, 110, 163, 18, "Anzahl zum Handeln:", false, HandelGui.window[1])
	guiSetFont(HandelGui.label[6], "default-bold-small")
	guiLabelSetColor(HandelGui.label[6], 50, 200, 255)
	HandelGui.edit[1] = guiCreateEdit(198, 132, 67, 27, "1", false, HandelGui.window[1])
	HandelGui.label[7] = guiCreateLabel(268, 138, 35, 18, "Stück", false, HandelGui.window[1])
	HandelGui.edit[2] = guiCreateEdit(198, 186, 67, 27, "", false, HandelGui.window[1])
	HandelGui.label[8] = guiCreateLabel(268, 190, 35, 18, "$", false, HandelGui.window[1])
	HandelGui.button[1] = guiCreateButton(195, 257, 93, 33, "Handel\nanbieten", false, HandelGui.window[1])
	HandelGui.button[2] = guiCreateButton(293, 257, 93, 33, "Schließen", false, HandelGui.window[1])
	HandelGui.button[3] = guiCreateButton(195, 223, 190, 24, "Items Aktualisieren", false, HandelGui.window[1])
	--HandelGui.image[1] = guiCreateStaticImage(leftoffset+13, topoffset+17, 66, 68, ":exo_hud/image/weapon/"..pic..".png", false, gunboxGUI.window[1])
	refreshItems()
	
	addEventHandler("onClientGUIClick",HandelGui.button[1],
			function(button,state)
				if button == "left" and state =="up" and guiGetVisible(source)==true and guiGetEnabled(source)==true then
					if isElement(targetC) then
						local anzahl = tonumber(guiGetText(HandelGui.edit[1]))
						local geld = tonumber(guiGetText(HandelGui.edit[2]))
						local itemname = guiGridListGetItemText ( HandelGui.gridlist[1], guiGridListGetSelectedItem ( HandelGui.gridlist[1] ), 1 )
						local maxanzahl = tonumber(guiGridListGetItemText ( HandelGui.gridlist[1], guiGridListGetSelectedItem ( HandelGui.gridlist[1] ), 2 ))
						if anzahl and geld and itemname and maxanzahl then
							if maxanzahl >= anzahl and anzahl > 0 then
								if geld >= 0 then
									triggerServerEvent("bieteHandel",getLocalPlayer(),targetC,itemname,anzahl,geld)
									destroyElement(HandelGui.window[1])
									guiSetInputEnabled ( false )
									showCursor(false)
								else
								
								end
							else
							outputChatBox("Du hast nicht soviel von diesem Item!",255,0,0)
							end
							
						else
							outputChatBox("Du hast nicht alles ausgefüllt!",255,0,0)
						end
					else
						outputChatBox("Spieler nicht gefunden!",255,0,0)
					end
				end
			end,false)
	
	addEventHandler("onClientGUIClick",HandelGui.button[3],
			function(button,state)
				if button == "left" and state =="up" and guiGetVisible(source)==true and guiGetEnabled(source)==true then
					refreshItems()
				end
			end,false)
	
	addEventHandler("onClientGUIClick",HandelGui.button[2],
			function(button,state)
				if button == "left" and state =="up" and guiGetVisible(source)==true and guiGetEnabled(source)==true then
					destroyElement(HandelGui.window[1])
					guiSetInputEnabled ( false )
					showCursor(false)
				end
			end,false)
end
addEvent("openHandelGui",true)
addEventHandler("openHandelGui",getRootElement(),openHandelGui_func)

function refreshItems()
	triggerServerEvent("callRefreshItems",getLocalPlayer())
end

function getItems_func(handelItems)
	local anzahl = 0
	local i = 0
	guiGridListClear(HandelGui.gridlist[1])
	for item, index in pairs(handelItems) do
		anzahl = tonumber(handelItems[item]["anzahl"])
		guiGridListAddRow(HandelGui.gridlist[1])
		guiGridListSetItemText(HandelGui.gridlist[1], i, 1, item, false, false)
		guiGridListSetItemText(HandelGui.gridlist[1], i, 2, anzahl, false, false)
		i = i+1
	end
end
addEvent("getItems",true)
addEventHandler("getItems",getRootElement(),getItems_func)