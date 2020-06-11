-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Jobs/JobServiceTechnicianTask.lua
-- *  PURPOSE:     Job service technician task question class
-- *
-- ****************************************************************************
JobServiceTechnicianTaskQuestion = inherit(JobServiceTechnicianTask)

function JobServiceTechnicianTaskQuestion:start(player)

    player:triggerEvent("openServiceTechnicianQuestionGraphicUserInterface", self:getQuestionSet(3)) -- by Shape alias Gibaex mit freundlichen Grüßen

end

function JobServiceTechnicianTaskQuestion:getQuestionSet(numQuestions)
	return Randomizer:getRandomOf(numQuestions, JobServiceTechnicianTaskQuestion.Questions)
end



addEvent("serviceTechnicianQuestionsRetrieve", true)
addEventHandler("serviceTechnicianQuestionsRetrieve", root,
    function(results)

    end
)

JobServiceTechnicianTaskQuestion.Questions = {
    {
        [[Gegeben ist folgende Konfiguration: 3 Clients mit den IPs 192.168.2.1, 192.168.2.127 und 192.168.2.254 mit der Präfixlänge von 24.
        Der Standardgateway hat die IP 192.168.1.1. Die Clients können keine Verbindung ins Internet aufbauen. Was ist das Problem?]],
        "Der Standardgateway ist in einem anderen Subnetz als die 3 Clients",
        "Die IP Adresse des Standardgateways muss auf 192.168.1.255 geändert werden",
        "Das Routingprotokoll RIP ist im Netz nicht aktiv",
        "Das WLAN-Kabel ist gebrochen" -- by jusi
    },
    {
        [[Ein Windows-PC funktioniert nicht mehr richtig. Welchen Rat solltest Du dem unerfahrenen Nutzer zuerst geben?]],
        "PC neustarten",
        "Die Logfiles nach Fehlern durchsuchen",
        "Den SPF Algorithmus neu konfigurieren",
        "Microsoft Linux neu kompilieren"
    },
    {
        [[Der Kunde möchte den Befehl wissen, um auf der Windows Kommandozeile in das Laufwerk "D" zu wechseln.]],
        "D:",
        "cd D:",
        "D",
        "cd D"
    }
}
for index in ipairs(JobServiceTechnicianTaskQuestion.Questions) do
	JobServiceTechnicianTaskQuestion.Questions[index][6] = index
end
