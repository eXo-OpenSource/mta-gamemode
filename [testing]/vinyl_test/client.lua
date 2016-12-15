-- https://www.youtube.com/watch?v=IxvY3pMwRqw
-- Testet with elegant


local sizeX, sizeY = 1000, 1000

function startVinyl()
	myRenderTarget = dxCreateRenderTarget(sizeX, sizeY, true)
	myShader = dxCreateShader("files/shader/texreplace.fx")
	dxSetShaderValue(myShader, "gTexture", myRenderTarget)
	engineApplyShaderToWorldTexture(myShader, "vehiclegrunge256")
	addEventHandler("onClientRender", root, renderVinyl)
end
addCommandHandler("vinyl", startVinyl)

function renderVinyl()
	dxSetRenderTarget(myRenderTarget)
	dxDrawRectangle(0, 0, sizeX, sizeY, tocolor(255, 0, 0, 255))
	dxDrawImage(50, 110,  50, 50, "files/images/test.png")
	dxSetRenderTarget()
end

addEventHandler( "onClientResourceStart", getRootElement( ),function(res)
	if res == getThisResource() then
		startVinyl()
	end
end)
