texture ScreenTexture;
sampler implicitInputSampler = sampler_state
{
    Texture = <ScreenTexture>;
};

float4 filterColor = float4(1, 1, 1, 1);

float4 PixelShaderFunction(float2 TextureCoordinate : TEXCOORD0) : COLOR0
{
	float2 texuv = TextureCoordinate;
	float4 srcColor = tex2D(implicitInputSampler, texuv);
	float4 luminance = srcColor.r*0.30 + srcColor.g*0.59 + srcColor.b*0.11;
	luminance.a = 1.0;
	
	return luminance * filterColor;
}

technique Technique1
{
    pass Pass1
    {
        PixelShader = compile ps_2_0 PixelShaderFunction();
    }
}