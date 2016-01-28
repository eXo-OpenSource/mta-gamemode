solution "Pathfind" 
	configurations { "Debug", "Release" }
	
	location ( "Build" )
	
	flags { "C++14" }
	platforms { "x86", "x64" }
	
	includedirs { "include" }
	libdirs { "lib" }	

	configuration "windows"
		defines { "WINDOWS", "WIN32" }
	
	configuration "Debug"
		flags { "Symbols" }
		defines { "DEBUG" }
		
	configuration "Release"
		flags { "Optimize" }
	
	project "ml_pathfind"
		language "C++"
		kind "SharedLib"
		targetname "ml_pathfind"
		
		vpaths { 
			["Headers/*"] = "**.h",
			["Sources/*"] = "**.c",
			["*"] = "premake5.lua"
		}
		
		files {
			"premake5.lua",
			"**.cpp",
			"**.h"
		}
