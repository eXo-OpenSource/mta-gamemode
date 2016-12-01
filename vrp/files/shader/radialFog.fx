    texture ScreenTexture;
 
    sampler TextureSampler = sampler_state
    {
        Texture = <ScreenTexture>;
    };
 
    //------------------------ PIXEL SHADER ----------------------------------------
	float4 PSSmoothen(float2 input : TEXCOORD0) : COLOR0
	{
	 float hPixel = 1.0f / 320.0f;
	 float vPixel = 1.0f / 480.0f;
	 
	 float3 color = float3(0, 0, 0);
	 
	 color += tex2D(TextureSampler, input) * 4.0f;
	 color += tex2D(TextureSampler, input + float2(-hPixel, 0)) * 2.0f;
	 color += tex2D(TextureSampler, input + float2(hPixel, 0)) * 2.0f;
	 color += tex2D(TextureSampler, input + float2(0, -vPixel)) * 2.0f;
	 color += tex2D(TextureSampler, input + float2(0, vPixel)) * 2.0f;
	 
	 color += tex2D(TextureSampler, input + float2(-hPixel, -vPixel));
	 color += tex2D(TextureSampler, input + float2(hPixel, -vPixel));
	 color += tex2D(TextureSampler, input + float2(-hPixel, vPixel));
	 color += tex2D(TextureSampler, input + float2(hPixel, vPixel));
	 
	 color /= 16;
	 
	 return float4(color, 1);
	 
	}
 
    //-------------------------- TECHNIQUES ----------------------------------------
    technique Technique1
    {
        pass Pass1
        {
            PixelShader = compile ps_2_0 PSSmoothen();
        }
    }