-- Tempoary Login while we have no GUI
addCommandHandler("dayzlogin", 
	function(_, user, pw)
		localPlayer:login(user, pw)
	end
)

addCommandHandler("dayzregister", 
	function(_, user, pw)
		localPlayer:register(user, pw)
	end
)

