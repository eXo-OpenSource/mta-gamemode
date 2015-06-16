-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/API.lua
-- *  PURPOSE:     Forum class
-- *
-- ****************************************************************************
Forum = inherit(Singleton)

function Forum:constructor()
end

Forum.api = {}
function Forum.api.call(user, hostname, form)
	if not Forum.api.validate(user, hostname) then
		return false
	end

	sql:setAsyncEnabled(false)
	form = form or {}

	if not form.action then
		return false
	end

	outputServerLog(form.action)
	local result = {pcall(Forum.api[form.action], form)}
	sql:setAsyncEnabled(true)

	if #result ~= 1 then
		table.remove(result, 1)
	end

	return unpack(result)
end
api_request = Forum.api.call


function Forum.api.validate(user, hostname)
	-- ToDo: Do something to find out if the request was made from a legit source (the forum)
	return true
end

function Forum.api.sendMoney(form)
	local userIdSource = tonumber(form.user)
	local userIDTarget = tonumber(form.target)
	local amount = tonumber(form.amount)
	local reason = tostring(form.reason)
	assert(userIdSource and userIDTarget and amount and reason, "Bad API Call")

	local sourceAccount = DatabasePlayer.get(userIdSource)
	if not sourceAccount or amount <= 0 or not sourceAccount:load() then
		return false
	end

	amount = math.ceil(amount)
	if sourceAccount:getBankMoney() < amount then
		return false, "Not enough money"
	end

	local targetAccount = DatabasePlayer.get(userIDTarget)
	if not targetAccount or not targetAccount:load() then
		return false
	end

	sourceAccount:takeBankMoney(amount)
	targetAccount:giveBankMoney(amount)

	sourceAccount:save()
	targetAccount:save()

	-- ToDo: Maybe output a message if the target user is logged in / playing

	return true
end

function Forum.api.get_active_players()
	local activePlayers = {}
	for k, player in pairs(getElementsByType("player")) do
		activePlayers[#activePlayers + 1] = {player:getId(), player:getName()}
	end
	return activePlayers
end
