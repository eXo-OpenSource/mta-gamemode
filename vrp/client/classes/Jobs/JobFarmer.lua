-- // Client

JobFarmer = inherit(Job)

addEvent("onReciveFarmerData",true)

function JobFarmer:constructor()
	Job.constructor(self,-1059,-1206,128, "files/images/Blips/Roadsweeper.png", "files/images/Jobs/HeaderFarmer.png", [[
	1.Saat auslegen
	2.Farmen
	3.Abliefern
	]])
	
end

function JobFarmer:start()
end

function JobFarmer:stop()
end