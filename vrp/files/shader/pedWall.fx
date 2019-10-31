//
// ped_wall.fx
//

//------------------------------------------------------------------------------------------
// Variables
//------------------------------------------------------------------------------------------
float4 sColorizePed = float4(1,1,1,1);
float sSpecularPower = 2;
float sWorldViewPosMult = 1;

//------------------------------------------------------------------------------------------
// Include some common stuff
//------------------------------------------------------------------------------------------
texture gTexture0 < string textureState="0,Texture"; >;
float4x4 gWorld : WORLD;
float4x4 gView : VIEW;
float4x4 gWorldView : WORLDVIEW;
float4x4 gProjection: PROJECTION;
float3 gCameraDirection : CAMERADIRECTION;
float3 gCameraPosition : CAMERAPOSITION;
int CUSTOMFLAGS <string createNormals = "yes"; string skipUnusedParameters = "yes"; >;

//------------------------------------------------------------------------------------------
// Sampler Inputs
//------------------------------------------------------------------------------------------
sampler ColorSampler = sampler_state
{
    Texture = (gTexture0);
};

//------------------------------------------------------------------------------------------
// Structure of data sent to the vertex shader
//------------------------------------------------------------------------------------------
struct VSInput
{
    float4 Position : POSITION0;
    float3 Normal : NORMAL0;
    float2 TexCoord : TEXCOORD0;
};

//------------------------------------------------------------------------------------------
// Structure of data sent to the pixel shader ( from the vertex shader )
//------------------------------------------------------------------------------------------
struct PSInput
{
    float4 Position : POSITION0;
    float2 TexCoord : TEXCOORD0;
    float SpecLighting : TEXCOORD1;
};

//------------------------------------------------------------------------------------------
// VertexShaderFunction
//------------------------------------------------------------------------------------------
PSInput VertexShaderFunction(VSInput VS)
{
    PSInput PS = (PSInput)0;

    float4 worldPos = mul(float4(VS.Position.xyz, 1.0),gWorld);
    float4 viewPos = mul(worldPos, gView);
    PS.Position = mul(viewPos, gProjection);
	
    PS.TexCoord = VS.TexCoord;

    float3 Normal = normalize(mul(VS.Normal, (float3x3)gWorld));
    float dotProduct = dot(-gCameraDirection, Normal);	
    PS.SpecLighting = saturate(pow(dotProduct, sSpecularPower));	
    return PS;
}

//------------------------------------------------------------------------------------------
// PixelShaderFunction
//------------------------------------------------------------------------------------------
float4 PixelShaderFunction(PSInput PS) : COLOR0
{
    float4 color = sColorizePed;
    color.a *= saturate(1 - PS.SpecLighting * 2);
    color.a *= tex2D(ColorSampler,PS.TexCoord).a;
    return color;
}

//------------------------------------------------------------------------------------------
// Techniques
//------------------------------------------------------------------------------------------
technique ped_wall
{
    pass P0
    {
        ZEnable = false;
        AlphaBlendEnable = true;
        AlphaRef = 1;
        SrcBlend = SrcAlpha;
        DestBlend = One;
        VertexShader = compile vs_2_0 VertexShaderFunction();
        PixelShader  = compile ps_2_0 PixelShaderFunction();
    }
}

// Fallback
technique fallback
{
    pass P0
    {
        // Just draw normally
    }
}
