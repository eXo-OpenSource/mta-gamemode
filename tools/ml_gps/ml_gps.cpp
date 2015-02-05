/*********************************************************
*
*  Multi Theft Auto: San Andreas - Deathmatch
*
*  ml_base, External lua add-on module
*  
*  Copyright � 2003-2008 MTA.  All Rights Reserved.
*
*  Grand Theft Auto is � 2002-2003 Rockstar North
*
*  THE FOLLOWING SOURCES ARE PART OF THE MULTI THEFT
*  AUTO SOFTWARE DEVELOPMENT KIT AND ARE RELEASED AS
*  OPEN SOURCE FILES. THESE FILES MAY BE USED AS LONG
*  AS THE DEVELOPER AGREES TO THE LICENSE THAT IS
*  PROVIDED WITH THIS PACKAGE.
*
*********************************************************/

#include "ml_gps.h"
#include "WayFinderJobManager.h"

ILuaModuleManager10* pModuleManager = nullptr;

// Initialisation function (module entrypoint)
MTAEXPORT bool InitModule ( ILuaModuleManager10* pManager, char* szModuleName, char* szAuthor, float* fVersion )
{
    pModuleManager = pManager;

    // Set the module info
    memcpy ( szModuleName, MODULE_NAME, MAX_INFO_LENGTH );
    memcpy ( szAuthor, MODULE_AUTHOR, MAX_INFO_LENGTH );
    (*fVersion) = MODULE_VERSION;

    // Initialise way finder job manager
    new WayFinderJobManager;

    return true;
}


MTAEXPORT void RegisterFunctions ( lua_State* luaVM )
{
    if ( pModuleManager && luaVM )
    {
        pModuleManager->RegisterFunction ( luaVM, "calculateRouteBetweenPoints", CFunctions::calculateRouteBetweenPoints );
    }
}


MTAEXPORT bool DoPulse ( void )
{
    return true;
}

MTAEXPORT bool ShutdownModule ( void )
{
    WayFinderJobManager::instance().stop();
    return true;
}

MTAEXPORT bool ResourceStopping ( lua_State* luaVM )
{
    return true;
}

MTAEXPORT bool ResourceStopped ( lua_State* luaVM )
{
    return true;
}