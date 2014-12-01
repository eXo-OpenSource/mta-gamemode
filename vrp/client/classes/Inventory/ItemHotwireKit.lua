ItemHotwireKit = inherit(Item)

function ItemHotwireKit:constructor() outputDebugString("Hi from client!") end
function ItemHotwireKit:destructor() end

function ItemHotwireKit:use(player)
	outputChatBox("Hi from client")

	-- Report the crime
	--player:reportCrime(Crime.Hotwire)
	
	-- Start clientside display
	-- Todo
end
