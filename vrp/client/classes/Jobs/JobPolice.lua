-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Jobs/JobPolice.lua
-- *  PURPOSE:     Police job class
-- *
-- ****************************************************************************
JobPolice = inherit(Job)

function JobPolice:constructor()
	Job.constructor(self, 1549.5, -1681.6, 12.6, "Police.png", "files/images/Jobs/HeaderPolice.png", _"Polizist/-in", _([[
		Als Polizist/-in ist es deine Aufgabe in San Andreas für Ordnung zu sorgen.
		Sollte ein anderer Bürger sich nicht an Recht und Ordnung halten und dafür schon bei der Polizei bekannt ist, bist du in der Lage ihn dafür zu verhaften.
		
		Um einen gesuchten Bürger zu verhaften, musst du nichts weiter machen als den Verbrecher mit dem Schlagstock, der dir kostenlos zur Verfügung steht, schlagen.
	]]))
end

function JobPolice:start()
end

function JobPolice:stop()
end