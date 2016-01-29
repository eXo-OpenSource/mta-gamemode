function onPlayerItemUseServer_func(itemid,tasche,itemname,platz,delete) 
	if not getElementData ( source, "prison" ) == true then
		if delete == true then
			removeItemFromPlatz(source,tasche,platz,1)
		end
		--outputChatBox("Gegenstand "..itemname.." verwendet!",source,255,0,0)
		if tasche == "Drogen" then
			if itemname == "Zigaretten" or itemname == "Weed-Samen" then
				exports.exo:export_func ( "useItem",source, itemname )
			else
				exports.exo:export_func ( "useItem",source, "Droge",itemname )
			end
		else
			exports.exo:export_func ( "useItem",source, itemname )
		end
	else
		outputChatBox("Es können keine Items im Prison verwendet werden!",source,255,0,0)
	end
end
addEvent("onPlayerItemUseServer",true)
addEventHandler("onPlayerItemUseServer",getRootElement(),onPlayerItemUseServer_func)