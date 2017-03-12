-- https://www.youtube.com/watch?v=IxvY3pMwRqw
-- Testet with elegant


local sizeX, sizeY = 1000, 1000

function startVinyl()
	local myShader, tec = dxCreateShader ( "files/shader/texreplace.fx", 1, 0, false, "all" )
	texture = dxCreateRenderTarget(1000, 1000, false)

	dxSetShaderValue( myShader, "Tex0", texture )
	engineApplyShaderToWorldTexture ( myShader, "cj_ped_head" )
	engineApplyShaderToWorldTexture ( myShader, "cj_ped_torso", localPlayer )

	addEventHandler("onClientRender", root, renderVinyl)
end
addCommandHandler("vinyl", startVinyl)

function renderVinyl()
	dxSetRenderTarget(texture)

		--dxDrawRectangle(0, 0, 1000, 1000, tocolor(125, 23, 32, 255))
		dxDrawImage(0, 0, 1000, 1000, "files/images/test.png")

	dxSetRenderTarget(nil)
end
