ItemHotwireKit = inherit(Item)

function ItemHotwireKit:constructor() end
function ItemHotwireKit:destructor() end

function ItemHotwireKit:use(inventory, player)
	-- Report the crime
	player:reportCrime(Crime.Hotwire)
end
