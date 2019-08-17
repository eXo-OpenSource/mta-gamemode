texture ScreenSource;
float radius;
float darkness;
 
sampler TextureSampler = sampler_state
{
    Texture = <ScreenSource>;
};
 
float4 PixelShaderFunction(float2 Tex : TEXCOORD0) : COLOR0
{
	float4 newSampler = tex2D(TextureSampler, Tex);
	float2 inTex = Tex - 0.5;
	float vignette = 1 - dot(inTex, inTex);
	newSampler.rgb *= saturate(pow(vignette, radius) + (1-darkness));
	return newSampler;
}

technique Vignette
{
    pass P0
    {
        PixelShader = compile ps_2_0 PixelShaderFunction();
    }
}
