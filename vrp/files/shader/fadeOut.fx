texture screenSource;
float2 screenSize = (0, 0);
float2 center = (0.5, 0.5);
float fadeProcess = 0;


sampler ScreenSourceSampler = sampler_state
{
    Texture = (screenSource);
	MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = Linear;
    AddressU = Mirror;
    AddressV = Mirror;
};


float4 ZoomBlur(float2 texCoords : TEXCOORD0)
{

	float4 color = 0;    
	texCoords -= center;

	for (int i = 0; i < 22; i++)  {
		float scale = 1.0 + fadeProcess * (i / 21.0);
		color += tex2D(ScreenSourceSampler, texCoords * scale + center);
	}
   
	color /= 22;
	
	return color;
}
 

float4 LensflarePixelShader(float2 texCoords : TEXCOORD) : COLOR
{
	float4 mainColor = ZoomBlur(texCoords); // tex2D(ScreenSourceSampler, texCoords); // ohne Blur
	mainColor.rgb *= 1 - fadeProcess / 2;
	
	float4 blackColor = float4(0, 0, 0, 1);
	
	float distfromcenter = distance(float2(center), texCoords);
	float4 finalColor = lerp(float4(mainColor.rgb, 1), float4(blackColor.rgb, 1), distfromcenter / 0.5 * fadeProcess * 3);
	
	if (fadeProcess >= 0.8) {finalColor = blackColor;}
	
	return finalColor;
}
 

technique fadeOut
{
	pass p0
    {
		AlphaBlendEnable = true;
		PixelShader = compile ps_2_0 LensflarePixelShader();
    }
}
 
// Fallback
technique Fallback
{
    pass P0
    {
        // Just draw normally
    }
}