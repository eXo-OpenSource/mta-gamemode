texture InputTexture;
sampler implicitInputTexture = sampler_state
{
    Texture = <InputTexture>;
};
 
texture MaskTexture;
sampler implicitMaskTexture = sampler_state
{
    Texture = <MaskTexture>;
};
 
float4 MaskTextureMain( float2 uv : TEXCOORD0 ) : COLOR0
{
    float4 inputTexture = tex2D( implicitInputTexture, uv );
    float4 inputMask = tex2D( implicitMaskTexture, uv );
    inputTexture.a = (inputMask.r + inputMask.g + inputMask.b) / 3.0f;
    return inputTexture;
}

technique Technique1
{
    pass Pass1
    {
        AlphaBlendEnable = true;
        SrcBlend = SrcAlpha;
        DestBlend = InvSrcAlpha;
        PixelShader = compile ps_2_0 MaskTextureMain();
    }
}