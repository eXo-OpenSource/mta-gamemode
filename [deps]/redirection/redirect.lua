local serverIP = "144.76.87.216"
local serverPort = 22003

function onPlayerJoin_handler()
    if serverIP and serverPort then
        redirectPlayer(source, serverIP, serverPort)
    end
end
addEventHandler("onPlayerJoin", root, onPlayerJoin_handler)