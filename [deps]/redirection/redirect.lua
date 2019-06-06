local serverIP = ""
local serverPort = 0

function onPlayerJoin_handler()
    if serverIP and serverPort then
        redirectPlayer(source, serverIP, serverPort)
    end
end
addEventHandler("onPlayerJoin", root, onPlayerJoin_handler)