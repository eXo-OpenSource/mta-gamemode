	texture ScreenTexture;
	sampler implicitInputSampler = sampler_state
	{
	    Texture = <ScreenTexture>;
	};
	
	float Desaturation = 0;
	float Toned = 0.5;
	float4 LightColor = float4(1,1,0,1);
	float4 DarkColor = float4(0.5,0,0.5,1);
	
	float4 PixelShaderFunction(float2 TextureCoordinate : TEXCOORD0) : COLOR0
	{
		float2 uv = TextureCoordinate;
		float4 scnColor = LightColor * (tex2D(implicitInputSampler, uv)+float4(0,0,0,1));
		float gray = dot(float3(0.3, 0.59, 0.11), scnColor.rgb);
		
		float3 muted = lerp(scnColor.rgb, gray.xxx, Desaturation);
		float3 middle = lerp(DarkColor, LightColor, gray);
		
		scnColor.rgb = lerp(muted, middle, Toned);
		return scnColor;		
	}
	
	technique Technique1
	{
	    pass Pass1
	    {
	        PixelShader = compile ps_2_0 PixelShaderFunction();
	    }
	}