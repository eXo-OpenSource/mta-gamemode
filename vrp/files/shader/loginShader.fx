
    //DUBOIS GREEN/MAGENTA Sidy by Side    

    texture ScreenTexture;
 
    sampler TextureSampler = sampler_state
    {
        Texture = <ScreenTexture>;
    };
 
    //------------------------ PIXEL SHADER ----------------------------------------
    float4 PixelShaderFunction(float2 TextureCoordinate : TEXCOORD0) : COLOR0
    {
		 float3 color;
		 
		 float4 original = tex2D(TextureSampler, TextureCoordinate);
		 float luminance = dot(original.rgb,  float3(0.1f, 0.6f, 0.6f));
		 
		 if(original.r > (original.g + 0.1f) && original.r > (original.b + 0.025f))
		 {
		 color.rgb = float3(0, luminance, luminance)*1.5;
		 }
		 else
		 {
		 color.rgb = luminance; //(luminance > 0.3f) ? 1.0f : 0.0f;
		 }
		 
		 return float4(color, 1);
		
    }
 
    //-------------------------- TECHNIQUES ----------------------------------------
    technique Technique1
    {
        pass Pass1
        {
            PixelShader = compile ps_2_0 PixelShaderFunction();
        }
    }