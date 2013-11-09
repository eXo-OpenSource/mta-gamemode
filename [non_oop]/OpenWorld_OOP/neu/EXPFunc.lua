nowexp = 0

experience = {
    [1] = 1000,
    [2] = 2000,
    [3] = 4000,
    [4] = 6000,
    [5] = 8000,
}

function sync()
	syncLevelAndEXP()
end
addCommandHandler("syncme", sync)

function setexp()
	nowexp = nowexp+100
	outputChatBox(nowexp)
end
addCommandHandler("setexp", setexp)

setTimer(function()
	local currentEXP = nowexp
	local level
	local neededEXP
	
	for index = 1, #experience, 1 do
		level = index
		neededEXP = experience[index]
		if (experience[index] > currentEXP) then
			break
		elseif (index == #experience) then
			currentEXP = "MAX"
			neededEXP = "MAX"
		end
	end
	triggerClientEvent(source, "setLevel", source, level, currentEXP, neededEXP)
end, 500, 0)

function getLevel(name)
	local level
	local currentEXP = devGetAccountData(name, "expe")
	for index = 1, #experience, 1 do
		level = index
		if (experience[index] > currentEXP) then
			break
		end
	end
	return level
end

function isPlayerMaxEXP(pl)
	local name = getPlayerName(pl)
	local currentEXP = nowexp
	if (currentEXP > experience[#experience]) then
		return true
	else
		return false
	end
end