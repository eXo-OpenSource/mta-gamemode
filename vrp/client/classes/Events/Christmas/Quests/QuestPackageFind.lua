QuestPackageFind = inherit(Object)
QuestPackageFind.isInQuest = false

function QuestPackageFind:constructor()
	QuestPackageFind.isInQuest = true
	QuestPackageFind.togglePackages(true)
end

function QuestPackageFind:destructor()
	QuestPackageFind.isInQuest = false
	QuestPackageFind.togglePackages(false)
end

function QuestPackageFind.togglePackages(state)
	for index, object in pairs(getElementsByType("object")) do
		if object:getModel() == 3878 then
			object:setCollisionsEnabled(state)
			object:setAlpha(state and 255 or 0)
		end
	end
end

function QuestPackageFind.refreshPackages(state)
	QuestPackageFind.togglePackages(QuestPackageFind.isInQuest)
end
addEvent("questPackagesFindRefreshPackages", true)
addEventHandler("questPackagesFindRefreshPackages", root, QuestPackageFind.refreshPackages)

