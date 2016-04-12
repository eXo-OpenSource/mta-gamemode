-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        shared/version.lua
-- *  PURPOSE:     Version
-- *
-- ****************************************************************************
VERSION = "0.1"
BUILD = "development"
--BUILD = "stable"
--BUILD = "unstable"
REVISION = 0
PROJECT_NAME = "eXo Reallife"

if BUILD == "development" then
	VERSION_LABEL = ("%s %sdev r%d"):format(PROJECT_NAME, VERSION, REVISION)
elseif BUILD == "unstable" then
	VERSION_LABEL = ("%s %s unstable"):format(PROJECT_NAME, VERSION)
else
	VERSION_LABEL = ("%s %s"):format(PROJECT_NAME, VERSION)
end
