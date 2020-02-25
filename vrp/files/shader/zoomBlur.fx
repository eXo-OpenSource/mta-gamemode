texture ScreenTexture;
	
sampler implicitInputSampler = sampler_state
{
    Texture = <ScreenTexture>;
};
	
float Center = 0.5;
float BlurAmount = 0.5;

float4 PixelShaderFunction(float2 TextureCoordinate : TEXCOORD0) : COLOR0
{
	float2 uv = TextureCoordinate;			
	float4 c = 0;    
	uv -= Center;
		
	for(int i=0; i<15; i++)
	{
	    float scale = 1.0 + BlurAmount * (i / 14.0);
	    c += tex2D(implicitInputSampler, uv * scale + Center );
	}
		
	c /= 15;
	return c;
}
	
technique Technique1
{
    pass Pass1
    {
		PixelShader = compile ps_2_a PixelShaderFunction();
	}
}