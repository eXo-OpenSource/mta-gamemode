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
		fetchRemote ( "https://discordapp.com/api/webhooks/401093257481682944/xX4jy3rTLFByTtGoXJeT8efFcJhLlh09ny0DS3xvLHIlBvYl0-z_cbmcY8cUXEVRnVbv", postData, function() end )
	else 
		outputDebugString("Discord Breaking-News was not sent ( Debug-Mode )", 3)
	end
end
