ItemHotwireKit = inherit(Item)

function ItemHotwireKit:constructor() outputChatBox("HotwireKit has been added to a inventory") end
function ItemHotwireKit:destructor() outputChatBox("HotwireKit has been removed from a inventory") end

function ItemHotwireKit:use(player)
	outputChatBox("Hi from client")

	-- Report the crime
	--player:reportCrime(Crime.Hotwire)
	
	-- Start clientside display
	-- Todo
end
