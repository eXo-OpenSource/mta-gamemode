texture ScreenTexture;

sampler implicitInputSampler = sampler_state
{
    Texture = <ScreenTexture>;
};

float Exposure = 0.2;
float Defog = 1.1;
float Gamma = 7;
float4 FogColor = float4(0.2,0.2,0.2,1);
float VignetteRadius = 0.5;
float2 VignetteCenter = float2(0.5,0.5);
float BlueShift = 0.1;

float4 PixelShaderFunction(float2 TextureCoordinate : TEXCOORD0) : COLOR0
{
  float2 uv = TextureCoordinate;
  float4 c = tex2D(implicitInputSampler, uv);
  c.rgb = max(0, c.rgb - Defog * FogColor.rgb);
  c.rgb *= pow(2.0f, Exposure);
  c.rgb = pow(c.rgb, Gamma);

  float2 tc = uv - VignetteCenter;
  float v = 1.0f - dot(tc, tc);
  c.rgb += pow(v, 4) * VignetteRadius;

  float3 d = c.rgb * float3(1.05f, 0.97f, 1.27f);
  c.rgb = lerp(c.rgb, d, BlueShift);

  return c;
}

technique Technique1
{
    pass Pass1
    {
        PixelShader = compile ps_2_0 PixelShaderFunction();
    }
}
