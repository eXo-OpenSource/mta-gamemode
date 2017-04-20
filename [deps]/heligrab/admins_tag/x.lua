addEventHandler ( "onPlayerChat", root,
function ( message, type )
if isObjectInACLGroup ( "user." .. getAccountName(getPlayerAccount(source)), aclGetGroup ( "Moderator" ) ) and type == 0 then
    cancelEvent ( )
    local r, g, b = getPlayerNametagColor(source)
    outputChatBox ( "#000000[#00ff00Moderator#000000]#ffffff " .. getPlayerName(source) .. ": " .. message, getRootElement(), r, g, b, true )
elseif isObjectInACLGroup ( "user." .. getAccountName(getPlayerAccount(source)), aclGetGroup ( "Admin" ) ) and type == 0 then   
    cancelEvent ( )
    local r, g, b = getPlayerNametagColor(source)
    outputChatBox ( "#000000[#C11B17Admin#000000]#ffffff " .. getPlayerName(source) .. ": " .. message, getRootElement(), r, g, b, true )
elseif isObjectInACLGroup ( "user." .. getAccountName(getPlayerAccount(source)), aclGetGroup ( "Console" ) ) and type == 0 then   
    cancelEvent ( )
    local r, g, b = getPlayerNametagColor(source)
    outputChatBox ( "#000000#C11B17[Inhaber]#000000#ffffff " .. getPlayerName(source) .. ": " .. message, getRootElement(), r, g, b, true )
end
end)