function exoSetElementData(player,arg1,arg2)
	exports.exo:exoSetElementData (player,arg1,arg2)
end

function exoGetElementData(player,arg1)
	return exports.exo:exoGetElementData (player,arg1)
end

function givePlayerSaveMoney(arg1,arg2)
	exports.exo:givePlayerSaveMoney (arg1,arg2)
end

function takePlayerSaveMoney(arg1,arg2)
	exports.exo:takePlayerSaveMoney (arg1,arg2)
end

function infobox(arg1,arg2,arg3,arg4,arg5,arg6)
	exports.exo:infobox ( arg1,arg2,arg3,arg4,arg5,arg6 )
end

function getPlayerFromPartOfName(tname,player)
	return exports.exo:getPlayerFromPartOfName(tname,player)
end

function sendMSGForFaction ( msg, faction, r, g, b )
	exports.exo:export_func ( "sendMSGForFaction",msg, faction, r, g, b )
end

function getFactionMembersOnline ( faction )
	if faction then
		return exports.exo:export_func ( "getFactionMembersOnline",faction )
	end
end

function meCMD_func ( player, cmd, ... )
	exports.exo:meCMD_func ( player, cmd, ... )
end