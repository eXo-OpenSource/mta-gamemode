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

// INTERFACE for Lua dynamic modules

#ifndef __ILUAMODULEMANAGER_H
#define __ILUAMODULEMANAGER_H

#define MAX_INFO_LENGTH 128

extern "C"
{
    #include "include/lua.h"
    #include "include/lualib.h"
    #include "include/lauxlib.h"
}

class ILuaModuleManager
{
public:
	virtual void			ErrorPrintf			( const char* szFormat, ... ) = 0;
	virtual void			DebugPrintf			( lua_State * luaVM, const char* szFormat, ... ) = 0;
	virtual void			Printf				( const char* szFormat, ... ) = 0;
	virtual bool			RegisterFunction	( lua_State * luaVM, const char *szFunctionName, lua_CFunction Func ) = 0;
	virtual const char*		GetResourceName		( lua_State * luaVM ) = 0;
	virtual unsigned long	GetResourceMetaCRC	( lua_State * luaVM ) = 0;
	virtual unsigned long	GetResourceFileCRC	( lua_State * luaVM, const char* szFile ) = 0;
};

#endif
