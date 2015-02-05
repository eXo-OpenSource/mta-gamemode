/*********************************************************
*
*  Multi Theft Auto: San Andreas - Deathmatch
*
*  ml_base, External lua add-on module
*
*  Copyright © 2003-2008 MTA.  All Rights Reserved.
*
*  Grand Theft Auto is © 2002-2003 Rockstar North
*
*  THE FOLLOWING SOURCES ARE PART OF THE MULTI THEFT
*  AUTO SOFTWARE DEVELOPMENT KIT AND ARE RELEASED AS
*  OPEN SOURCE FILES. THESE FILES MAY BE USED AS LONG
*  AS THE DEVELOPER AGREES TO THE LICENSE THAT IS
*  PROVIDED WITH THIS PACKAGE.
*
*********************************************************/

#include "CFunctions.h"
#include "extra/CLuaArguments.h"
#include "WayFinderJobManager.h"

int CFunctions::calculateRouteBetweenPoints ( lua_State* luaVM )
{
    if ( !luaVM )
        return 0;

    // Create a new job
    WayFinderJob job;
    job.positionFrom.x = lua_tonumber(luaVM, 0);
    job.positionFrom.y = lua_tonumber(luaVM, 1);
    job.positionFrom.z = lua_tonumber(luaVM, 2);
    job.positionTo.x = lua_tonumber(luaVM, 3);
    job.positionTo.y = lua_tonumber(luaVM, 4);
    job.positionTo.z = lua_tonumber(luaVM, 5);

    WayFinderJobManager::instance().addJob(job);

    lua_pushboolean(luaVM, true);
    return 1;
}