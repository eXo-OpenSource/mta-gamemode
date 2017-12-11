

----------------------------------------------------------------
-- enableSnow
----------------------------------------------------------------
function enableSnow()
	if bEffectEnabled then return end
	bEffectEnabled = true
	-- Load textures
	snowTexture = dxCreateTexture('snow.png')
	snowShader = getSnowShader()				-- TODO make this better
	effectParts = {snowTexture, snowShader}

	engineApplyShaderToWorldTexture ( snowShader, "*conc*" )
	--engineApplyShaderToWorldTexture ( snowShader, "*drain*" )
	engineApplyShaderToWorldTexture ( snowShader, "*walk*" )
	engineApplyShaderToWorldTexture ( snowShader, "*pave*" )
	engineApplyShaderToWorldTexture ( snowShader, "*cross*" )
	engineApplyShaderToWorldTexture ( snowShader, "*mud*" )
	engineApplyShaderToWorldTexture ( snowShader, "*dirt*" )
	engineApplyShaderToWorldTexture ( snowShader, "*grass*" )
	engineApplyShaderToWorldTexture ( snowShader, "*newcrop*" )
	engineApplyShaderToWorldTexture ( snowShader, "*forest*" )
	engineApplyShaderToWorldTexture ( snowShader, "*grifnewtex*" )
	engineApplyShaderToWorldTexture ( snowShader, "*gravel*" )
	engineApplyShaderToWorldTexture ( snowShader, "*trailblank*" )
	engineApplyShaderToWorldTexture ( snowShader, "*stones256*" )
	engineApplyShaderToWorldTexture ( snowShader, "desertgryard256" )	-- grass
	engineApplyShaderToWorldTexture ( snowShader, "*sand*" )
	engineApplyShaderToWorldTexture ( snowShader, "*txgrass*" )
	engineApplyShaderToWorldTexture ( snowShader, "*hllblf*" )
	engineApplyShaderToWorldTexture ( snowShader, "*sl_plazatile*" )
	engineApplyShaderToWorldTexture ( snowShader, "*badmarb1_lan*" )
	engineApplyShaderToWorldTexture ( snowShader, "*parking*" )
	engineApplyShaderToWorldTexture ( snowShader, "*carpark*" )
	engineApplyShaderToWorldTexture ( snowShader, "*mono*_sfe*" )
	engineApplyShaderToWorldTexture ( snowShader, "*fancy_slab128" )
	engineApplyShaderToWorldTexture ( snowShader, "sl_sfngrssdrt*" )
	engineApplyShaderToWorldTexture ( snowShader, "sl_flagstone*" )
	engineApplyShaderToWorldTexture ( snowShader, "lasunion994*" )
	engineApplyShaderToWorldTexture ( snowShader, "tarmacplain_bank" )
	engineApplyShaderToWorldTexture ( snowShader, "sjmlahus*" )
	engineApplyShaderToWorldTexture ( snowShader, "des_scrub*" )
	engineApplyShaderToWorldTexture ( snowShader, "sjmscorclawn*" )
	engineApplyShaderToWorldTexture ( snowShader, "ws_runwaytarmac" )
	engineApplyShaderToWorldTexture ( snowShader, "greyground256" )
	engineApplyShaderToWorldTexture ( snowShader, "sjmcargr" )
	engineApplyShaderToWorldTexture ( snowShader, "sjmndukwal?" )
	engineApplyShaderToWorldTexture ( snowShader, "tarmacplain?_bank" )
	engineApplyShaderToWorldTexture ( snowShader, "rocktbrn128blnd" )
	engineApplyShaderToWorldTexture ( snowShader, "ws_rooftarmac*" )
	engineApplyShaderToWorldTexture ( snowShader, "obhilltex1*" )
	engineApplyShaderToWorldTexture ( snowShader, "tardor9")
	engineApplyShaderToWorldTexture ( snowShader, "genroof*_128")
	engineApplyShaderToWorldTexture ( snowShader, "roof*l256")
	engineApplyShaderToWorldTexture ( snowShader, "crazy paving")
	engineApplyShaderToWorldTexture ( snowShader, "bow_smear_cement")
	engineApplyShaderToWorldTexture ( snowShader, "bow_road_nomark_b")
	engineApplyShaderToWorldTexture ( snowShader, "shingleslah")
	engineApplyShaderToWorldTexture ( snowShader, "gry_roof")
	engineApplyShaderToWorldTexture ( snowShader, "rooftiles*")
	engineApplyShaderToWorldTexture ( snowShader, "shingles*")
	engineApplyShaderToWorldTexture ( snowShader, "redslates64_law")
	engineApplyShaderToWorldTexture ( snowShader, "cityhallroof")
	engineApplyShaderToWorldTexture ( snowShader, "lasjmroof")
	engineApplyShaderToWorldTexture ( snowShader, "backalley*_lae")
	engineApplyShaderToWorldTexture ( snowShader, "adet")
	engineApplyShaderToWorldTexture ( snowShader, "greyground256128")
	engineApplyShaderToWorldTexture ( snowShader, "sw_stones")
	engineApplyShaderToWorldTexture ( snowShader, "sw_farmroad*")
	engineApplyShaderToWorldTexture ( snowShader, "husruf")
	engineApplyShaderToWorldTexture ( snowShader, "plaintarmac*")
	engineApplyShaderToWorldTexture ( snowShader, "brickgrey")
	engineApplyShaderToWorldTexture ( snowShader, "ws_hextile")
	engineApplyShaderToWorldTexture ( snowShader, "sl_labedingsoil")
	engineApplyShaderToWorldTexture ( snowShader, "snpdwargrn*")
	engineApplyShaderToWorldTexture ( snowShader, "acrooftop*256")
	engineApplyShaderToWorldTexture ( snowShader, "craproad5_lae")
	engineApplyShaderToWorldTexture ( snowShader, "pierplanks_128")
	engineApplyShaderToWorldTexture ( snowShader, "cobbles_kb_256")
	engineApplyShaderToWorldTexture ( snowShader, "redclifftop256")
	engineApplyShaderToWorldTexture ( snowShader, "block2")
	engineApplyShaderToWorldTexture ( snowShader, "brickred")
	engineApplyShaderToWorldTexture ( snowShader, "pier69_ground1")
	engineApplyShaderToWorldTexture ( snowShader, "lasjmslumruf")
	engineApplyShaderToWorldTexture ( snowShader, "geiloo")
	engineApplyShaderToWorldTexture ( snowShader, "marblekb2_256128")
	engineApplyShaderToWorldTexture ( snowShader, "brngrss2stones")
	engineApplyShaderToWorldTexture ( snowShader, "brngrss2stones")
	engineApplyShaderToWorldTexture ( snowShader, "sidelatino*" )
	engineApplyShaderToWorldTexture ( snowShader, "sjmhoodlawn*" )

	for i,part in pairs(effectParts) do
		if getElementType(part) == "shader" then
			engineRemoveShaderFromWorldTexture ( part, "concpanel_la" )
			engineRemoveShaderFromWorldTexture ( part, "ws_sandstone*" )
			engineRemoveShaderFromWorldTexture ( part, "citywall2" )
			engineRemoveShaderFromWorldTexture ( part, "bow_concrete_drip" )
			engineRemoveShaderFromWorldTexture ( part, "comptwall30" )
			engineRemoveShaderFromWorldTexture ( part, "whiteconc01" )
			engineRemoveShaderFromWorldTexture ( part, "shad_exp" )
			engineRemoveShaderFromWorldTexture ( part, "dt_carpark_line_texture" )
			engineRemoveShaderFromWorldTexture ( part, "ws_sub_pen_conc*" )
			engineRemoveShaderFromWorldTexture ( part, "crossing_law" )
			engineRemoveShaderFromWorldTexture ( part, "*_carparkwall*" )
			engineRemoveShaderFromWorldTexture ( part, "oranconc*" )
			engineRemoveShaderFromWorldTexture ( part, "yelloconc*_la" )
			engineRemoveShaderFromWorldTexture ( part, "sl_hirisergrnconc" )
			engineRemoveShaderFromWorldTexture ( part, "semi3dirty" )
			engineRemoveShaderFromWorldTexture ( part, "stormdrain?_nt" )
			engineRemoveShaderFromWorldTexture ( part, "heliconcrete" )
			engineRemoveShaderFromWorldTexture ( part, "concretegroundl1_256" )
			engineRemoveShaderFromWorldTexture ( part, "sl_concretewall*" )
			engineRemoveShaderFromWorldTexture ( part, "sjmndukwal1" )
			engineRemoveShaderFromWorldTexture ( part, "concroadslab_256" )
			--engineRemoveShaderFromWorldTexture ( part, "sandnew_law" )
			engineRemoveShaderFromWorldTexture ( part, "concretewall22_256" )
			engineRemoveShaderFromWorldTexture ( part, "corugwall_sandy" )
			engineRemoveShaderFromWorldTexture ( part, "ws_whitewall2_top" )
			engineRemoveShaderFromWorldTexture ( part, "ws_whitewall2_*" )
			
			
			engineRemoveShaderFromWorldTexture ( part, "tx*" )
		end
	end
end


----------------------------------------------------------------
-- disableSnow
----------------------------------------------------------------
function disableSnow()
	if not bEffectEnabled then return end

	-- Destroy all parts
	for _,part in ipairs(effectParts) do
		if part then
			destroyElement( part )
		end
	end
	effectParts = {}
	bAllValid = false

	-- Flag effect as stopped
	bEffectEnabled = false
end


----------------------------------------------------------------
-- All the shaders
----------------------------------------------------------------

function getSnowShader()
	return getMakeShader( getSnowSettings () )
end

function getMakeShader(v)
		local shader,tec = dxCreateShader ( "swap.fx", 1, 1000 )
		if shader then
			dxSetShaderValue( shader, "swap", v.texture )
		end
		return shader,tec
end


function getSnowSettings ()
	local v = {}
	v.texture=snowTexture
	v.swap = true
	v.detailScale=2
	v.sFadeStart=80
	v.sFadeEnd=100
	v.sStrength=0.6
	v.sAnisotropy=1
	return v
end
---------------------------------
