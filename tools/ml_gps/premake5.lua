solution "PathFind"
	configurations { "Debug", "Release" }
	location ( "Build" )

	flags { "C++14", "Symbols" }
	platforms { "x86", "x64" }
	pic "On"

	includedirs { "include" }
	libdirs { "lib" }

	filter "system:windows"
		defines { "WINDOWS", "WIN32" }

	filter "configurations:Debug"
		defines { "DEBUG" }

	filter "configurations:Release"
		flags { "Optimize" }

	project "ml_pathfind"
		language "C++"
		kind "SharedLib"
		targetname "ml_pathfind"

		vpaths {
			["Headers/*"] = "**.h",
			["Sources/*"] = "**.cpp",
			["*"] = "premake5.lua"
		}

		files {
			"premake5.lua",
			"**.cpp",
			"**.h"
		}
		
		filter { "system:windows", "platforms:x86" }
			links { "lua5.1.lib" }
			
		filter { "system:windows", "platforms:x64" }
			links { "lua5.1_64.lib" }
