-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Discord.lua
-- *  PURPOSE:     Discord API-class
-- *
-- ****************************************************************************
Discord = inherit(Singleton) 

function Discord:constructor() 
end


function Discord:destructor() 

end

function Discord:outputBreakingNews( text ) 
	if not DEBUG then
		local postData = 
		{
			queueName = "Discord Breaking-News",
			connectionAttempts = 3,
			connectTimeout = 5000,
			formFields = 
			{
				content=text,
				username="Breaking News",
			},
		}
		fetchRemote ( "", postData, function() end )
	else 
		outputDebugString("Discord Breaking-News was not sent ( Debug-Mode )", 3)
	end
end

function Discord:outputGangwarNews( text ) --TODO: do this lol
	--if not DEBUG then
		local textScaffhold = 
[[
Das Gebiet '%s' der Fraktion %s wurde von der Fraktion %s angegriffen%s. Details:
```diff
+++ %s (%s Verteidiger, %s Damagepunkte)
%s
--- %s (%s Verteidiger, %s Damagepunkte)
%s
```
]]
		local postData = 
		{
			queueName = "Discord Gangwar-News",
			connectionAttempts = 3,
			connectTimeout = 5000,
			formFields = 
			{
				content=textScaffhold,
				username="Gangwar-Ergebnisse",
			},
		}
		fetchRemote ( "", postData, function() end )
	--else 
		outputDebugString("Discord Breaking-News was not sent ( Debug-Mode )", 3)
	--end
end
