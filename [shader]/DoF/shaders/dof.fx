texture screenSource;
texture blurredSource;
texture farPlane;
float2 screenSize = float2(0, 0);
float saturation = 1.0;
float contrast = 1.0;
float brightness = 1.0;

sampler ScreenSourceSampler = sampler_state {
    Texture = <screenSource>;
	MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = Linear;
    AddressU = Mirror;
    AddressV = Mirror;
};


sampler FarPlaneSampler = sampler_state {
    Texture = <farPlane>;
	MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = Linear;
    AddressU = Mirror;
    AddressV = Mirror;
};

sampler BlurredSampler = sampler_state {
    Texture = <blurredSource>;
	MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = Linear;
    AddressU = Mirror;
    AddressV = Mirror;
};


float4 PixelShaderFunction(float2 texCoords : TEXCOORD0) : COLOR0 {	
	
	float4 baseColor = tex2D(ScreenSourceSampler, texCoords);
	float4 farPlaneColor = tex2D(FarPlaneSampler, texCoords);
	float4 blurColor = tex2D(BlurredSampler, texCoords);
	
	float4 allColor = lerp(baseColor, blurColor, farPlaneColor.r);
	
	float3 luminanceWeights = float3(0.299, 0.587, 0.114);
	float luminance = dot(allColor, luminanceWeights);
	float4 finalColor = lerp(luminance, allColor, saturation);
	finalColor.rgb *= 1.5;
	
	finalColor.a = allColor.a;
	finalColor.rgb = ((finalColor.rgb - 0.5f) * max(contrast, 0)) + 0.5f;
	finalColor.rgb *= brightness;
	
	return finalColor;
}
 
 
technique Dof
{
    pass Pass1
    {
        PixelShader = compile ps_2_0 PixelShaderFunction();
    }
}