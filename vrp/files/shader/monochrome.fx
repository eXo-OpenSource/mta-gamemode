texture ScreenTexture;
sampler implicitInputSampler = sampler_state
{
    Texture = <ScreenTexture>;
};

float4 filterColor = float4(0.4, 0.4, 0.4, 1);
float luminanceFloat = 2;
float alpha = 1;
float Center = 0;
float BlurAmount = 0;
float negative = 0;

float4 PixelShaderFunction(float2 TextureCoordinate : TEXCOORD0) : COLOR0
{
	float2 texuv = TextureCoordinate;
	texuv -= Center;
	float4 srcColor = tex2D(implicitInputSampler, texuv);
	for(int i=0; i<15; i++)
	{
	    float scale = 1.0 + BlurAmount * (i / 14.0);
	    srcColor += tex2D(implicitInputSampler, texuv * scale + Center );
	}
		
	srcColor /= 15;
	float4 luminance = srcColor.r*0.45 + srcColor.g*0.45 + srcColor.b;
	luminance.a = luminanceFloat;
	
	if (negative == 1)
	{
		float4 invertColor = 1 - luminance;
		invertColor.a = luminance.a;
		invertColor.rgb *= invertColor.a;
		return invertColor * filterColor;
	}

	return luminance * filterColor;
	
}

technique Technique1
{
    pass Pass1
    {
        PixelShader = compile ps_2_0 PixelShaderFunction();
    }
}