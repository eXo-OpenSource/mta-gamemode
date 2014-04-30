-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Forum.lua
-- *  PURPOSE:     Forum class
-- *
-- ****************************************************************************
Forum = inherit(Singleton)

function Forum:constructor()
end

function Forum:createAccount(player, username, password)
	fetchRemote((API_URL.."action=CreateAccount&username=%s&password=%s"):format(username, password), Async.waitFor(player))
	return Async.wait()
end

Forum.api = {}
function Forum.api.call(user, hostname, form)
	if not Forum.api.validate(user, hostname) then
		return false
	end
	
	for k, v in pairs(form) do
		outputDebug(k)
		outputDebug(v)
	end
end
api_request = Forum.api.call


function Forum.api.validate(user, hostname)
	-- ToDo: Do something to find out if the request was made from a legit source (the forum)
	return true
end

function Forum.api.sendMoney(userIdSource, userIdTarget, amount, reason)
	local sourceAccount = DatabasePlayer.get(userIdSource)
	if not sourceAccount or amount <= 0 then 
		return false
	end
	
	amount = math.ceil(amount)
	
	if sourceAccount:getBankMoney() < amount then
		return false, "Not enough money"
	end
	
	local targetAccount = DatabasePlayer.get(userIdSource)
	if not targetAccount then 
		return false
	end
	
	sourceAccount:takeBankMoney(amount)
	targetAccount:giveBankMoney(amount)
	
	-- ToDo: Maybe output a message if the target user is logged in / playing
	
	return true
end