Christmas = inherit(Singleton)

function Christmas:constructor()
	SHADERS["Schnee"] = {["event"] = "switchSnow", ["enabled"] = true}
end
