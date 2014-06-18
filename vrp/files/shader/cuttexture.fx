#include "mta-helper.fx"

texture gTexture;
sampler TextureSampler = sampler_state
{
    Texture = <gTexture0>;
};

float4 PixelShaderFunction(PS_INPUT In) : COLOR0
{
    float4 color = tex2D(TextureSampler, In.Texture);
	if (In.Pos[1] > 20)
	{
		color.r = 0
		color.g = 0
		color.b = 0
		color.a = 0
	}
	
    return color;
}

technique TextureCut
{
	pass P0
	{
		PixelShader = compile ps_2_0 PixelShaderFunction();
	}
}
