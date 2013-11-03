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
#include <string>
#include <stdlib.h>

int CFunctions::updateFromSVN ( lua_State* pLuaVM )
{
	if ( !pLuaVM )
        return 0;

    // Read svn path
    if (lua_type(pLuaVM, 1) == LUA_TSTRING)
    {
        std::string svnPath = lua_tostring(pLuaVM, 1);
        std::string systemCommand = "cd " + svnPath + " && svn update";
        
        if (system(systemCommand.c_str()) != 0)
        {
            // System command error
            pModuleManager->ErrorPrintf("Failed to update the svn");
            lua_pushboolean(pLuaVM, false);
            return 1;
        }

        // Create the logfile
        if (lua_type(pLuaVM, 2) == LUA_TSTRING)
        {
            std::string logPath = lua_tostring(pLuaVM, 2);
            system(("cd " + svnPath + " && svn log --xml > " + logPath).c_str());
        }

        // Call event
        lua_getglobal(pLuaVM, "triggerEvent");
        lua_pushstring(pLuaVM, "onSVNUpdate");
        lua_getglobal(pLuaVM, "root");
        lua_call(pLuaVM, 2, 0);

        // Return on success
        lua_pushboolean(pLuaVM, true);
        return 1;
    }
    else
        pModuleManager->ErrorPrintf("Bad argument @ updateFromSVN");

    lua_pushboolean(pLuaVM, false);
    return 1;
}
