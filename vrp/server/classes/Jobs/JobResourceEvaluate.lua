-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Jobs/JobResourceEvaluate.lua
-- *  PURPOSE:     Job-Resource Evaluator
-- *
-- ****************************************************************************
JobResourceEvaluate = inherit(Singleton)	

function JobResourceEvaluate:constructor() 
	self.m_EvaluationTable = {}
	self.m_Date = getPastDateDay(24*365*9)

	print("** Pinging for Job-Evaluations, this will cause a warning if the table is not found! **")
	if not sqlLogs:queryFetch("SELECT 1 FROM ??_JobEvaluations;", sqlLogs:getPrefix()) then -- ping to see if we have all dependant tables before things get fucked up
		sqlLogs:queryExec("CREATE TABLE `??_JobEvaluations` " ..
							"(`Id` INT NOT NULL AUTO_INCREMENT, `Data` TEXT NOT NULL DEFAULT '', `Date` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, PRIMARY KEY (`Id`)) " ..
							"COLLATE='utf8_general_ci' ENGINE=InnoDB", sqlLogs:getPrefix())
		print(("** Job-Evaluation is missing! Creating %s_JobEvaluations... **"):format(sqlLogs:getPrefix()))
	end
end

function JobResourceEvaluate:startAsyncEvaluate() 
	Async.create(bind(self.evaluate, self))()
end

function JobResourceEvaluate:evaluate() 	
	sqlLogs:queryFetchSingle(Async.waitFor(), "SELECT COUNT(*) as Anzahl FROM ??_Job WHERE Date >= ?;", sqlLogs:getPrefix(), self.m_Date)
	local maxCount = Async.wait().Anzahl 

	sqlLogs:queryFetch(Async.waitFor(), "SELECT Id, Job, Duration, Date FROM ??_Job WHERE Date >= ?;", sqlLogs:getPrefix(), self.m_Date)
	local result = Async.wait()
	local fetch = {}
	local count = 0
	if result then 
		for k, row in pairs(result) do 
			fetch[row.Id] = {job = row.Job, duration = row.Duration, date = row.Date}
			count = count + 1 
			if (count % 4000)  == 0 or count == maxCount then 
				print(("[Job-Evaluation] %s von %s (%.2f%%)"):format(count, maxCount, (count/maxCount)*100))
			end
		end
	end

	sqlLogs:queryFetch(Async.waitFor(), "SELECT Distinct(Job) FROM ??_Job;", sqlLogs:getPrefix())
	self.m_JobList = {}
	result = Async.wait()
	if result then 
		for k, row in pairs(result) do 
			self.m_JobList[row.Job] = true;
		end
	end
	self.m_Fetched = true
	self.m_Data = fetch
	self:evaluateAverage()
end

function JobResourceEvaluate:evaluateAverage() 
	Async.create(function() 
		self:asyncAverageEvaluate(ev)
	end)()
end

function JobResourceEvaluate:asyncAverageEvaluate(ev, callback) 
	local f1, f2, f3 = debug.gethook() 
	debug.sethook(nil) -- suppress infinite-loop
	if not self.m_Fetched then return "Data still fetching please be patient..." end
	evaluateData = {}
	for job, k in pairs(self:getJobList()) do 
		evaluateData[job] = 0
	end
	for id, row in pairs(self:getData()) do 
		evaluateData[row.job] = evaluateData[row.job] + 1
	end
	local timeDifference = math.ceil( (getTimestampFromStringDate(getPastDateDay(0)) - getTimestampFromStringDate(self.m_Date)) / 86400)
	for job, count in pairs(evaluateData) do 
		evaluateData[job] = count / timeDifference
	end
	debug.sethook( f0, f1, f2, f3 ) -- restore hook 
	self.m_Average = evaluateData
end


function JobResourceEvaluate:getData() return self.m_Data end
function JobResourceEvaluate:getJobList() return self.m_JobList end

function JobResourceEvaluate:destructor()

end