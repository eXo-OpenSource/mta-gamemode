texture ScreenTexture;
sampler implicitInputSampler = sampler_state
{
    Texture = <ScreenTexture>;
};

float4 filterColor = float4(0.85, 0.85, 1, 1);
float luminanceFloat = 1;
float alpha = 1;
float4 PixelShaderFunction(float2 TextureCoordinate : TEXCOORD0) : COLOR0
{
	float2 texuv = TextureCoordinate;
	float4 srcColor = tex2D(implicitInputSampler, texuv);
	float4 luminance = srcColor.r*0.45 + srcColor.g*0.45 + srcColor.b;
	luminance.a = luminanceFloat;
	
	return luminance * filterColor;
}

technique Technique1
{
    pass Pass1
    {
        PixelShader = compile ps_2_0 PixelShaderFunction();
    }
}