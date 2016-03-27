texture ScreenTexture;

sampler implicitInputSampler = sampler_state
{
    Texture = <ScreenTexture>;
};

float Amount = 1.3;
float Width = 0.001;

float4 PixelShaderFunction(float2 TextureCoordinate : TEXCOORD0) : COLOR0
{
  float2 uv = TextureCoordinate;
  float4 color = tex2D(implicitInputSampler, uv);
  color.rgb += tex2D(implicitInputSampler, uv - Width) * Amount;
  color.rgb -= tex2D(implicitInputSampler, uv + Width) * Amount;
  return color;
}

technique Technique1
{
    pass Pass1
    {
        PixelShader = compile ps_2_0 PixelShaderFunction();
    }
}
