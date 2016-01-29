function startHandel(player,cmd,tname)
	if tname then
		local target = getPlayerFromPartOfName(tname,player)
		if isElement(target) then
			if target ~= player then
				local x,y,z = getElementPosition(player)
				local tx,ty,tz = getElementPosition(target)
				if getDistanceBetweenPoints3D(x,y,z,tx,ty,tz) < 10 then
					triggerClientEvent(player,"openHandelGui",player,target)
				else
					infobox(player,"Du bist zuweit entfernt!",7200,255,0,0)
				end
			else
				infobox(player,"Du kannst nicht mit dir selbst handeln!",7200,255,0,0)
			end
		end
	else
		infobox(player,"Handel-Befehl:\n/handel NAME",7200,255,0,0)
	end
end
addCommandHandler("handel",startHandel)
addCommandHandler("trade",startHandel)
addCommandHandler("handeln",startHandel)

function getHandelItems(player)
	
end
addCommandHandler("getitems",getHandelItems)

function callRefreshItems_func()
	local player = client
	
	local handelItems = {}
	
	local handel = 0
	local anzahl = 0
	for item, index in pairs(itemData) do
		handel = itemData[item]["Handel"]
		if handel == 1 then
			anzahl = getPlayerItemAnzahl(player,item)
			if anzahl > 0 then
				handelItems[item] = {}
				handelItems[item]["name"] = item
				handelItems[item]["anzahl"] = anzahl
			end
		end
	end
	
	triggerClientEvent(player,"getItems",player,handelItems)
	
end
addEvent("callRefreshItems",true)
addEventHandler("callRefreshItems",getRootElement(),callRefreshItems_func)

function bieteHandel_func(target,item,anzahl,geld)
	local player = client
	if isElement(target) then
		local x,y,z = getElementPosition(player)
		local tx,ty,tz = getElementPosition(target)
		if getDistanceBetweenPoints3D(x,y,z,tx,ty,tz) < 10 then
			if target ~= player then
				if item and anzahl and geld then
					if getPlayerItemAnzahl(player,item) then
						outputChatBox("Du hast dem Spieler "..getPlayerName(target).." "..anzahl.." "..item.." für "..geld.."$ angeboten!",player,125,125,255)
						outputChatBox("Der Spieler "..getPlayerName(player).." bietet dir "..anzahl.." "..item.." für "..geld.."$ an!",target,125,125,255)
						outputChatBox("Drücke F3 um den Handel anzunehmen, oder F4 um abzulehnen!",target,125,125,255)
						
						bindKey ( target, "F3", "down", handelAnnehmen,player,item,anzahl,geld)
						bindKey ( target, "F4", "down", handelAblehnen,player,item,anzahl,geld)
					else
						infobox(player,"Du hast nicht mehr soviel von diesem Item!",7200,255,0,0)
					end
				else
					infobox(player,"Parameter fehlt!",7200,255,0,0)
				end
			else
				infobox(player,"Du kannst nicht mit dir selbst handeln!",7200,255,0,0)
			end	
		else
			infobox(player,"Du bist zuweit entfernt!",7200,255,0,0)
		end	
	else
		infobox(player,"Ziel nicht gefunden!",7200,255,0,0)
	end
end
addEvent("bieteHandel",true)
addEventHandler("bieteHandel",getRootElement(),bieteHandel_func)

function unbindHandelKeys(player)
	unbindKey ( player, "F3", "down", handelAnnehmen)
	unbindKey ( player, "F4", "down", handelAblehnen)

end

function handelAnnehmen(player,key,state,partner,item,anzahl,geld)
	if isElement(partner) then
		local x,y,z = getElementPosition(player)
		local tx,ty,tz = getElementPosition(partner)
		if getDistanceBetweenPoints3D(x,y,z,tx,ty,tz) < 10 then
			if getFreePlacesForItem(player,item) >= anzahl then
				if exoGetElementData(player,"money") >= geld then
					if getPlayerItemAnzahl(partner,item) >= anzahl then
						outputChatBox("Du hast den Handel mit "..getPlayerName(partner).." angenommen!",player,125,125,255)
						outputChatBox(getPlayerName(player).." hat deinen Handel angenommen!",partner,125,125,255)
						meCMD_func ( partner, "meCMD", "handelt mit "..getPlayerName ( player ).."! (Item: "..item..")" )
						exports.exo:outputLog ( getPlayerName ( partner ).." handelt mit "..getPlayerName ( player ).."! ("..anzahl.." x "..item.." für "..geld.."$)", "handel" )
						removeItem(partner,item,anzahl)
						giveItem(player,item,anzahl)
						
						takePlayerSaveMoney(player,geld)
						givePlayerSaveMoney(partner,geld)
						unbindHandelKeys(player)
					else
						infobox(player,"Dein Handelspartner hat nicht mehr genug "..item.."!",7200,255,0,0)
					end
				else
					infobox(player,"Du hast nicht soviel Geld! ("..geld.."$)",7200,255,0,0)
				end
			else
				infobox(player,"Du hast nicht Platz für "..anzahl.." "..item.."!",7200,255,0,0)
			end
		else
			infobox(player,"Du bist zuweit entfernt!",7200,255,0,0)
		end		
	else
		infobox(player,"Handelspartner nicht gefunden!",7200,255,0,0)
	end
end

function handelAblehnen(player,key,state,partner,item,anzahl,geld)
	outputChatBox("Du hast den Handel mit "..getPlayerName(partner).." abgelehnt!",player,125,125,255)
	outputChatBox(getPlayerName(player).." hat deinen Handel abgelehnt!",partner,125,125,255)
	unbindHandelKeys(player)
end